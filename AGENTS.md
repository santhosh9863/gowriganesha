# Sankalpa — OpenCode Agent Instructions

This file is loaded automatically at the start of every OpenCode session. It defines how the Sankalpa project must be built, modified, and tested. Follow every section below. Do not deviate from established patterns.

---

## 1. Project Overview

**Sankalpa** is a festival management application for *Sri Gowri Ganesha Geleyara Balaga*, a Bengaluru-based community trust. It tracks sponsorships (targets), daily collections, expenses, follow-ups, and activities for the annual Ganesha festival.

### Primary Users

- **Admin** — Full CRUD on all entities, access to settings, budget, QR upload, data seeding.
- **Volunteer** — Read-only access to targets, expenses, daily collections. Cannot edit/delete records created by others. Cannot add expenses, daily collections, or follow-ups.

### Core Goals

- Track sponsorship contributions against targets.
- Record daily street/area collections.
- Log festival expenses.
- Schedule and complete sponsor follow-ups.
- Unify all activity in a real-time notification + timeline feed.
- Deliver push notifications to all devices via FCM.

### Current Architecture (simplified)

```
User action → Feature Page (UI)
  → Provider (state + orchestration)
    → Service (business logic)
      → Repository/API (Firestore persistence)
        → Model (data class)
```

---

## 2. Technology Stack

| Layer | Technology | Version |
|---|---|---|
| Language | Dart | ^3.11.5 |
| Framework | Flutter (Material 3) | SDK bundled |
| State | flutter_riverpod | ^2.4 |
| Routing | go_router | ^13.0 |
| Backend | Firebase Firestore | ^4.14 |
| Auth | firebase_auth (anonymous) | ^4.16 |
| Storage | firebase_storage | ^11.6 |
| Push | firebase_messaging | ^14.9 |
| Fonts | google_fonts (Inter) | ^6.1 |
| Charts | fl_chart | ^1.2 |
| QR | qr_flutter | ^4.1 |
| Share | share_plus | ^9.0 |
| Local | shared_preferences | ^2.2 |
| Crypto | crypto | ^3.0 |
| Server | Firebase Cloud Functions (Node 22) | TypeScript |
| Image | image_picker | ^1.0 |

---

## 3. Project Folder Structure

```
lib/
  app.dart                   -- GoRouter config, GaneshaApp widget
  main.dart                  -- App entry, provider scope init
  firebase_options.dart      -- Generated Firebase config

  core/
    constants.dart           -- AppConstants (festivalId, currency, etc.)
    theme.dart               -- AppTheme (Material 3 theme data)
    design/
      app_colors.dart        -- Sankalpa color palette
      app_typography.dart    -- Inter text theme (all tiers)
      app_spacing.dart       -- Spacing constants (xs→xxxxl)
      app_radius.dart        -- Border radius tiers + shortcuts
      app_shadows.dart       -- Shadow tiers (none→elevated)
    models/
      user_role.dart         -- UserRole enum (none, admin, volunteer)
      target.dart            -- Sponsor target model
      expense.dart           -- Expense model
      daily_collection.dart  -- Daily collection model
      activity.dart          -- Timeline activity model
      contribution.dart      -- Sponsor contribution model
      sponsor_followup.dart  -- Follow-up model
      festival.dart          -- Festival metadata model
      app_notification.dart  -- In-app notification model
      notification_type.dart -- Category, priority, type, status enums
    providers/               -- Riverpod providers (one per domain)
      auth_provider.dart     -- Role, userId, userName providers
      festival_provider.dart -- Festival document provider
      target_provider.dart   -- Targets CRUD + stream providers
      expense_provider.dart  -- Expenses CRUD + stream providers
      daily_collection_provider.dart
      followup_provider.dart -- Follow-ups stream + state
      dashboard_provider.dart-- Aggregated dashboard data
      chart_provider.dart    -- Chart data
      activity_provider.dart -- Activity feed stream
      contribution_provider.dart
      budget_provider.dart
      financial_metrics_provider.dart
      notification_provider.dart -- Notification services + streams
    services/                -- Business logic + data access
      firestore_service.dart -- Firestore CRUD (all collections)
      activity_service.dart  -- Record activity + notification creation
      notification_repository.dart -- Notifications CRUD + streams
      notification_service.dart   -- Notification orchestration
      notification_factory.dart   -- Constructs AppNotification instances
      notification_messages.dart  -- String templates
      notification_navigator.dart -- Route resolution from notification
      notification_permission_service.dart
      local_notification_service.dart
      push_notification_service.dart -- FCM token + message handling
      firestore_service.dart
      seed_data.dart         -- Dev data seeder
    utils/                   -- Shared utilities

  features/                  -- One folder per domain
    auth/
      entry_page.dart        -- Login screen
    dashboard/
      dashboard_page.dart    -- Main dashboard
    collections/
      collection_list_page.dart
      collection_detail_page.dart
      collection_form_page.dart
    daily_collections/
      daily_collection_list_page.dart
      daily_collection_form_page.dart
    expenses/
      expense_list_page.dart
      expense_form_page.dart
    followups/
      followup_list_page.dart
      followup_form_page.dart
    notifications/
      notification_center_page.dart
    settings/
      settings_page.dart
    splash/                  -- (reserved)

  shared/
    services/
      festival_countdown_service.dart
    utils/
      amount_format.dart     -- Currency formatting utility
    widgets/                 -- Reusable UI components (29 widgets)
      app_scaffold.dart      -- App shell with bottom nav + banner
      animated_bottom_nav.dart
      app_page_scaffold.dart
      app_page_header.dart
      app_page_actions.dart
      app_bell_icon.dart
      app_notification_banner.dart
      app_notification_tile.dart
      sankalpa_glass.dart
      app_empty_state.dart
      app_skeleton.dart
      app_stagger.dart
      app_card.dart / app_metric_card.dart / app_trend_card.dart
      app_progress_card.dart / app_insight_card.dart / app_countdown_card.dart
      app_status_chip.dart
      app_button.dart
      app_section_header.dart
      app_greeting_section.dart
      app_avatar_badge.dart
      app_action_tile.dart
      app_qr_sheet.dart / adjust_collection_sheet.dart
      confirm_dialog.dart
      amount_text.dart
      page_transitions.dart

functions/                   -- Firebase Cloud Functions
  src/index.ts              -- sendNotificationPush trigger
  package.json / tsconfig.json

firebase.json                -- Firebase project config
firestore.rules              -- Security rules
firestore.indexes.json       -- Composite indexes
```

### Adding a New Feature

1. Add model in `core/models/`.
2. Add CRUD in `core/services/` (repository + service classes).
3. Add providers in `core/providers/`.
4. Add pages in `features/<feature_name>/`.
5. Register routes in `app.dart`.
6. Reuse shared widgets from `shared/widgets/`.

---

## 4. Architecture Rules

### Data Flow

```
UI Widget
  ↓ reads/watches
Provider (Riverpod)
  ↓ calls
Service (business logic, orchestration)
  ↓ calls
Repository (Firestore persistence, error handling)
  ↓
Firestore
```

### Strict Prohibitions

- **Never bypass repositories** — Widgets and providers must never call `FirebaseFirestore.instance` directly. All persistence goes through `*Repository` or `FirestoreService`.
- **Never bypass services** — Providers orchestrate via `*Service` classes. Business logic (validation, multi-step operations, notification creation) lives in services.
- **Never place business logic inside widgets** — Widgets call providers. Providers call services. Services contain logic.
- **Never call `context.read` inside `build`** — Use `ref.watch` for reactive reads. Use `ref.read` only inside callbacks.
- **No duplicate repository wrappers** — If `Target`, `Expense`, `DailyCollection`, `SponsorFollowup` functionality exists in `FirestoreService`, do not create a separate repository for each. Use `FirestoreService`.
- **No duplicate providers** — Check existing providers before adding new ones.

### Riverpod Patterns

- `Provider` — For injectable singletons (services, repositories).
- `StreamProvider` — For real-time Firestore streams.
- `FutureProvider` — For one-shot async data.
- `StateNotifierProvider` — For mutable state with logic.
- `StateProvider` — For simple mutable state (strings, ints, enums).
- Never use `ChangeNotifierProvider`.

### GoRouter Rules

- `StatefulShellRoute.indexedStack` wraps all tab branches (5 tabs).
- Each branch preserves its navigation stack.
- Use `PageTransition.fadeSlide` for all page transitions (currently `NoTransitionPage` placeholder — reserved for custom transitions).
- Routes outside the shell (settings, notifications) use direct `GoRoute`.
- Route redirect logic enforces volunteer role restrictions.
- Do not change the routing structure.

---

## 5. CRUD Rules

Every feature with a Firestore collection must implement:

| Operation | Where |
|---|---|
| Create | Repository → `set()` with generated ID |
| Read (single) | Repository → `get()` |
| Read (stream) | Repository → `snapshots()` stream |
| Update | Repository → `update()` |
| Delete | Repository → `delete()` (with subcollection cleanup via batch) |

### Pattern

```dart
// In *Service class
Future<void> createFoo(Foo foo) async {
  if (!foo.isValid) throw ArgumentError('Invalid foo');
  await _repository.createFoo(foo);
}

// In *Repository class
Future<void> createFoo(Foo foo) async {
  try {
    await _collection.doc(foo.id).set(foo.toMap());
  } on FirebaseException catch (e) {
    throw FirestoreException('Failed to create foo', originalError: e);
  }
}
```

### Requirements

- Always include validation before persistence.
- Handle loading, success, and error states in the UI.
- Use Firestore `batch` for atomic multi-document writes.
- Never leave TODO CRUD methods.
- Keep Firestore writes atomic where possible.

---

## 6. Firestore Standards

### Collections

| Collection | Document ID | Notes |
|---|---|---|
| `festivals` | `ganesha_2026` | Single document |
| `targets` | Auto-generated (`_` collection doc ID) | Sponsor targets |
| `targets/{id}/contributions` | Auto-generated | Subcollection |
| `expenses` | Auto-generated | |
| `daily_collections` | Auto-generated | |
| `sponsor_followups` | Auto-generated | |
| `activities` | Auto-generated | Timeline activity feed |
| `notifications` | Auto-generated | In-app notifications |
| `device_tokens` | FCM token string | Push notification tokens |
| `notification_preferences` | `userId` | Raw map (typed model future) |
| `settings` | Fest ID (reserved) | |
| `config` | `security` | Admin hash, volunteer password |

### Document Model Pattern

```dart
class Foo {
  final String id;
  final String festivalId;  // Always filter by festivalId
  // ... fields

  Map<String, dynamic> toMap() => { ... };
  factory Foo.fromMap(String id, Map<String, dynamic> map) => ...;
  Foo copyWith({ ... }) => ...;
}
```

### Indexes

- All queries must filter by `festivalId` first.
- Composite indexes are defined in `firestore.indexes.json`.
- Avoid complex queries that require new indexes — prefer client-side filtering for small datasets.

### Batch Writes

Use `WriteBatch` for:
- Deleting a target + its contributions subcollection.
- Recording a contribution (update target `givenAmount` + create contribution doc).
- Removing multiple invalid device tokens.

### Error Handling

- All repository methods wrap Firestore calls in `try/catch`.
- Convert `FirebaseException` to `FirestoreException` with a user-friendly message.
- Streams use `.handleError()` to log without crashing.
- Debug logging uses `debugPrint` with `[DOMAIN]` prefix (e.g. `[FIRESTORE]`, `[NOTIFICATION_REPO]`).

---

## 7. UI/UX Standards

### Design Tokens — USE THESE EXCLUSIVELY

Never introduce random colors, spacing, radii, shadows, or font sizes.

| Token | File | Key Values |
|---|---|---|
| Colors | `core/design/app_colors.dart` | `primary` (#0F6B3C), `accent` (#C8A43E), `success` (#22C55E), `warning` (#E8A838), `error` (#DC2626), `info` (#3686D6), `surface` (#F4F4F0), `card` (#FFFFFF), `charcoal` (#2D2D2D), warmGray scale, semantic bg colors |
| Typography | `core/design/app_typography.dart` | Inter font. 7 tiers: display (36px), headline (24-18px), title (16-13px), body (15-13px), label (12-10px). Use specific theme properties (`theme.textTheme.titleSmall` etc.) |
| Spacing | `core/design/app_spacing.dart` | `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 20, `xxl` 24, `xxxl` 32, `xxxxl` 40 |
| Radius | `core/design/app_radius.dart` | `small` 8, `medium` 12, `large` 16, `hero` 24, `full` 999. Use named tiers + `mediumBorder`/`largeBorder` shortcuts |
| Shadows | `core/design/app_shadows.dart` | `subtle`, `soft`, `elevated`, `card`, `none` |
| Glass | `shared/widgets/sankalpa_glass.dart` | `BackdropFilter` wrapper. Used for nav bar, bell badge, notification banner |

### Card System

All cards follow this pattern:

```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: AppRadius.largeBorder,       // 16px
    border: Border.all(color: AppColors.outline),
    boxShadow: AppShadows.subtle,
  ),
  child: ...
)
```

Available card widgets: `AppCard`, `AppMetricCard`, `AppTrendCard`, `AppProgressCard`, `AppInsightCard`, `AppCountdownCard`.

### Premium Material 3 Principles

- Floating surfaces with subtle shadows.
- Glassmorphism (`SankalpaGlass`) used sparingly — bottom nav, bell badge, notification banner.
- Soft `easeOutCubic` animations (250-300ms).
- Implicit animation widgets preferred over `AnimationController`.
- Responsive layouts using `LayoutBuilder` + width breakpoints (900px wide threshold).
- Proper SafeArea handling on all screens.
- Touch targets ≥ 36x36dp.
- `SplashFactory: InkSparkle.splashFactory`.

### Page Structure

- Full-screen pages use `Scaffold` with `AppColors.surface` background.
- List pages with page headers use `AppPageHeader` + `AppSectionHeader`.
- For scrollable lists: `ListView` with proper `EdgeInsets` padding following `AppSpacing`.
- For empty states: `AppEmptyState` — never plain text.
- For loading states: `AppSkeleton` / `AppSkeletonList`.
- For error states: icon + message + retry button.

### Typography Hierarchy on Screens

- Page title: `headlineSmall` (18px w600)
- Section header: `titleLarge` (16px w600) or `labelLarge` with `letterSpacing` (12px w600)
- Card title: `titleSmall` (13px w500/w600)
- Card body: `bodySmall` (13px w400)
- Timestamps: `labelMedium` (11px w500)
- Status chips: `labelLarge` (12px w600)

### Notification-Specific Design

- Tiles: 76px fixed height, left accent bar (4px, semantic color), 32px category icon, `titleSmall` + `bodySmall` + `labelMedium` timestamp.
- Bell icon: SankalpaGlass container, pulse animation on unread count > 0, glass badge with error tint.
- Banner: SankalpaGlass slide-down + fade-in (250ms easeOutCubic), swipe to dismiss, auto-dismiss 5s.
- Filter chips: Custom `_FilterChip` with `AnimatedContainer`, primary fill when selected, `chip` border radius.
- Empty state: `AppEmptyState` with context-aware subtitle.

### Accessibility

- Wrap interactive elements in `Semantics` with descriptive `label` and `hint`.
- Ensure sufficient color contrast (semantic colors on white/light backgrounds).
- Use `tooltip` on IconButtons.

---

## 8. Component Rules

### Always Reuse Before Creating

Check `lib/shared/widgets/` before building any new UI component. The existing catalog includes:

| Widget | Purpose |
|---|---|
| `SankalpaGlass` | Glassmorphism backdrop container |
| `AppCard` | Generic card wrapper |
| `AppMetricCard` | Metric display (icon + value + label) |
| `AppTrendCard` | Trend display with up/down indicator |
| `AppProgressCard` | Progress bar card |
| `AppInsightCard` | Insight/info card with accent |
| `AppCountdownCard` | Festival countdown display |
| `AppStatusChip` | Status badge (success/warning/error/info/accent/neutral) |
| `AppButton` | Press-scale animated buttons (filled/outlined/text/tonal) |
| `AppSectionHeader` | Section title with optional subtitle + trailing |
| `AppPageHeader` | Greeting + festival name + actions row |
| `AppPageActions` | Action icon buttons row |
| `AppEmptyState` | Centered illustration + title + subtitle + action |
| `AppSkeleton` / `AppSkeletonList` | Shimmer loading placeholders |
| `AppStagger` | Staggered fade+slide animation for lists |
| `AppNotificationTile` | Notification list item (76px Sankalpa card) |
| `AppNotificationBanner` | In-app slide-down glass banner |
| `AppBellIcon` | Floating bell with animated unread badge |
| `AppAvatarBadge` | Avatar with status dot |
| `AppActionTile` | Tappable action row |
| `AnimatedBottomNav` | Floating glass bottom navigation |
| `AppScaffold` | App shell (nav + banner + content) |
| `AppPageScaffold` | Page wrapper with header + FAB |
| `AppGreetingSection` | Greeting + festival name + date |
| `ConfirmDialog` | Confirmation modal |
| `AppQrSheet` | QR image bottom sheet |
| `AdjustCollectionSheet` | Adjust collection bottom sheet |
| `AmountText` | Formatted amount display |
| `PageTransition` | Route page builder helper |

---

## 9. Notification Architecture

### Flow

```
User action on page
  ↓
ActivityService.record*() (in service layer)
  ↓
├─ FirestoreService.addActivity() → activities collection
└─ NotificationFactory.*() → AppNotification
    ↓
  NotificationService.createNotification()
    ↓
  NotificationRepository.createNotification()
    ↓
  notifications collection (Firestore)
    ↓
  ├─ Cloud Function (sendNotificationPush) → FCM → devices
  └─ Stream on clients → notification center + banner + badge update
```

### Rules

- **Never call `NotificationFactory` from a widget.** Call it from `ActivityService`.
- **Never call `NotificationService.createNotification` from a widget.** Call `ActivityService` methods instead.
- **Never bypass `ActivityService`** — Notifications must always be paired with an activity record.
- **Never send FCM from the client.** The Cloud Function is the sole sender.
- **Never read `device_tokens` collection from the client** except through `PushNotificationService`.
- **Never modify notification documents from the client** except for marking as read/archived, which goes through `NotificationRepository`.

### File Responsibilities

| File | Responsibility |
|---|---|
| `activity_service.dart` | Records activity doc + creates notification via `NotificationFactory` + `NotificationService` |
| `notification_factory.dart` | Static methods to construct typed `AppNotification` instances |
| `notification_messages.dart` | String templates for all notification titles/bodies |
| `notification_repository.dart` | Firestore CRUD for notifications + device tokens + preferences |
| `notification_service.dart` | Orchestration (create, delete, mark as read, archive) |
| `notification_navigator.dart` | Resolves notification `entityType`/`entityId` → GoRouter path |
| `push_notification_service.dart` | FCM token registration, foreground/background message listening, initial tap handling |
| `notification_banner.dart` | In-app slide-down banner UI + queuing |
| `notification_center_page.dart` | Full notification list with filtering, archive toggle |
| `app_notification_tile.dart` | Compact Sankalpa notification card |
| `app_bell_icon.dart` | Bell icon + animated unread badge |
| `functions/src/index.ts` | Cloud Function: sends FCM multicast on `notifications` doc creation |

---

## 10. Coding Standards

### Widget Structure

- Prefer `ConsumerWidget` / `ConsumerStatefulWidget` over raw `StatelessWidget`/`StatefulWidget` when Riverpod is needed.
- Keep widgets small. Extract reusable parts into private methods or separate widget classes.
- Use `const` constructors everywhere.
- No `print()` — use `debugPrint('[DOMAIN] ...')` for temporary debug output.
- No unused imports.
- Named parameters > positional. Use `required` where appropriate.

### Naming

- Files: `snake_case.dart` (e.g. `app_notification_tile.dart`).
- Classes: `PascalCase` (e.g. `AppNotificationTile`).
- Variables/methods: `camelCase`.
- Private members: `_` prefix.
- Providers: `camelCaseProvider` suffix (e.g. `targetsStreamProvider`).

### Null Safety

- Use `?` for nullable types.
- Use `late` only when guaranteed initialization (controller in initState, ref.watch in build).
- Prefer `valueOrNull` over `!` for nullable async values.
- Always cast Firestore map values explicitly (`as String?`, `as int?`, etc.).

### File Size

Keep files under 400 lines. Extract helpers into separate files when a single file exceeds this.

### Avoid

- `BuildContext` across async gaps (use `mounted` check).
- Dynamic `as` casts (prefer `as String?` with null checks).
- Magic strings/numbers (use `AppConstants`, `AppColors`, etc.).
- Importing from `features/` into `core/` (core is independent of features).
- Circular dependencies between core services.

---

## 11. Performance

- Use `const` constructors for all widgets that don't change.
- Prefer implicit animation widgets (`AnimatedContainer`, `AnimatedScale`, `AnimatedOpacity`) over `AnimationController` where possible.
- Avoid `setState` in animation listeners — use `AnimatedBuilder` or implicit widgets.
- Avoid expensive operations in `build` methods.
- Keep Firestore queries filtered by `festivalId` and indexed.
- Limit stream results with `.limit(N)` where full dataset isn't needed.
- Use `ref.watch` selectively — prefer granular providers over watching a large object.
- For lists, avoid recreating widgets unnecessarily (stable keys).

---

## 12. Testing Checklist

Before completing any task, run the following:

```bash
flutter analyze
```

1. Fix all introduced issues (warnings, errors, info items).
2. Ensure the project compiles without errors.
3. Verify navigation works (routes, back button, bottom nav tabs).
4. Verify CRUD flows (create → appears in list → update → delete → disappears).
5. Verify Firestore integration if modified (data persists, streams update).
6. Verify the existing notification flow still works if notification code was touched.

---

## 13. Git Workflow

- Commit at logical checkpoints (e.g., "feat: add expense form validation").
- Use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`.
- Write meaningful commit messages that explain *what* and *why*.
- Never mix unrelated changes in one commit.
- Before committing: run `flutter analyze` and ensure zero new issues.
- After committing: push to the current feature branch.

---

## 14. AI Working Rules

### Before Writing Code

1. Read existing files to understand the patterns (not just names — read implementations).
2. Check `shared/widgets/` for reusable components before building new ones.
3. Check `core/services/` and `core/providers/` for existing services/providers.
4. Determine if the task requires a new model, service, provider, or just a UI change.
5. If the task is large (multiple features or screens), divide it into phases.

### During Implementation

1. **Preserve existing architecture.** Do not refactor unrelated code.
2. **Reuse existing patterns.** Every new file must look like it was written by the same author.
3. **Do not invent new architecture.** Stick to the established flow: Widget → Provider → Service → Repository → Firestore.
4. **Do not skip requested features.** If the spec asks for validation, add it. If it asks for error handling, add it.
5. **Finish completely.** Do not leave stubs, placeholders, or TODOs in committed code.
6. **Preserve backwards compatibility.** Never break existing widget APIs or provider signatures.
7. **Write all code** — do not skip file creation, imports, or route registration.

### After Implementation

1. Run `flutter analyze`.
2. Fix every issue that was introduced.
3. Verify the app compiles.
4. Verify the changed screens render correctly.
5. Commit with a clear message.

### Phasing Large Tasks

If a task requires building an entire new feature:

- **Phase 1:** Model + Service + Repository (data layer)
- **Phase 2:** Providers (state layer)
- **Phase 3:** Routes + pages (UI layer)
- Complete each phase fully before starting the next. Do not leave the project in a broken state between phases.
