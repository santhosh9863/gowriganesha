# UI Overhaul Changelog

## Phase 0 — Baseline

- Branch: `feature/ui-overhaul`
- Base branch: `stable/pre-ui-overhaul`
- `flutter analyze`: **No issues found**
- `flutter test`: 1 test failing (pre-existing — missing ProviderScope wrapper in `widget_test.dart`, not related to UI changes)

### Baseline commit
`4ebf6dc` — stable: production-ready before ui overhaul

---

## Phase 1 — Design System Foundation

### 1.1 Typography System
- Added `google_fonts` package
- Configured global `ThemeData` typography with Inter font
- Created typography scale (Display, H1–H3, Body, Small, Label)
- Commit: `feat(ui): typography system`

### 1.2 Color System
- Created `AppColors` token class
- Centralized all color tokens (Primary, Success, Warning, Error, Info, Surface, Card, Outline)
- Commit: `feat(ui): color system`

### 1.3 Spacing System
- Created `AppSpacing` constants (4, 8, 12, 16, 20, 24, 32, 40)
- Commit: `feat(ui): spacing system`

### 1.4 Radius System
- Created `AppRadius` constants (Cards: 16, Buttons: 12, Bottom Sheets: 20, Chips: 20)
- Commit: `feat(ui): radius system`

---

## Phase 2 — Component Modernization

### 2.1 Buttons
- Added hover states, press scale effect (0.97), 100ms animation, consistent radius
- Commit: `feat(ui): modern button system`

### 2.2 Cards
- Created reusable `AppCard` (radius 16, cleaner padding, consistent elevation, subtle border)
- Commit: `feat(ui): unified card system`

### 2.3 Filter Chips
- Unified all pages to use Material 3 FilterChip
- Applied to Sponsors, Followups
- Commit: `feat(ui): unified filter chips`

### 2.4 Empty States
- Created reusable `AppEmptyState` (icon, title, subtitle, optional action)
- Applied to Sponsors, Expenses, Followups, Activity Feed
- Commit: `feat(ui): empty states`

---

## Phase 3 — Dashboard Redesign

### 3.1 Dashboard Hierarchy
- Reordered sections: Pending Visits → Pending Sponsors → Today's Collection → Goal Progress → Balance → Recent Activity
- Commit: `feat(ui): dashboard hierarchy`

### 3.2 Hero Section
- Modernized Expected Sponsorship section with improved typography, spacing, progress bar styling
- Added count-up animation
- Commit: `feat(ui): dashboard hero`

### 3.3 Activity Feed
- Added semantic icon colors (Collection: green, Followup: blue, Completed: green, Expense: red)
- Improved spacing and readability
- Commit: `feat(ui): activity feed redesign`

---

## Phase 4 — Sponsors Experience

### 4.1 Sponsor Cards
- Modern CRM style with colored left status border, cleaner hierarchy, better spacing, stronger amount visibility
- Commit: `feat(ui): sponsor cards`

### 4.2 Search + Filters
- Improved layout: Search first, Filters second, Summary chips third
- Made summary chips tappable
- Commit: `feat(ui): sponsor filtering ux`

### 4.3 Sponsor Detail
- Replaced dialog workflow with bottom sheets
- Improved amount section, action row, followup history
- Highlighted overdue followups
- Commit: `feat(ui): sponsor detail redesign`

---

## Phase 5 — Follow-Up Experience

### 5.1 Followup List
- Improved cards with semantic colors for due today, overdue, completed
- Commit: `feat(ui): followup cards`

### 5.2 Followup Entry
- Replaced dialog style with bottom sheets
- Improved form layout
- Commit: `feat(ui): followup form redesign`

---

## Phase 6 — Daily Collections

### 6.1 Timeline Layout
- Finance-app-inspired timeline (time, amount, sponsor, note)
- Improved readability
- Commit: `feat(ui): daily timeline`

### 6.2 Summary Bar
- Made today's total section more prominent
- Commit: `feat(ui): daily summary redesign`

---

## Phase 7 — Loading & Polish

### 7.1 Skeleton Loading
- Added shimmer placeholders for Dashboard, Sponsors, Followups
- Commit: `feat(ui): skeleton loading`

### 7.2 Pull To Refresh
- Added `RefreshIndicator` everywhere appropriate
- Commit: `feat(ui): pull to refresh`

### 7.3 Staggered List Animation
- Applied 300ms duration, 50ms stagger to Sponsor list, Followup list, Activity feed
- Commit: `feat(ui): stagger animations`

### 7.4 Micro Interactions
- Added button press feedback, chip selection animation, card tap feedback
- Commit: `feat(ui): micro interactions`
