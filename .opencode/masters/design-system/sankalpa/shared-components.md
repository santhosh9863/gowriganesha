# Shared Components

> Catalog of all reusable UI building blocks in `lib/shared/widgets/`.

---

## SankalpaGlass

| File | `lib/shared/widgets/sankalpa_glass.dart` |
|------|-----------------------------------------|
| Purpose | BackdropFilter glassmorphism container |
| Params | `sigma` (default 10), `opacity` (default 0.85), `borderRadius`, `borderColor`, `tintColor`, `padding`, `boxShadow` |
| Painting | `ClipRRect` → `BackdropFilter(ImageFilter.blur)` → colored overlay with opacity |
| Usage | Bottom nav (sigma: 14, opacity: 0.90, layered shadows), bell badge (sigma: 8, opacity: 0.92), notification banner (sigma: 12, opacity: 0.88) |

---

## AppCard

| File | `lib/shared/widgets/app_card.dart` |
|------|-----------------------------------|
| Purpose | Generic card wrapper using Material `Card` widget |
| Params | `child`, `padding`, `margin`, `onTap`, `color` |
| Base | `Card(margin: EdgeInsets.zero, color: ...)` |
| Design code | Prefer the explicit `Container` pattern in feature code over `AppCard` |

---

## AppMetricCard

| File | `lib/shared/widgets/app_metric_card.dart` |
|------|------------------------------------------|
| Purpose | Compact metric display (icon + value + label) |
| Params | `label`, `value` (String), `icon`, `iconColor`, `iconBgColor`, `trend` (optional), `isTrendUp`, `onTap` |
| Card spec | `AppColors.card`, `AppRadius.largeBorder`, outline border, `AppShadows.subtle`, padding `sm(8)` |
| Icon container | 4px padding, `iconBgColor`, `AppRadius.mediumBorder` |
| Icon | 14px, `iconColor` |
| Value | `titleLarge`, `AppColors.charcoal` |
| Label | `labelMedium`, `AppColors.warmGray500` |
| Trend badge | Small pill: `successBg`/`errorBg`, `AppRadius.smallBorder`, trending icon + text in `success`/`error` |

---

## AppTrendCard

| File | `lib/shared/widgets/app_trend_card.dart` |
|------|-----------------------------------------|
| Purpose | Trend display with up/down indicator |
| Card spec | Same as AppMetricCard, padding `lg(16)` |
| Icon container | 4+2=6px padding, `accent.withAlpha(25)`, `AppRadius.mediumBorder` |
| Trend badge | `accent.withAlpha(20)`, `AppRadius.smallBorder` |
| Value | `headlineSmall`, `AppColors.charcoal` |

---

## AppProgressCard

| File | `lib/shared/widgets/app_progress_card.dart` |
|------|--------------------------------------------|
| Purpose | Card with progress bar |
| Card spec | Same as above, padding `lg(16)` |
| Progress bar | `LinearProgressIndicator`, `minHeight: 6`, full pill radius, `warmGray100` track |
| Value | Right-aligned below bar, `titleMedium`, `charcoal` |

---

## AppInsightCard

| File | `lib/shared/widgets/app_insight_card.dart` |
|------|-------------------------------------------|
| Purpose | Insight/info card with icon + title + description |
| Layout | Horizontal: icon container → text column → trailing |
| Title | `titleSmall`, `charcoal`, `w600` |
| Description | `bodySmall`, `warmGray500`, `height: 1.4` |

---

## AppCountdownCard

| File | `lib/shared/widgets/app_countdown_card.dart` |
|------|---------------------------------------------|
| Purpose | Festival countdown display |
| Layout | Horizontal: icon (40x40 container) → text column |
| Icon rules | Past: `check_circle_outline_rounded`, `warmGray400`; ≤13 days: `event_rounded`, `warning`; Otherwise: `calendar_month_rounded`, `primary` |
| Title | `result.title` in `titleSmall`, `charcoal`, `w600` |
| Message | `result.message` in `bodySmall`, `warmGray500` |
| Date | `result.formattedDate` in `labelSmall`, `warmGray400` |

---

## AppStatusChip

| File | `lib/shared/widgets/app_status_chip.dart` |
|------|------------------------------------------|
| Purpose | Status badge (pill) with color dot |
| Variants | `success`, `warning`, `error`, `info`, `accent`, `neutral` |
| Layout | Dot (6px circle, 5px from text) → optional icon (12px, 3px gap) → label |
| Typography | `labelLarge` (12px), `w600` |
| Padding | `EdgeInsets.symmetric(horizontal: sm(8), vertical: xs(4))` |
| Border radius | `AppRadius.full` (999px) |

### Variant Colors
| Variant | Background | Foreground | Dot |
|---------|-----------|------------|-----|
| success | `successBg` | `success` | `success` |
| warning | `warningBg` | `warning` | `warning` |
| error | `errorBg` | `error` | `error` |
| info | `infoBg` | `info` | `info` |
| accent | `accentBg` | `accent` | `accent` |
| neutral | `warmGray100` | `warmGray600` | `warmGray400` |

---

## AppButton

| File | `lib/shared/widgets/app_button.dart` |
|------|-------------------------------------|
| Purpose | Press-scale animated button wrappers |
| Variants | `filled()`, `outlined()`, `text()`, `filledIcon()`, `tonalIcon()` |
| Shape | `AppRadius.buttonBorder` |
| Press animation | Scale to 0.97x on pointer down, 100ms `easeInOut` |
| Implementation | `AnimationController` + `Listener(onPointerDown/Up/Cancel)` → `Transform.scale` |

---

## AppSectionHeader

| File | `lib/shared/widgets/app_section_header.dart` |
|------|---------------------------------------------|
| Purpose | Section title with optional subtitle + trailing widget |
| Title | `titleLarge` (16px), `AppColors.charcoal` |
| Subtitle | `bodySmall` (13px), `AppColors.warmGray500`, 2px gap |
| Layout | `Row(crossAxisAlignment: start)` with column for text + trailing |

---

## AppPageHeader

| File | `lib/shared/widgets/app_page_header.dart` |
|------|------------------------------------------|
| Purpose | Page header with greeting + festival name + action buttons |
| Layout | `Row` → `AppGreetingSection` (expanded) + `SizedBox(12px)` + `AppPageActions` |
| Props | `greeting`, `festivalName`, `date`, `onSettings`, `onAdd`, `onFilter`, `onSearch` |

---

## AppPageActions

| File | `lib/shared/widgets/app_page_actions.dart` |
|------|-------------------------------------------|

---

## AppScaffold

| File | `lib/shared/widgets/app_scaffold.dart` |
|------|---------------------------------------|
| Purpose | App shell wrapping `StatefulNavigationShell` + bottom nav + banner overlay |
| Children | Bottom nav: `AnimatedBottomNav`; Top overlay: `AppNotificationBanner` (positioned, absolute) |
| Notification listener | Watches `notificationsStreamProvider`, shows `AppNotificationBanner` on new items |

---

## AppPageScaffold

| File | `lib/shared/widgets/app_page_scaffold.dart` |
|------|--------------------------------------------|
| Purpose | Page wrapper with header + optional FAB |
| Layout | `Scaffold` → `SafeArea` → `Column(header + Expanded(body))` |
| Header | Back button + page title or `AppPageHeader` (greeting mode) |
| FAB | `primary` bg, white icon, 16px border radius, auto-hides when keyboard open |
| Responsive horizontal pad | `>900px: xxxl(32)` / `<=900px: lg(16)` |

---

## AppSkeleton / AppSkeletonCard / AppSkeletonList

| File | `lib/shared/widgets/app_skeleton.dart` |
|------|---------------------------------------|
| Purpose | Shimmer loading placeholders |
| Animation | Animated shimmer sweep via `LinearGradient` with 3 stops cycling 1.5s repeat |
| `AppSkeleton` | Single block: `width`, `height`, `borderRadius` |
| `AppSkeletonCard` | Card mock: row (80px bar + circle) + title bar + N content lines |
| `AppSkeletonList` | N `AppSkeletonCard` items in `ListView.builder`, default 6 |
| Colors | `colorScheme.surfaceContainerHighest` with alpha 100/200 sweep |

---

## AppEmptyState

| File | `lib/shared/widgets/app_empty_state.dart` |
|------|------------------------------------------|
| Purpose | Centered empty state with icon + text + optional action |
| Icon | 48px, `onSurface.withAlpha(60)` |
| Title | `titleMedium`, `onSurfaceVariant`, centered |
| Subtitle | `bodySmall`, `onSurface.withAlpha(128)`, centered, 4px gap |
| Action | Optional, placed below with `lg(16)` gap |

---

## AppStagger

| File | `lib/shared/widgets/app_stagger.dart` |
|------|--------------------------------------|
| Purpose | Staggered fade+slide animation for list items |
| Delay | `index * 50ms`, computed as `Interval(start, start+appear)` |
| Animation | `FadeTransition` + `SlideTransition(begin: Offset(0, 0.08))` |
| Controller | **External** — parent provides `AnimationController` (300ms typical) |
| Curve | `Curves.easeOut` for both fade and slide |

---

## AppBellIcon

| File | `lib/shared/widgets/app_bell_icon.dart` |
|------|-----------------------------------------|
| Purpose | Floating bell icon with animated unread badge |
| Glass | `SankalpaGlass(sigma: 8, opacity: 0.92, mediumBorder, outline border, card tint)` |
| Size | 48×48 |
| Icon | `notifications_rounded` (filled when unread) / `notifications_outlined`, 22px, `primary`/`warmGray500` |
| Badge | `SankalpaGlass(sigma: 6, opacity: 0.95, error tint)`, positioned `top: 4, right: 4` |
| Badge text | 10px, `w700`, white, "99+" overflow |
| Pulse | `AnimationController` 600ms easeInOut, scale 1.0↔1.12, repeat reverse when unread |
| Navigation | Pushes `/notifications` on tap |

---

## AppNotificationTile

| File | `lib/shared/widgets/app_notification_tile.dart` |
|------|------------------------------------------------|
| Purpose | Compact 76px Sankalpa notification card |
| Spec | See `notification-center.md` for full spec |
| Key props | `notification`, `currentUserId`, `onTap`, `onMarkAsRead`, `onArchive` |
| Swipe | `Dismissible` (horizontal): right→read (green), left→archive (warmGray500) |

---

## AppNotificationBanner

| File | `lib/shared/widgets/app_notification_banner.dart` |
|------|--------------------------------------------------|
| Purpose | In-app glass slide-down banner with queue |
| Spec | See `animations.md` for animation spec |
| Auto-dismiss | 5s timer |
| State | `InAppBannerNotifier` (StateNotifier), manages queue |

---

## ConfirmDialog

| File | `lib/shared/widgets/confirm_dialog.dart` |
|------|-----------------------------------------|
| Purpose | Standard confirmation modal |
| Params | title, message, confirmLabel, cancelLabel |
| Returns | `bool` via `showConfirmDialog(context, ...)` |

---

## AppQrSheet

| File | `lib/shared/widgets/app_qr_sheet.dart` |
|------|----------------------------------------|
| Purpose | QR code bottom sheet for payment display |

---

## AdjustCollectionSheet

| File | `lib/shared/widgets/adjust_collection_sheet.dart` |
|------|--------------------------------------------------|
| Purpose | Correction bottom sheet for adjusting collection amounts |

---

## AmountText

| File | `lib/shared/widgets/amount_text.dart` |
|------|---------------------------------------|
| Purpose | Formatted amount display with currency symbol |
| Uses | `fmtAmount()` from `shared/utils/amount_format.dart` |

---

## PageTransition

| File | `lib/shared/widgets/page_transitions.dart` |
|------|-------------------------------------------|
| Purpose | Route page builder helper for go_router, currently uses `NoTransitionPage` |
| Future | Reserved for `fadeSlide` transition |

---

## List Tiles (Feature-Level)

### SponsorCard (collection_tile.dart)
| Property | Value |
|----------|-------|
| Height | ~132px (calculated) |
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline, `AppShadows.subtle` |
| Margin | `EdgeInsets.symmetric(horizontal: 16, vertical: 4)` |
| Padding | `EdgeInsets.all(12)` |
| Quick action buttons | `AppRadius.mediumBorder`, filled or outlined tint |

### DailyCollectionTile
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `borderRadius: 12`, outline |
| Padding | `EdgeInsets.all(12)` |
| Icon | 40x40, `primaryBg`, `borderRadius: 10` |

### ExpenseTile
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline |
| Padding | `EdgeInsets.all(12)` |
| Icon | 40x40, `errorBg`, `AppRadius.mediumBorder` |

### FollowUpCard
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline |
| Left accent | 4px bar, semantic color |
| Padding | `EdgeInsets.all(12)` |
| Avatar | 36x36, `accent.withAlpha(0.1)`, initials |
| Action buttons | `color.withAlpha(0.08)` bg, `AppRadius.mediumBorder` |

---

## Filter/Tab Chips (Feature-Level)

### Collection Filter Chip (_FilterChip in collection_list_page.dart)
| State | Style |
|-------|-------|
| Default | transparent bg, `AppColors.outline` border, `warmGray500` text |
| Selected | `color.withAlpha(0.1)` bg, `color.withAlpha(0.3)` border, colored text |
| Border radius | `AppRadius.full` (pill) |
| Typography | `labelLarge`, `w600` |
| Animation | `AnimatedContainer`, 200ms |

### Follow-up Tab Chip (_TabChip in followup_list_page.dart)
Same as filter chip with added count badge (pill, `labelSmall(10px)`, `w600`).

### Daily Collection Amount Chip (_AmountChip)
Same as filter chip, shows `AppConstants.currencySymbol + fmtAmount(amount)`.

---

## Do's and Don'ts

**Do:**
- Always use `AppRadius` named shortcuts (`largeBorder`, `mediumBorder`, etc.)
- Always use `AppSpacing` named constants (`lg`, `md`, `sm`, etc.)
- Use `AppStatusChip` for all status badges — never build custom chips
- Use `AppSkeleton` / `AppSkeletonList` for all loading states

**Don't:**
- Create duplicate wrappers — check `shared/widgets/` first
- Use raw `EdgeInsets.all(8)` — use `AppSpacing.sm`
- Use raw `BorderRadius.circular(12)` — use `AppRadius.mediumBorder`
- Use raw `TextStyle` — use `theme.textTheme.*`
