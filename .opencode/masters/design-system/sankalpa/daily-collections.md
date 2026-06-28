# Daily Collections Page

> Covers the daily collections list and form pages.

---

## Daily Collection List Page

### Layout Hierarchy

```
AppPageScaffold (title: "Daily Collections", FAB for add)
└── ListView (padding bottom: 72)
    ├── Summary Metrics (2x2 grid)
    │   ├── Today's Collection (primary)
    │   ├── Entries (info)
    │   ├── Average (warning)
    │   └── Largest (success)
    ├── Quick Record Card (admin only)
    │   ├── Header: "Record Collection"
    │   ├── Amount TextField + preset chips (₹1,000/2,000/5,000/10,000)
    │   └── Save FilledButton
    ├── Section: "Today"
    │   └── DailyCollectionTile list
    ├── Section: "Yesterday"
    │   └── DailyCollectionTile list
    ├── Section: "Earlier"
    │   └── DailyCollectionTile list
    └── Empty State
```

### Summary Metrics
- 2x2 `Wrap` grid via `AppMetricCard`
- Today's Collection (`primary`), Entries (`info`), Average (`warning`), Largest (`success`)

### Quick Record Card (Inline, Admin Only)
| Property | Value |
|----------|-------|
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline border |
| Padding | `EdgeInsets.all(16)` |
| Header icon | `Icons.add_circle_rounded` in `primaryBg` container |
| Header title | `titleSmall`, `AppColors.charcoal`, `w600` |
| Amount field | `prefixText: "₹ "`, `filled: true`, `fillColor: warmGray50`, `AppRadius.mediumBorder` |
| Preset chips | `AnimatedContainer` (200ms), `AppRadius.mediumBorder`, border = outline (default) / `primary.withAlpha(0.3)` (selected) |
| Chip typography | `labelLarge`, `w600`, `warmGray500` / `primary` (selected) |
| Save button | `FilledButton.icon`, spinner when saving, `padding: vertical 14` |

### Section Headers
| Property | Value |
|----------|-------|
| Widget | `AppSectionHeader` |
| Padding | `EdgeInsets.fromLTRB(16, sm, 16, xs)` — 8px bottom padding to tiles |
| Yesterday/Earlier | Extra `top padding: md(12)` for visual separation |

### Daily Collection Tile
| Property | Value |
|----------|-------|
| Horizontal margin | `EdgeInsets.symmetric(horizontal: 16, vertical: 4)` |
| Card | `AppColors.card`, `borderRadius: 12`, outline border |
| Inner padding | `EdgeInsets.all(12)` |
| Icon container | 40x40, `primaryBg`, `borderRadius: 10` |
| Icon | `Icons.today_rounded` (today) / `Icons.calendar_month_rounded` (other), `primary`, 20px |
| Date | `bodyMedium`, `w600`, `charcoal` |
| Note | `bodySmall`, `warmGray500`, `maxLines: 1` |
| Amount | `titleMedium`, `w700`, `charcoal` |
| Menu | `PopupMenuButton` (Edit + Delete), visible for admin via `canManageExpenses` |

### Empty State
- `account_balance_wallet_rounded` icon
- "No collections recorded yet"
- "Use the form above to record your first collection"

---

## Daily Collection Form Page

### Layout
- Standard `Scaffold` with `AppBar`
- Admin-only access (redirects non-admin)
- `Form` with validation

### Fields
| Field | Validation |
|-------|-----------|
| Amount | Required, must be > 0 |
| Note | Optional, `maxLines: 3` |
| Date | Required, date picker (2020-today), `InputDecorator` with calendar icon |

### Save Button
- `FilledButton.icon`, spinner when saving
- Labels: "Add Collection" / "Update Collection"

---

## Do's and Don'ts

**Do:**
- Enable inline quick record for admin on list page
- Group by date buckets (Today / Yesterday / Earlier)
- Provide preset amount chips for speed
- Use `AppSectionHeader` for date group labels

**Don't:**
- Allow non-admin create/edit/delete
- Show empty skeleton when data exists
- Hardcode date bucket logic — use computed day boundaries
