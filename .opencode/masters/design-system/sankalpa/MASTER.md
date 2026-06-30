# Design System Master File

> **LOGIC:** When building a specific page, first check `design-system/pages/[page-name].md`.
> If that file exists, its rules **override** this Master file.
> If not, strictly follow the rules below.

---

**Project:** Sankalpa
**Generated:** 2026-06-28
**Category:** Festival Management / Analytics Dashboard

---

## Global Rules

### Color Palette

| Role | Hex | Dart Constant |
|------|-----|--------------|
| Primary | `#0F6B3C` | `AppColors.primary` |
| Accent | `#C8A43E` | `AppColors.accent` |
| Success | `#22C55E` | `AppColors.success` |
| Warning | `#E8A838` | `AppColors.warning` |
| Error | `#DC2626` | `AppColors.error` |
| Info | `#3686D6` | `AppColors.info` |
| Surface | `#F4F4F0` | `AppColors.surface` |
| Card | `#FFFFFF` | `AppColors.card` |
| Charcoal | `#2D2D2D` | `AppColors.charcoal` |
| Outline | `#E2E2E0` | `AppColors.outline` |

**Notes:** Light theme with green primary + gold accent. Semantic colors have background tints (primaryBg, successBg, etc.). WarmGray scale for secondary text. Source: `lib/core/design/app_colors.dart`.

### Typography

- **Font:** Inter (via `google_fonts`)
- **7 tiers:** display (36px), headline (24-18px), title (16-13px), body (15-13px), label (12-10px)
- **Source:** `lib/core/design/app_typography.dart` — use `theme.textTheme.titleSmall` etc.

### Spacing

| Token | Value | Dart Constant |
|-------|-------|--------------|
| `xs` | `4px` | `AppSpacing.xs` |
| `sm` | `8px` | `AppSpacing.sm` |
| `md` | `12px` | `AppSpacing.md` |
| `lg` | `16px` | `AppSpacing.lg` |
| `xl` | `20px` | `AppSpacing.xl` |
| `xxl` | `24px` | `AppSpacing.xxl` |
| `xxxl` | `32px` | `AppSpacing.xxxl` |
| `xxxxl` | `40px` | `AppSpacing.xxxxl` |

**Source:** `lib/core/design/app_spacing.dart`

### Border Radius

| Tier | Value | Dart Shortcut |
|------|-------|--------------|
| Small | `8px` | `AppRadius.smallBorder` |
| Medium | `12px` | `AppRadius.mediumBorder` |
| Large | `16px` | `AppRadius.largeBorder` |
| Hero | `24px` | `AppRadius.heroBorder` |
| Full | `999px` | `AppRadius.full` |

**Source:** `lib/core/design/app_radius.dart`

### Shadows

| Tier | Value | Dart Constant |
|------|-------|--------------|
| Subtle | `0 2px 4px rgba(0,0,0,0.04)` | `AppShadows.subtle` |
| Soft | `0 4px 12px rgba(0,0,0,0.06)` | `AppShadows.soft` |
| Elevated | `0 8px 24px rgba(0,0,0,0.10)` | `AppShadows.elevated` |
| Card | `0 2px 8px rgba(0,0,0,0.06)` | `AppShadows.card` |

**Source:** `lib/core/design/app_shadows.dart`

### Glassmorphism

| Property | Value |
|----------|-------|
| Sigma | 14 |
| Opacity | 0.94 |
| Tint | White |
| Widget | `SankalpaGlass` in `lib/shared/widgets/sankalpa_glass.dart` |

**Usage:** Nav bar, bell badge, notification banner only.

### Animation

| Property | Value |
|----------|-------|
| Duration | 250-300ms |
| Curve | `easeOutCubic` |
| Preference | Implicit `Animated*` widgets over `AnimationController` |

---

## Component Specs

### Cards
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: AppRadius.largeBorder,
    border: Border.all(color: AppColors.outline),
    boxShadow: AppShadows.subtle,
  ),
)
```
**Available widgets:** `AppCard`, `AppMetricCard`, `AppTrendCard`, `AppProgressCard`, `AppInsightCard`, `AppCountdownCard`

### Notification Tiles
- 76px fixed height
- Sankalpa card with `AppRadius.largeBorder`
- 4px semantic left accent bar
- 32px category icon
- Typography: `titleSmall` + `bodySmall` + `labelMedium` timestamp
- Shadow: `AppShadows.subtle`

### Bottom Navigation
- `SankalpaGlass` container (sigma 14, opacity 0.94)
- 32dp hero radius, 16dp horizontal + bottom margins
- Active tab: `AppColors.primaryBg` pill + `AnimatedScale` 1.18
- Inactive tab: `AppColors.warmGray500` at 55% opacity
- `AnimatedBottomNav` in `lib/shared/widgets/animated_bottom_nav.dart`

### Bell Icon
- `SankalpaGlass` wrapper
- Glass badge with error tint
- 600ms easeInOut pulse animation
- `AppBellIcon` in `lib/shared/widgets/app_bell_icon.dart`

### Buttons
- Use `AppButton` from `lib/shared/widgets/app_button.dart`
- Types: filled, outlined, text, tonal
- Press-scale animation
- No raw `ElevatedButton`/`OutlinedButton`

### Status Chips
- Use `AppStatusChip` from `lib/shared/widgets/app_status_chip.dart`
- Variants: success, warning, error, info, accent, neutral
- Typography: `labelLarge` (12px w600)

---

## Style Guidelines

**Style:** Data-Dense Dashboard with Warm Indian Aesthetics

**Keywords:** Festival management, sponsorship tracking, daily collections, expense logging, progress cards, KPI metrics, community dashboard, follow-up scheduling

**Key Effects:** Card hover lift, staggered list animations (AppStagger), smooth filter transitions, glass blur for overlays, progress bars with animated fills, countdown timer

---

## Page Patterns

### Dashboard Page
- Greeting + festival name + countdown card at top
- 2-column metric grid (total targets, collected, expenses, balance)
- Progress card (target achievement)
- Recent activity feed
- Insight cards for trends
- Responsive: single column below 900px

### Notification Center
- `FadeTransition` entry animation
- Category filter bar with animated `_FilterChip`
- Archive toggle
- List of `AppNotificationTile` with swipe-to-dismiss
- Empty state with `AppEmptyState`
- Pagination with 20 items per page

### Collection/Expense Lists
- `AppPageHeader` + `AppSectionHeader`
- Skeleton loading via `AppSkeletonList`
- Pull-to-refresh
- FAB for create

---

## Anti-Patterns (Do NOT Use)

- ❌ `FirebaseFirestore.instance` in widgets/providers — use repositories
- ❌ `ChangeNotifierProvider` — use Riverpod patterns
- ❌ Business logic in widgets — belongs in services
- ❌ `context.read` in `build` — use `ref.watch`
- ❌ Random colors/spacing/radius — use AppColors/AppSpacing/AppRadius
- ❌ `AnimationController` for simple state changes — use implicit widgets
- ❌ `print()` — use `debugPrint('[DOMAIN] ...')`
- ❌ Emojis as icons — use Material icons
- ❌ Dynamic `as` casts — prefer `as String?` with null checks
- ❌ Magic strings/numbers — use `AppConstants`

---

## Pre-Delivery Checklist

Before delivering any UI code, verify:

- [ ] `flutter analyze` passes with zero new issues
- [ ] All colors from `AppColors`, all spacing from `AppSpacing`
- [ ] No raw Container decorations — use existing widgets where possible
- [ ] `const` constructors everywhere possible
- [ ] Touch targets >= 36x36dp
- [ ] Proper `SafeArea` handling
- [ ] Loading states use `AppSkeleton` / `AppSkeletonList`
- [ ] Empty states use `AppEmptyState`
- [ ] Error states show retry button
- [ ] Typography uses theme text styles (not raw `TextStyle`)
