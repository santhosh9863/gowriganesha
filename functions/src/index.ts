import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

admin.initializeApp();

const CHUNK_SIZE = 500;

export const sendNotificationPush = onDocumentCreated(
  'notifications/{notificationId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.warn('No data in notification document');
      return;
    }

    const notification = snapshot.data();
    const title = notification.title as string | undefined;
    const body = notification.body as string | undefined;
    const type = notification.type as string | undefined;
    const priority = notification.priority as string | undefined;
    const entityType = notification.entityType as string | undefined;
    const entityId = notification.entityId as string | undefined;

    if (!title || !body) {
      logger.warn('Skipping notification without title or body');
      return;
    }

    const tokensSnapshot = await admin
      .firestore()
      .collection('device_tokens')
      .get();

    const tokens = tokensSnapshot.docs.map((doc) => {
      return { ref: doc.ref, token: doc.data().token as string };
    });

    if (tokens.length === 0) {
      logger.info('No device tokens registered, skipping push');
      return;
    }

    const notificationPayload: admin.messaging.Notification = {
      title,
      body,
    };

    const dataPayload: Record<string, string> = {
      notificationId: event.params.notificationId,
    };
    if (type) dataPayload.type = type;
    if (priority) dataPayload.priority = priority;
    if (entityType) dataPayload.entityType = entityType;
    if (entityId) dataPayload.entityId = entityId;

    const failedTokens: admin.firestore.DocumentReference[] = [];

    for (let i = 0; i < tokens.length; i += CHUNK_SIZE) {
      const chunk = tokens.slice(i, i + CHUNK_SIZE);
      const tokenStrings = chunk.map((t) => t.token);

      try {
        const response = await admin.messaging().sendEachForMulticast({
          tokens: tokenStrings,
          notification: notificationPayload,
          data: dataPayload,
        });

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
            `Chunk ${i / CHUNK_SIZE + 1}: ${response.successCount} sent, ` +
              `${response.failureCount} failed`,
          );
        }
      } catch (error) {
        logger.error(
          `Failed to send chunk ${i / CHUNK_SIZE + 1}:`,
          error,
        );
      }
    }

    if (failedTokens.length > 0) {
      const batch = admin.firestore().batch();
      for (const ref of failedTokens) {
        batch.delete(ref);
      }
      await batch.commit();
      logger.warn(`Removed ${failedTokens.length} invalid device tokens`);
    }

    logger.info(
      `Sent notification ${event.params.notificationId} to ${tokens.length - failedTokens.length} devices`,
    );
  },
);
