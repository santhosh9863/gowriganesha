import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

admin.initializeApp();

const CHUNK_SIZE = 500;
const NOTIFICATION_COLLECTION = 'notifications';
const DEVICE_TOKENS_COLLECTION = 'device_tokens';
const PREFERENCES_COLLECTION = 'notification_preferences';

interface DeviceTokenDoc {
  ref: admin.firestore.DocumentReference;
  token: string;
  userId: string;
}

interface NotificationPreferences {
  pushEnabled: boolean;
  channels: Record<string, boolean>;
}

const defaultPreferences: NotificationPreferences = {
  pushEnabled: true,
  channels: {},
};

function getCorrelationId(event: { params: Record<string, string> }): string {
  return `notif-${event.params.notificationId}`;
}

async function getPreferencesBatch(
  db: admin.firestore.Firestore,
  userIds: Set<string>,
): Promise<Map<string, NotificationPreferences>> {
  const prefsMap = new Map<string, NotificationPreferences>();
  const chunk = Array.from(userIds);
  for (let i = 0; i < chunk.length; i += 30) {
    const batch = chunk.slice(i, i + 30);
    const docs = await db
      .collection(PREFERENCES_COLLECTION)
      .where('__name__', 'in', batch)
      .get();
    for (const doc of docs.docs) {
      const data = doc.data();
      prefsMap.set(doc.id, {
        pushEnabled: data.pushEnabled !== false,
        channels: (data.channels as Record<string, boolean>) ?? {},
      });
    }
  }
  return prefsMap;
}

async function updateDeliveryMetadata(
  db: admin.firestore.Firestore,
  notificationId: string,
  correlationId: string,
  status: 'attempted' | 'sent' | 'failed',
  error?: string,
): Promise<void> {
  const update: Record<string, unknown> = {
    'metadata.deliveryStatus': status,
    'metadata.lastDeliveryAttempt': admin.firestore.FieldValue.serverTimestamp(),
  };

  if (error) {
    update['metadata.lastDeliveryError'] = error;
    update['metadata.deliveryAttempts'] = admin.firestore.FieldValue.increment(1);
  }

  try {
    await db.collection(NOTIFICATION_COLLECTION).doc(notificationId).update(update);
  } catch (err) {
    logger.warn(`[${correlationId}] Failed to update delivery metadata:`, err);
  }
}

export const sendNotificationPush = onDocumentCreated(
  NOTIFICATION_COLLECTION + '/{notificationId}',
  async (event) => {
    const correlationId = getCorrelationId(event);
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn(`[${correlationId}] No data in notification document`);
      return;
    }

    const notification = snapshot.data();
    const notificationId = event.params.notificationId as string;
    const title = notification.title as string | undefined;
    const body = notification.body as string | undefined;
    const type = notification.type as string | undefined;
    const priority = notification.priority as string | undefined;
    const entityType = notification.entityType as string | undefined;
    const entityId = notification.entityId as string | undefined;
    const category = notification.category as string | undefined;
    if (!title || !body) {
      logger.warn(`[${correlationId}] Skipping notification without title or body`);
      return;
    }

    const db = admin.firestore();

    await updateDeliveryMetadata(db, notificationId, correlationId, 'attempted');

    const tokensSnapshot = await db.collection(DEVICE_TOKENS_COLLECTION).get();

    const tokens: DeviceTokenDoc[] = tokensSnapshot.docs.map((doc) => ({
      ref: doc.ref,
      token: doc.data().token as string,
      userId: doc.data().userId as string,
    }));

    if (tokens.length === 0) {
      logger.info(`[${correlationId}] No device tokens registered, skipping push`);
      await updateDeliveryMetadata(db, notificationId, correlationId, 'sent');
      return;
    }

    const userIds = new Set(tokens.map((t) => t.userId));
    const preferencesMap = await getPreferencesBatch(db, userIds);

    const eligibleTokens = tokens.filter((t) => {
      const userPrefs = preferencesMap.get(t.userId) ?? defaultPreferences;
      if (!userPrefs.pushEnabled) return false;
      if (category && userPrefs.channels[category] === false) return false;
      return true;
    });

    if (eligibleTokens.length === 0) {
      logger.info(
        `[${correlationId}] All users have disabled push for this notification, skipping`,
      );
      await updateDeliveryMetadata(db, notificationId, correlationId, 'sent');
      return;
    }

    const notificationPayload: admin.messaging.Notification = {
      title,
      body,
    };

    const dataPayload: Record<string, string> = {
      notificationId,
    };
    if (type) dataPayload.type = type;
    if (priority) dataPayload.priority = priority;
    if (entityType) dataPayload.entityType = entityType;
    if (entityId) dataPayload.entityId = entityId;
    if (category) dataPayload.category = category;

    const failedTokens: admin.firestore.DocumentReference[] = [];
    let totalSent = 0;

    for (let i = 0; i < eligibleTokens.length; i += CHUNK_SIZE) {
      const chunk = eligibleTokens.slice(i, i + CHUNK_SIZE);
      const tokenStrings = chunk.map((t) => t.token);

      try {
        const response = await admin.messaging().sendEachForMulticast({
          tokens: tokenStrings,
          notification: notificationPayload,
          data: dataPayload,
        });

        totalSent += response.successCount;

        if (response.failureCount > 0) {
          response.responses.forEach((resp, index) => {
            if (!resp.success && resp.error) {
              const code = resp.error.code;
              if (
                code === 'messaging/invalid-registration-token' ||
                code === 'messaging/registration-token-not-registered'
              ) {
                failedTokens.push(chunk[index].ref);
              }
            }
          });

          logger.info(
            `[${correlationId}] Chunk ${i / CHUNK_SIZE + 1}: ${response.successCount} sent, ` +
              `${response.failureCount} failed`,
          );
        }
      } catch (error) {
        logger.error(
          `[${correlationId}] Failed to send chunk ${i / CHUNK_SIZE + 1}:`,
          error,
        );
      }
    }

    if (failedTokens.length > 0) {
      const batch = db.batch();
      for (const ref of failedTokens) {
        batch.delete(ref);
      }
      await batch.commit();
      logger.warn(
        `[${correlationId}] Removed ${failedTokens.length} invalid device tokens`,
      );
    }

    const deliveredCount = eligibleTokens.length - failedTokens.length;
    await updateDeliveryMetadata(db, notificationId, correlationId, 'sent');

    logger.info(
      `[${correlationId}] Sent notification ${notificationId} to ${deliveredCount} devices ` +
        `(${eligibleTokens.length} eligible, ${totalSent} successful)`,
    );
  },
);

const NOTIFICATION_RETENTION_DAYS_KEY = 'notificationRetentionDays';
const DEFAULT_RETENTION_DAYS = 90;

export const archiveOldNotifications = onSchedule(
  'every day 03:00',
  async (event) => {
    const correlationId = `archive-${Date.now().toString()}`;
    const db = admin.firestore();
    const settingsDoc = await db
      .collection('settings')
      .doc('ganesha_2026')
      .get();
    const retentionDays =
      (settingsDoc.data()?.[NOTIFICATION_RETENTION_DAYS_KEY] as number) ??
      DEFAULT_RETENTION_DAYS;

    const cutoff = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - retentionDays * 24 * 60 * 60 * 1000),
    );

    const snapshot = await db
      .collection('notifications')
      .where('archivedAt', '==', null)
      .where('createdAt', '<', cutoff)
      .get();

    if (snapshot.docs.length === 0) {
      logger.info(`[${correlationId}] No notifications to archive`);
      return;
    }

    let archived = 0;
    const batch = db.batch();
    for (const doc of snapshot.docs) {
      batch.update(doc.ref, {
        archivedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      archived++;
      if (archived % 500 === 0) {
        await batch.commit();
        logger.info(
          `[${correlationId}] Archived ${archived} / ${snapshot.docs.length} notifications`,
        );
      }
    }
    await batch.commit();

    logger.info(
      `[${correlationId}] Archived ${archived} notifications (retention: ${retentionDays}d)`,
    );
  },
);
