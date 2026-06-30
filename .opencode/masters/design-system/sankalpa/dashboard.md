# Dashboard Page

> Page-level override for the main Dashboard screen.

---

## Layout Hierarchy

```
SafeArea
└── FadeTransition (500ms entry)
    └── RefreshIndicator
        └── SingleChildScrollView
            ├── AppPageHeader (greeting + festival name + actions)
            ├── CompactCountdown (optional, if festival date set)
            ├── FestivalMission (hero card: collected total + ring + progress bar)
            ├── QuickActions (2x2 action grid + QR strip)
            ├── KpiGrid (2x2 metric cards: today, pending, expenses, visits)
            ├── CollectionTrend (14-day line chart)
            └── ActivityTimeline (grouped feed, top 5 items)
```

### Responsive Breakpoint
- **Narrow** (< 900px): Single column, sequential sections
- **Wide** (>= 900px): Side-by-side layouts (FestivalMission + QuickActions, KpiGrid + CollectionTrend)

### Padding
- Narrow: `EdgeInsets.fromLTRB(16, 20, 16, 32)`
- Wide: `EdgeInsets.fromLTRB(32, 20, 32, 32)`

---

## Section Details

### Festival Mission (Hero Card)
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline border |
| Padding | `EdgeInsets.all(AppSpacing.lg)` — 16px |
| Sub-header icon | `Icons.flag_rounded` in `AppColors.primaryBg` container |
| Sub-header label | `labelLarge`, `AppColors.warmGray500`, `letterSpacing: 0.3` |
| Collected amount | `displayLarge`, `AppColors.charcoal`, `w800`, `letterSpacing: -1.5` |
| Goal text | `bodyMedium`, `AppColors.warmGray400` |
| Ring | Custom painter, `size: 64`, `stroke: 5`, `AppColors.primary` fill, `700ms easeOut` animation |
| Progress bar | `TweenAnimationBuilder(700ms, easeOut)`, `minHeight: 10`, `AppColors.warmGray200` track |
| Percent badge | `primaryBg` background, `labelMedium`, `AppColors.primary`, `w700` |
| Remaining text | `labelMedium`, `AppColors.warmGray400` |
| Footer metrics | 3-column: Pending count / Expenses / Balance, separated by vertical `Divider` (1px, `AppColors.outline`) |

### Quick Actions
| Property | Value |
|----------|-------|
| Section label | `labelLarge`, `AppColors.warmGray500` |
| Grid | 2-column `Wrap` with `spacing: sm(8)` `runSpacing: sm(8)` |
| Action tile | 72px height, `AppColors.card`, `AppRadius.largeBorder`, outline border |
| Icon container | 34x34, `color.withAlpha(0.1)` bg, `AppRadius.mediumBorder` |
| Icon | 18px, semantic color |
| Label | `labelLarge`, `AppColors.charcoal` |
| Actions | Sponsor (primary), Collection (success), Visit (warning), Expense (error) |

### QR Strip
| Property | Value |
|----------|-------|
| Height | 56px |
| Icon zone | 48x48, `primaryBg`, `AppRadius.mediumBorder`, 4px margin |
| Icon | `Icons.qr_code_rounded`, 22px, `AppColors.primary` |
| Text | `titleSmall`, `AppColors.charcoal`, `w600` |
| Chevron | `chevron_right_rounded`, 18px, `warmGray400` |

### KPI Grid
| Property | Value |
|----------|-------|
| Layout | 2-column `Wrap`, `spacing: sm(8)` `runSpacing: sm(8)` |
| Card | `AppCard` spec, padding `AppSpacing.sm(8)` |
| Icon container | `color.withAlpha(0.1)` bg, `AppRadius.mediumBorder`, padding `xs(4)` |
| Icon | 14px |
| Value | `titleLarge`, `AppColors.charcoal`, `height: 1.0` |
| Label | `labelMedium`, `AppColors.warmGray500` |
| Trend | `labelSmall`, `AppColors.warmGray400`, `height: 1.2` |
| Cards | Today's Collection (success), Pending Sponsors (warning), Expenses (error), Pending Visits (primary) |

### Collection Trend (14-day Chart)
| Property | Value |
|----------|-------|
| Card padding | `EdgeInsets.all(AppSpacing.xl)` — 20px |
| Title | `titleSmall`, `AppColors.warmGray500` |
| Period label | "14 days", `labelLarge`, `AppColors.warmGray400` |
| Chart height | 140px |
| Library | `fl_chart` `LineChart` |
| Line color | `AppColors.primary`, `barWidth: 2`, curved |
| Gradient fill | `primary.withAlpha(0.12)` to `primary.withAlpha(0.0)` |
| Grid | `drawVerticalLine: false`, `FlLine(color: AppColors.outline)` |
| Tooltip | White text, `w600`, `fontSize: 11` |
| Total label | `titleLarge`, `AppColors.charcoal` + "total in 14 days" in `bodySmall`, `warmGray400` |

### Activity Timeline
| Property | Value |
|----------|-------|
| Card padding | `EdgeInsets.all(AppSpacing.md)` — 12px |
| Header | "Activity Feed", `fontSize: 12`, `w600`, `warmGray500` |
| Grouping | Today / Yesterday / Date (e.g. "14 Jun") |
| Group label | `labelLarge`, `AppColors.warmGray400`, `letterSpacing: 0.5` |
| Icon container | 28x28, `color.withAlpha(0.1)` bg, `AppRadius.mediumBorder` |
| Icon | 14px, semantic per activity type |
| Description | `bodySmall`, `AppColors.charcoal`, `maxLines: 1`, ellipsis |
| Timestamp | `labelMedium`, `AppColors.warmGray400` |
| Max items | 5 |
| Tappable | Navigates to relevant entity if `recordId` + `entityType` present |

### Activity Type Colors
| Type | Color |
|------|-------|
| `collection_recorded` | `AppColors.success` |
| `collection_corrected` | `AppColors.warning` |
| `expense_added` | `AppColors.error` |
| `followup_added` | `AppColors.warning` |
| `followup_completed` | `AppColors.success` |
| `followup_undo` | `AppColors.warmGray500` |
| `sponsor_added` | `AppColors.primary` |
| `sponsor_updated` | `AppColors.info` |
| `festival_updated` | `AppColors.warmGray500` |
| `qr_updated` | `AppColors.info` |

---

## States

### Loading
- `AppSkeletonList` inside `SafeArea`

### Error
- Centered column: `cloud_off_rounded` icon (48px, `error`), "Failed to load dashboard" (`titleLarge`, `charcoal`), subtitle (`bodyMedium`, `warmGray500`), Retry `FilledButton.icon`

### Empty (Chart)
- Animated skeleton bars: 10 bars varying height (20%-100%), shimmer via `AppColors.warmGray400.withAlpha(opacity)` cycling 0.04-0.10, 2s repeat reverse

---

## Interaction Rules

- Pull-to-refresh invalidates `dashboardProvider`, `activitiesStreamProvider`, `activeFollowUpsProvider`, `dailyChartProvider`
- Activity items navigate to detail/edit pages on tap
- Quick Actions push to /collections/add, /daily-collections/add, /followups/add, /expenses/add
- QR strip opens `AppQrSheet` bottom sheet
- Settings icon pushes /settings
- Festival card footer metrics use `_shortFmt` for large numbers (1K, 1L)
