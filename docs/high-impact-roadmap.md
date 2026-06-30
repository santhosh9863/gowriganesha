# High-Impact Roadmap — UI/UX Transformation

**Goal:** Make the app feel dramatically better, prioritized by user-noticeable impact.

Each item includes:
- **Effort**: estimated implementation time
- **Visual Impact**: how much the app's appearance improves (1-10)
- **UX Impact**: how much the workflow improves (1-10)
- **Risk**: chance of breaking existing functionality (1-10)
- **ROI Score**: (Visual + UX) / (Effort + Risk) — higher is better

---

## Ranked by ROI

### 1. Dashboard Typographic Hierarchy
Replace the flat card grid with a Stripe/Linear-inspired hierarchy: huge "Expected" metric at top, "Collected" below, "Balance" with green/red color coding. Merge hero+progress into one unified component.

- **Effort**: 4 hours
- **Visual Impact**: 10/10
- **UX Impact**: 9/10
- **Risk**: 2/10
- **ROI**: 3.17

### 2. Bottom Nav: Add Labels + Follow-ups as 5th Tab
Add text labels to bottom navigation items. Move Follow-ups into the ShellRoute as a 5th tab using StatefulShellRoute so the bottom nav persists.

- **Effort**: 4 hours
- **Visual Impact**: 8/10
- **UX Impact**: 9/10
- **Risk**: 4/10
- **ROI**: 2.83

### 3. Group Activity Feed by Date
Add "Today", "Yesterday", "This Week" section headers to the dashboard activity feed. Limit to 5 per group with "View more". Fix relative time format.

- **Effort**: 2 hours
- **Visual Impact**: 7/10
- **UX Impact**: 8/10
- **Risk**: 1/10
- **ROI**: 2.73

### 4. Reduce Sponsor Card Density (9 → 4-5 elements)
Show only: status (icon + text label + color strip), name, mini progress bar "₹X of ₹Y", quick action button. Move location/timestamp/full amounts to detail page.

- **Effort**: 3 hours
- **Visual Impact**: 9/10
- **UX Impact**: 7/10
- **Risk**: 3/10
- **ROI**: 2.67

### 5. Move Quick-Add Daily Collection from Inline to FAB + Bottom Sheet
The quick-add form currently takes 50% of the viewport. Move it to a FAB that opens a bottom sheet. Show the list as the primary view.

- **Effort**: 3 hours
- **Visual Impact**: 8/10
- **UX Impact**: 8/10
- **Risk**: 3/10
- **ROI**: 2.67

### 6. Add OVERDUE / DUE TODAY Badges to Follow-Up Cards
Small colored chips on follow-up cards showing urgency, not just color changes on icons.

- **Effort**: 1.5 hours
- **Visual Impact**: 7/10
- **UX Impact**: 8/10
- **Risk**: 1/10
- **ROI**: 2.50

### 7. Replace 3-Button Action Row with 1 Primary + Text Links
On sponsor detail page, show "Receive Amount" as the only prominent button. "Add Follow-Up" and "Edit" become icon buttons in the app bar.

- **Effort**: 2 hours
- **Visual Impact**: 8/10
- **UX Impact**: 6/10
- **Risk**: 2/10
- **ROI**: 2.33

### 8. Reduce Hero Animation to 400ms (Cold Start Only)
The 1200ms count-up animation plays every tab switch. Cut to 400ms and only on cold start.

- **Effort**: 0.5 hours
- **Visual Impact**: 4/10
- **UX Impact**: 7/10
- **Risk**: 1/10
- **ROI**: 2.20

### 9. Remove "All" Filter from Follow-Ups, Default to Active
Reduce cognitive load. Users want to see what needs to be done. "All" is redundant with "Active" + "Completed".

- **Effort**: 0.5 hours
- **Visual Impact**: 3/10
- **UX Impact**: 7/10
- **Risk**: 1/10
- **ROI**: 2.00

### 10. Collapse Search into App Bar (Sponsor List)
Use `showSearch` delegate pattern so search overlays content instead of pushing it down.

- **Effort**: 3 hours
- **Visual Impact**: 6/10
- **UX Impact**: 7/10
- **Risk**: 3/10
- **ROI**: 1.86

---

## Implementation Phases (in order)

| Order | Item | Phase | Est. Time |
|-------|------|-------|-----------|
| 1 | Dashboard Typographic Hierarchy | Dashboard | 4h |
| 2 | Group Activity Feed by Date | Dashboard | 2h |
| 3 | Reduce Hero Animation to 400ms | Dashboard | 0.5h |
| 4 | Bottom Nav Labels + Follow-ups Tab | Navigation | 4h |
| 5 | Reduce Sponsor Card Density | Sponsor List | 3h |
| 6 | Replace 3-Button Action Row | Sponsor Detail | 2h |
| 7 | OVERDUE / DUE TODAY Badges | Follow-ups | 1.5h |
| 8 | Remove "All" Filter | Follow-ups | 0.5h |
| 9 | Move Quick-Add to FAB + Bottom Sheet | Daily Collections | 3h |
| 10 | Collapse Search into App Bar | Sponsor List | 3h |

**Total estimated time: ~22 hours**

---

## Immediate Impact (Day 1)

Items 1, 2, 3 change the dashboard from a flat card grid to a professional financial dashboard. These three alone can be done in ~6.5 hours and will make the app feel like a completely different product.

**Starting with: Dashboard Transformation (Items 1-3)**
