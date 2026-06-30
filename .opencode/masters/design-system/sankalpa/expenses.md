# Expenses Page

> Covers the expenses list and form pages.

---

## Expense List Page

### Layout Hierarchy

```
AppPageScaffold (title: "Expenses", FAB for add)
└── ListView (padding bottom: 72)
    ├── Summary Metrics (2x2 grid)
    │   ├── Total Expenses (error)
    │   ├── Remaining Budget / Over Budget (success/error)
    │   ├── Largest Expense (warning)
    │   └── Expense Count (info)
    ├── Empty State (when no expenses)
    └── Grouped Sections (by "MMMM yyyy")
        ├── AppSectionHeader (month name + count + subtotal)
        └── ExpenseTile list
```

### Summary Metrics
- 2x2 `Wrap` grid via `AppMetricCard`
- Total Expenses (`error`), Remaining/Over Budget (`success`/`error`), Largest (`warning`), Count (`info`)
- Budget state: if `remaining < 0`, icon becomes `warning_amber_rounded`, color becomes error

### Grouping
- Grouped by month key: `DateFormat('MMMM yyyy')`
- Sorted reverse chronologically
- Section subtitle: "{count} entries · ₹{subtotal}"

### Expense Tile
| Property | Value |
|----------|-------|
| Horizontal margin | `EdgeInsets.symmetric(horizontal: 16, vertical: 4)` |
| Card | `AppColors.card`, `AppRadius.largeBorder`, outline border |
| Inner padding | `EdgeInsets.all(12)` |
| Icon container | 40x40, `errorBg`, `AppRadius.mediumBorder` |
| Icon | `Icons.receipt_rounded`, `AppColors.error`, 20px |
| Note | `bodyMedium`, `AppColors.charcoal`, `maxLines: 2` |
| Date row | Calendar icon (12px) + date + "·" + relative time, all `labelSmall`, `warmGray400` |
| Amount | `titleLarge`, `w700`, `charcoal` |
| Menu | `PopupMenuButton` (Edit + Delete), visible via `canManageExpenses` |

### Empty State
- Admin: icon + "No expenses recorded" + "Tap + to record" + FAB action button
- Non-admin: same icon + title, no action button, subtitle: "No expenses have been recorded yet."

---

## Expense Form Page

### Layout
- Standard `Scaffold` with `AppBar`
- Admin-only access (redirects non-admin)
- `Form` with validation

### Fields
| Field | Validation |
|-------|-----------|
| Amount | Required, must be > 0 |
| Note | Required-like, hint "What was this expense for?", `maxLines: 3` |
| Date | Required, date picker (2020-today), `InputDecorator` with calendar + dropdown icons |

### Save Button
- `FilledButton.icon`, spinner when saving
- Labels: "Add Expense" / "Update Expense"

---

## Interaction Rules

- Delete: `showConfirmDialog` with "Delete expense of ₹{amount}? This cannot be undone."
- Delete calls `firestoreService.deleteExpense(id)`
- On error: SnackBar "Failed to delete expense. Please try again."

---

## Do's and Don'ts

**Do:**
- Group expenses by month for readability
- Show budget context (remaining/overspent) at list top
- Use error semantic color for all expense icons

**Don't:**
- Allow non-admin create/edit/delete
- Show raw timestamp — use date + relative time
- Forget to invalidate streams after CRUD
