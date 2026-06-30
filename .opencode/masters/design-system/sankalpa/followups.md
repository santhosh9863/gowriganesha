# Follow-ups / Visits Page

> Covers the follow-up (visit) list and form pages.

---

## Follow-up List Page

### Layout Hierarchy

```
AppPageScaffold (title: "Visits", FAB for add)
└── ListView (padding bottom: 72)
    ├── Summary Metrics (2x2 grid)
    │   ├── Overdue (error)
    │   ├── Due Today (warning)
    │   ├── Upcoming (warmGray500)
    │   └── Completed (success)
    ├── Tab Chips (Pending / Completed)
    ├── [Tab: Pending]
    │   ├── Overdue Section
    │   │   └── AppSectionHeader ("Overdue", count)
    │   │   └── FollowUpCard list
    │   ├── Today Section
    │   │   └── AppSectionHeader ("Today", count)
    │   │   └── FollowUpCard list
    │   └── Upcoming Section
    │       └── AppSectionHeader ("Upcoming", count)
    │       └── FollowUpCard list
    ├── [Tab: Completed]
    │   └── FollowUpCard list
    ├── Empty State (no visits)
    └── All Caught Up State (no pending)
```

### Summary Metrics
- 2x2 `Wrap` grid via `AppMetricCard`
- Overdue (`error`), Due Today (`warning`), Upcoming (`neutral` — `warmGray500/warmGray100`), Completed (`success`)

### Tab Chips
| Property | Value |
|----------|-------|
| Container | `AnimatedContainer`, 200ms duration |
| Padding | `EdgeInsets.symmetric(horizontal: 12, vertical: sm(8))` |
| Border radius | `AppRadius.medium` (12px) |
| Default | transparent bg, `AppColors.outline` border |
| Selected | `color.withAlpha(0.1)` bg, `color.withAlpha(0.3)` border |
| Typography | `labelLarge`, `w600` |
| Count badge | Small pill: selected = colored bg + white text, default = `warmGray200` + `warmGray500` |
| Tabs | Pending (warning), Completed (success) |

### FollowUp Card
| Property | Value |
|----------|-------|
| Horizontal margin | `EdgeInsets.symmetric(horizontal: 16, vertical: 4)` |
| Container | `AppColors.card`, `AppRadius.largeBorder`, outline border |
| Left accent | 4px bar, semantic color, `topLeft/bottomLeft: Radius.circular(large: 16)` |
| Avatar | 36x36, `accentColor.withAlpha(0.1)` bg, centered initials text (`titleSmall`, accent, `w700`) |
| Sponsor name | `titleSmall`, `AppColors.charcoal`, `w600`, `maxLines: 1` |
| Date row | Calendar icon (12px, `warmGray400`) + relative date, `labelMedium`, `warmGray400` |
| Status chip | `AppStatusChip` (Completed/Overdue/Due Today/Upcoming) |
| Note preview | `bodySmall`, `AppColors.warmGray500`, `maxLines: 2` |
| Amount | `titleMedium`, `w700`, `charcoal` (if present) |
| Action buttons | "Collect" (check_circle, accent) + "Edit" (edit, warmGray500) + "Delete" (delete, warmGray400) |
| Action button style | `color.withAlpha(0.08)` bg, `AppRadius.mediumBorder`, `labelMedium` text |

### Status → Accent Color Mapping
| Status | Color | Chip Variant |
|--------|-------|-------------|
| Completed | `AppColors.success` | `success` |
| Overdue | `AppColors.error` | `error` |
| Due Today | `AppColors.warning` | `warning` |
| Upcoming | `AppColors.warmGray500` | `neutral` |

### Mark as Collected Flow
1. Confirmation dialog: "Mark Collection Completed?" → Cancel / Collected
2. On confirm: update status to "completed", record `followup_completed` activity
3. SnackBar: "Visit marked as completed" with UNDO action (3s duration)
4. Undo restores status to "active", records `followup_undo` activity

### Empty States
- **No visits at all:** `follow_the_signs_rounded`, "No visits yet", "Tap + to create", with action button
- **All caught up:** `check_circle_outline_rounded`, "All caught up!", "No pending visits"

---

## Follow-up Form Page

### Layout
- Standard `Scaffold` with `AppBar`
- Admin-only access (redirects non-admin)
- `Form` with validation

### Fields
| Field | Validation |
|-------|-----------|
| Sponsor Name | Required (hidden if `sponsorId` query param provided), `TextCapitalization.words` |
| Visit Date | Required, date picker (today to +365 days) |
| Amount | Optional, number input |
| Note | Optional, hint "What was discussed?", `maxLines: 3`, sentence case |

### Query Parameters
- `sponsorId` + `sponsorName`: Pre-fills sponsor name, hides name field, links visit to sponsor
- `targetName`: Alternative param for sponsor name

### Save Button
- `FilledButton.icon`, spinner when saving
- Labels: "Add Visit" / "Update Visit"

---

## Do's and Don'ts

**Do:**
- Use 4px left accent bar on cards for status signaling
- Separate Pending (Overdue/Today/Upcoming) from Completed
- Provide UNDO on mark-as-completed
- Pre-fill sponsor info from query params

**Don't:**
- Allow non-admin create/edit/delete
- Show completed items in pending tab
- Forget to sort: overdue by date ASC, upcoming by date ASC, completed by date DESC
