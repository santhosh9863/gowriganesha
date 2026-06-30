# Sponsors Page

> Covers Sponsor (Target) list, detail, and form pages.

---

## Sponsor List Page

### Layout Hierarchy

```
AppPageScaffold (title: "Sponsors", FAB for add)
└── ListView (padding bottom: 72)
    ├── Summary Metrics (2x2 grid)
    │   ├── Total Sponsors (primary)
    │   ├── Achieved (success)
    │   ├── Active (warning)
    │   └── Sponsor Remaining (error)
    ├── Search Bar
    ├── Filter Chips (All / Active / Completed)
    ├── Empty State (no sponsors / no search matches)
    └── Sponsor Cards (wrapped in AppStagger)
```

### Summary Metrics
- 2x2 `Wrap` grid via `AppMetricCard`
- 4 cards: Total Sponsors (`primary`), Achieved (`success`), Active (`warning`), Sponsor Remaining (`error`)

### Search Bar
| Property | Value |
|----------|-------|
| Hint | "Search sponsors..." |
| Prefix | `Icons.search_rounded`, 20px |
| Clear button | `Icons.clear_rounded`, visible when query not empty |
| Fill | `AppColors.warmGray50` |
| Content padding | `EdgeInsets.symmetric(horizontal: 12, vertical: 12)` |
| Border radius | `AppRadius.medium` (12px) |
| Border | `BorderSide(color: AppColors.outline)` |
| Search fields | name, building, area (all lowercased) |

### Filter Chips
| Property | Value |
|----------|-------|
| Container | `AnimatedContainer`, 200ms duration |
| Padding | `EdgeInsets.symmetric(horizontal: 12, vertical: 6)` |
| Border radius | `AppRadius.full` (rounded pill) |
| Default | transparent bg, `AppColors.outline` border, `AppColors.warmGray500` text |
| Selected | `color.withAlpha(0.1)` bg, `color.withAlpha(0.3)` border, colored text |
| Typography | `labelLarge`, `w600` |
| Chips | All (warmGray500), Active (warning), Completed (success) |

### Staggered Animation
- `AppStagger` wraps each card
- 50ms delay between items
- Fade + slide (0.08 fractional offset) from bottom
- 300ms total controller duration

### Sponsor Card
| Property | Value |
|----------|-------|
| margin | `EdgeInsets.symmetric(horizontal: 16, vertical: 4)` |
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline border, `AppShadows.subtle` |
| Inner padding | `EdgeInsets.all(AppSpacing.md)` — 12px |
| Avatar | 36x36, `AppColors.primaryBg`, `AppRadius.mediumBorder`, centered initials text (`titleSmall`, `primary`, `w700`) |
| Name | `titleMedium`, `AppColors.charcoal`, `w600`, `maxLines: 1` |
| Location | `bodySmall`, `AppColors.warmGray400`, `maxLines: 1` |
| Status chip | `AppStatusChip` (Ready/Active/Achieved) |
| Menu | `PopupMenuButton` with Edit + Delete (admin only) |
| Progress bar | `minHeight: 4`, `AppColors.warmGray200` track, `AppColors.primary`/`AppColors.success` fill (complete) |
| Amount blocks | 3-column: Commitment (`warmGray500`), Raised (`primary`/`success`), To Reach (`warning`/`warmGray400`) |
| Quick actions | "Collect" button (primary filled) + "Visit" button (warning outlined) |
| Timestamp | `Icons.access_time_rounded` (12px) + `labelMedium`, `AppColors.warmGray400` |

### Empty States
- **No sponsors:** `people_outline_rounded` icon, "No sponsors yet", subtitle + FAB action
- **No search match:** `search_off_rounded` icon, "No sponsors match..."

---

## Sponsor Detail Page

### Layout Hierarchy

```
AppPageScaffold (showBack: true, title: sponsor name)
└── SingleChildScrollView (padding: 16)
    ├── Action Row (Add Visit, Edit, Delete icons)
    ├── Amount Summary Card (Commitment / Raised / To Reach)
    │   └── LinearProgressIndicator
    ├── Action Buttons (Record Contribution + Adjust Collection)
    ├── Contribution History List
    ├── Overdue Warning Banner (conditional)
    └── Visit History (active + completed followups)
```

### Amount Summary
- `AppCard` with `EdgeInsets.all(20px)` padding
- 3-column amount row: Commitment, Raised, To Reach
- Each column: `labelSmall` subtitle + `AmountText` in `titleSmall` bold
- Progress bar: `minHeight: 10`, `primaryContainer` track
- Below bar: "{raised} of {commitment} raised ({percent}%)"

### Contribution History
| Section | Detail |
|---------|--------|
| Header | `titleSmall`, `w600` + count badge (`bodySmall`, `onSurfaceVariant`) |
| Row icon | 34x34 container, 18px icon (payments/tune), semantic color |
| Note | `bodyMedium`, `w500`, `maxLines: 2` |
| Type badge | `labelSmall`, `w600`, colored bg |
| Timestamp | Relative time (`bodySmall`, `onSurfaceVariant`) |
| Amount | `titleSmall`, bold, colored (primary/correction=error) |
| Skeleton loading | 3 rows of `AppSkeleton` mimicking tile layout |

### Followup/Pending Visit Section
- Active + Completed followups grouped under "Visit History"
- Overdue warning: `error.withAlpha(15)` bg, `error.withAlpha(60)` border, warning icon + count text
- Each row: status icon (warning/schedule/check) + date + note + amount + status badge (Overdue/Pending/Collected)

### Quick Record Bottom Sheet
- Modal: `isScrollControlled: true`, `top: Radius.circular(AppRadius.bottomSheet)`
- Title: `headlineSmall`, `w600`
- Amount + Note fields
- Cancel + Save buttons (Save: `flex: 2`)

---

## Sponsor Form Page

### Layout
- Standard `Scaffold` with `AppBar`
- `SingleChildScrollView`, `EdgeInsets.all(16px)`
- `Form` with `GlobalKey<FormState>`

### Fields
| Field | Validation |
|-------|-----------|
| Name | Required, `TextCapitalization.words` |
| Commitment Amount | Required, must parse as positive int |
| Amount Collected | Required (create only), must parse as positive int |
| Notes | Optional, `maxLines: 3`, sentence case |

### Edit Mode
- Pre-fills all fields
- Shows "Total Collected" read-only banner with Adjust Collection button
- Redirects non-admin users to list

### Save Button
- `FilledButton.icon`, shows spinner when saving
- Label: "Add Sponsor" / "Update Sponsor"

---

## Do's and Don'ts

**Do:**
- Use `AppStagger` for list entry animations
- Show `AppStatusChip` for quick status reading
- Use `AppMetricCard` for summary metrics
- Enable Quick Actions (Collect + Visit) on each card
- Provide skeleton loading for contribution history

**Don't:**
- Mix `AppColors` with raw `colorScheme` — use Sankalpa tokens consistently
- Allow non-admin edit/delete access
- Use raw `CircularProgressIndicator` where `AppSkeleton` should be used
