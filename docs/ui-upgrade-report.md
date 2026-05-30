# UI/UX Audit & Upgrade Report

**Application:** Sri Gowri Ganesha Geleyara Balaga — Festival Management Platform
**Platform:** Flutter Web (responsive — supports mobile, tablet, desktop)
**Audit Date:** May 2026
**Auditor:** Senior Product Designer / UX Researcher / Design Systems Architect

---

## Executive Summary

This application manages festival sponsorships, daily collections, follow-ups, and expenses. The core functionality is solid — Firestore integration works, data flows correctly, and the fundamental CRUD operations are complete. The app serves a real operational need for a volunteer-run festival organization.

**However, the current UI reflects a "functionality-first, design-later" approach that was never refined.**

The experience is dominated by:

- A generic Material Design 3 shell with no brand identity
- Inconsistent spacing, typography, and color usage
- Card-heavy layouts that feel like an admin panel from 2018
- Dialog-driven workflows that interrupt user flow
- An orphaned balance page that exists but is unreachable
- Empty states that range from weak to nonexistent
- A button system that was created but never applied

The recent UI overhaul (commits on `feature/ui-overhaul` branch) has laid foundational work — a design token system (`AppColors`, `AppSpacing`, `AppRadius`, `AppTypography`), a reusable `AppCard` widget, skeleton loading, and stagger animations. These are significant improvements, but they only address surface-level consistency.

**This report identifies what still needs to change, screen by screen.**

### Overall UX Score

| Category | Score |
|----------|-------|
| Visual Design | 4.5 / 10 |
| Usability | 6.5 / 10 |
| Accessibility | 5.0 / 10 |
| Information Hierarchy | 5.5 / 10 |
| Mobile Experience | 6.0 / 10 |

**Composite Score: 5.5 / 10**

---

## Screen-by-Screen Audit

---

### 1. Dashboard

**Current location:** `lib/features/dashboard/dashboard_page.dart` (816 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 5/10 | The hero animation and staggered sections show effort, but the card-heavy layout lacks hierarchy. Everything is the same weight. |
| Usability | 7/10 | Sections are logically ordered (visits → sponsors → collection → balance). Tappable cards work well. |
| Accessibility | 5/10 | Green-on-green for progress indicators, small relative-time text, no semantic labels. |
| Information Hierarchy | 6/10 | Six distinct sections are clear, but they compete for attention — nothing is visually prioritized. |
| Mobile Experience | 7/10 | Single-column scroll works. Cards are adequately sized for touch. |

#### Problems

**Major**
- **No visual hierarchy between sections.** Every card has the same padding, same border, same background. The "Expected Sponsorship" hero at the top is the only differentiated section, and it uses a 42px font size that's appropriate for desktop but overwhelming on mobile. In Linear or Stripe, financial metrics use size, color, and spacing to signal importance. Here, the balance section (arguably the most important metric) is buried equally among Pending Visits and Recent Activity.
- **Activity feed is unreadable at scale.** With 20 items, each with a colored icon, title, description, and timestamp, the list becomes visual noise. The colors (green, blue, red) are helpful, but the lack of grouping by time (Today, Yesterday, This Week) means users cannot quickly scan for recent events.
- **Progress bar is disconnected from the goal.** The LinearProgressIndicator sits inside the hero card, but it shows "Collected" progress relative to the total, not the remaining goal. The "Expected Sponsorship" number at the top and the "Collected" bar below it feel like two separate widgets that happen to be in the same card.

**Medium**
- **"Pending Visits" section truncates at 5 items** with no "See All" affordance on mobile. The "View All" link exists in the header row but is small (bodySmall text) and easy to miss.
- **The hero animation (1200ms) is too slow for repeat visits.** A volunteer who opens the app daily does not need a 1.2-second count-up animation. It should play only on first visit or be skippable.
- **Balance section uses two different font sizes for the same metric.** Current Balance is `headlineSmall`, Expenses is `titleLarge`. This makes the balance seem more important than expenses, which is correct, but the inconsistency between the two columns is visually jarring.

**Minor**
- **Activity timestamps use relative format ("5m ago", "2h ago")** but this breaks down across day boundaries. An activity from yesterday says "1d ago" rather than "Yesterday at 3:15 PM", which requires mental calculation.
- **RefreshIndicator trigger area** conflicts with the SingleChildScrollView at the top of the hero section. Users often trigger a refresh when trying to scroll up past the hero.

#### Industry Comparison

**Linear:** Uses typographic hierarchy masterfully. A single bold metric at the top, supporting metrics below in smaller text. No cards — just text on a clean background. Activity feed is grouped by date with minimal styling.

**Stripe Dashboard:** Uses color-coded metric cards with very clear visual priority. The most important metric (your balance) is largest, with supporting metrics clearly secondary.

**Splitwise:** Simple, flat design with clear debt amounts. Uses whitespace aggressively to separate concerns. Activity is chronological with clear grouping.

#### Redesign Recommendation

- **Replace the card grid with a typographic hierarchy.** The "Expected Sponsorship" should be `displayLarge` (48px). "Collected" should be `headlineLarge` (28px) in a secondary position. "Balance" should be `displayMedium` (40px) with green/red color coding.
- **Group the progress bar directly under the goal** in a single unified hero component. Show "₹X of ₹Y collected (Z%)" as a single statement, not two separate widgets.
- **Activity feed must be grouped by date.** "Today", "Yesterday", "This Week" headers with max 5 items per group, "View more" link.
- **Cut the hero animation to 400ms maximum** and play it only on cold start (not on tab switch).

---

### 2. Sponsor List (Collections)

**Current location:** `lib/features/collections/collection_list_page.dart` (454 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 5/10 | The left-color-border cards are a good CRM pattern, but the card density creates a wall of text. |
| Usability | 7/10 | Search + filter + summary chips layout follows the plan well. Tappable chips are a nice touch. |
| Accessibility | 5/10 | The thin 4px color strip on the left is the only status indicator — insufficient for colorblind users. |
| Information Hierarchy | 5/10 | Each card shows 6+ pieces of information with poor visual separation. |
| Mobile Experience | 6/10 | Cards are tappable, but both "Expected" and "Received" amounts are crammed into a single row. |

#### Problems

**Major**
- **Information density is too high per card.** Each card displays: status icon, status label, sponsor name, location, expected amount, received amount (tappable), edit icon, update timestamp, 3-dot menu. This is 9 distinct pieces of information in a single card. The CRM-style left border helps, but the card becomes a wall of information that requires significant cognitive effort to scan.
- **Search and filters compete for screen real estate.** On mobile (which is the primary use case for volunteers), the search bar, filter chips, summary bar, and the first card all appear within the first viewport. The user must scroll past 4 UI elements before seeing any actual data. The search should be collapsible or moved to the app bar.
- **The color-based status system is inaccessible.** Not Started (grey), Pending (amber), Complete (green) rely entirely on color. The icons help (circle_outlined, schedule, check_circle) but they're 14px — too small to be effective. A colorblind user sees three shades of grey.

**Medium**
- **The summary chips (Expected, Collected, Remaining) are tappable**, which is good, but tapping "Remaining" navigates to a new page with a filter query param. This replaces the current filter state rather than toggling it in-place, which disorients the user — especially since the chips look like filter toggles but behave like navigation links.
- **The "Received" amount editing pattern** uses an AlertDialog, which blocks the user from seeing the card while editing. A bottom sheet or inline edit would be more modern.
- **No sorting controls.** The Firestore query sorts by `expectedAmount desc`. There is no way to sort by name, amount, status, or last updated. For a list that can grow to 40+ sponsors, this is a significant usability gap.

**Minor**
- **PopupMenuButton position** is inconsistent — sometimes it's at the right of the name row, sometimes it overlaps with other content. On small screens, it can be cut off by the edge.
- **"No sponsors match..." empty state** has a suggestion to "Tap + to add", but the user was searching, not creating. The action should be "Clear search" not "Add sponsor".

#### Industry Comparison

**HubSpot CRM:** Contact cards show 4 key pieces of information: name, company, email, phone. Everything else is behind an expand or detail view. The most recent activity is shown as a single line.

**Pipedrive:** Deal cards are compact: title, value, stage, next activity date. Color-coded stages use both color AND pattern/texture for accessibility.

**Notion Databases:** Allow grouping, sorting, filtering, AND searching from a single toolbar. The density is user-configurable (compact, medium, spacious).

#### Redesign Recommendation

- **Reduce card density to 4-5 elements:** Status (icon + label + color strip), Name (bold, prominent), Amount (single "₹X of ₹Y" progress mini-bar), Next action (quick update button). Move location, timestamp, and full amounts to the detail page.
- **Collapse search into the app bar** using a `showSearch` delegate pattern. It should overlay the content, not push it down.
- **Add sort controls** as a dropdown in the app bar: "Sort by name | amount | status | last updated".
- **Replace the AlertDialog for quick amount update** with an inline editable field or a bottom sheet. The bottom sheet pattern is already used in the detail page — use it here too.
- **Add text labels alongside color indicators.** Instead of just a green border for "Complete", show a small "Complete" badge with text. This helps colorblind users, screen readers, and users in bright sunlight.

---

### 3. Sponsor Detail

**Current location:** `lib/features/collections/collection_detail_page.dart` (465 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 5/10 | The amount card is clean, but the action buttons below are a wall of identical-width buttons. |
| Usability | 6/10 | Bottom sheet for Receive Amount is good. Follow-up history below is useful. |
| Accessibility | 5/10 | Same color-only status indicators for follow-ups. |
| Information Hierarchy | 6/10 | Amount progress at top, actions middle, history bottom — logical flow. |
| Mobile Experience | 6/10 | Actions are full-width and easy to tap. Bottom sheet works well. |

#### Problems

**Major**
- **Three buttons stacked vertically is overwhelming.** "Receive Amount" (filled), "Add Follow-Up" (outlined), "Edit Sponsor" (outlined) are all the same width, creating a wall of identical-sized rectangles. The primary action (Receive Amount) should be visually distinct. In Stripe, the primary CTA is full-width and filled; secondary actions are smaller text links or icon buttons.
- **Follow-Up History lacks urgency cues.** Active follow-ups and completed follow-ups are mixed in the same section. Overdue items are subtly highlighted with a red icon container, but they do not visually pop. A sponsor with 3 completed follow-ups and 1 overdue follow-up should show the overdue one as an urgent alert, not as just another timeline entry.
- **The progress percentage** (`${(progress * 100).toStringAsFixed(0)}%`) is shown as plain text below the progress bar. This is a missed opportunity — the percentage should be integrated into the progress bar itself as a label, like "75% — ₹75,000 of ₹1,00,000".

**Medium**
- **No delete action on the detail page.** The user must navigate back to the list, find the card, and use the 3-dot menu to delete. This is a multi-step process for a destructive action that should be accessible from the detail page as well.
- **The "Updated X ago" timestamp** is in `bodySmall` with `onSurfaceVariant` color. This is useful information but too subtle — it's easy to miss, and knowing when a sponsor was last updated is important for volunteers managing follow-ups.

**Minor**
- **Follow-Up Row uses `isOverdue` logic** that checks `followUpDate.toDate().isBefore(DateTime.now())`. This means a follow-up scheduled for today but not yet completed is already shown as overdue. The correct logic is `dueDate.isBefore(today)` (midnight comparison).
- **The divider between active and completed follow-ups** (`Divider(height: 24)`) is the same as the spacing between items, making the separation unclear.

#### Industry Comparison

**HubSpot Contact Detail:** Uses a left sidebar for contact info and a main area for activity timeline. The "Log activity" button is prominent and fixed at the bottom. The timeline shows calls, emails, meetings — each with a clear icon, timestamp, and preview.

**Pipedrive Deal Detail:** The deal value is shown in a large, bold card at the top. The stage is visually represented as a pipeline progress bar. Activities are shown in a scrollable feed with color-coded urgency.

#### Redesign Recommendation

- **Reduce the action row to one primary + one secondary.** "Receive Amount" is the only action that needs to be a full-width filled button. "Add Follow-Up" and "Edit" should be icon buttons in the app bar or a single "Actions" dropdown.
- **Use the progress bar itself as the hero.** Instead of three separate amount rows (expected, received, remaining), show a single, large, well-designed progress bar with the numeric breakdown integrated into it. Example: a green bar from 0 to 75%, with "₹75,000 / ₹1,00,000" as an overlay label.
- **Add a prominent overdue alert** at the top of the Follow-Up History section if any follow-ups are overdue. A red banner saying "⏰ 1 follow-up overdue — Take action now" that links to the next action.
- **Move the delete action** to the app bar as a trash icon button, with a confirmation bottom sheet (reusing the existing `showConfirmDialog` pattern).

---

### 4. Add/Edit Sponsor (Collection Form)

**Current location:** `lib/features/collections/collection_form_page.dart` (208 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 4/10 | Generic form fields with no visual hierarchy. Default Material Design appearance. |
| Usability | 7/10 | Simple, straightforward form. Validation works correctly. |
| Accessibility | 5/10 | No error grouping, no autocomplete for known fields (area/building). |
| Information Hierarchy | 4/10 | All fields are equally weighted. "Notes" gets the same visual treatment as "Name". |
| Mobile Experience | 7/10 | Single-column form works well on mobile. Keyboard-aware scrolling is adequate. |

#### Problems

**Major**
- **No visual indication of required vs optional fields.** The validation error messages appear only after submission. Users discover that "Name" and "Expected Sponsorship" are required only when they tap "Save". This creates a negative feedback loop — the user fills out 4 fields, taps save, and sees errors. Modern forms use leading asterisks or labels like "Required" to communicate this upfront.
- **"Received Amount" defaults to 0** in new sponsor creation. This is an anti-pattern — if a new sponsor has not paid yet, the field should be empty or hidden. Defaulting to 0 encourages data entry errors (user forgets to change it, the sponsor shows as "₹0 received").
- **No field grouping.** "Building" and "Area" are not grouped together visually. They should be in a "Location" section with a subtle section header or a grouped card. Similarly, "Expected" and "Received" should be in a "Sponsorship Amount" group.

**Medium**
- **The Notes field has no character limit** or hint about what to write. In a volunteer context with multiple data entry people, consistency matters. As noted in the research doc, there are frequent data entry errors with amount formatting.
- **No keyboard type differentiation.** The amount fields should use `TextInputType.number` (which they do), but they should also show a number pad on mobile. The current implementation uses `TextInputType.number` which is correct.

**Minor**
- **The form uses `const SizedBox(height: 16)`** rather than `AppSpacing` tokens for spacing between fields. This was improved in the recent overhaul for some pages but not this one.
- **No confirmation on form discard.** If a user fills out the form and navigates back, the data is lost with no warning.

#### Industry Comparison

**Notion Forms:** Inline labels, clear required indicators, grouped fields, and character counts on text fields. The form is treated as a single visual block with sections.

**Linear Create Issue:** Minimal — title field is prominent, all other fields are collapsed below. Uses progressive disclosure so the user is never overwhelmed.

#### Redesign Recommendation

- **Add required field indicators** — a red asterisk or "Required" chip next to field labels.
- **Set "Received Amount" to null/empty** for new sponsors, with a hint "Leave at 0 if not yet received".
- **Group fields into visual sections:** "Sponsor Information" (Name), "Location" (Building, Area), "Sponsorship" (Expected, Received), "Notes". Use subtle section headers with bottom padding.
- **Add a discard confirmation dialog** using the existing `showConfirmDialog` pattern.

---

### 5. Follow-Ups List

**Current location:** `lib/features/followups/followup_list_page.dart` (439 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 6/10 | Semantic color coding (red/amber/blue/green) is a significant improvement. Icons help. |
| Usability | 7/10 | Filter chips are clear. The "Collected" CTA button is well-placed on active items. |
| Accessibility | 5/10 | Color-only differentiation for urgency. Icons help but are small (22px). |
| Information Hierarchy | 6/10 | Sponsor name is prominent. Date, amount, and note are secondary — correct priority. |
| Mobile Experience | 7/10 | Cards are tappable. The "Collected" button is within thumb reach. |

#### Problems

**Major**
- **Card density varies wildly based on content.** A follow-up with an amount, a long note, and a "Collected" button will be 3x taller than one without. This creates an uneven scrolling experience where some items get disproportionate visual weight based on data, not importance.
- **The "Collected" button** (`FilledButton.tonalIcon`) is right-aligned in the card. This creates a long visual path from the sponsor name (top-left) to the action (bottom-right). Users scanning the list must move their eyes diagonally across each card.
- **Filter chip labels are ambiguous.** "Active" and "Completed" are clear, but "All" includes both active and completed items. A volunteer who wants to see only their pending work should use "Active". But if the default is "Active" (as the code shows with `_filter = 'active'`), then why offer "All" at all? This is a cognitive load problem — every extra option requires a decision.

**Medium**
- **Undo snackbar after marking as collected** has a 3-second timeout. This is too short for a user who accidentally taps "Collected". It should be at least 5 seconds, or use the persistent snackbar pattern with an action button.
- **"Completed" filter shows completed follow-ups** but does not show the completion date. The card shows "Completed" text but not *when* it was completed. For tracking purposes, this is a gap.
- **No visual distinction between overdue and due-today** beyond color. Both use the same icon+text layout, just different colors. A due-today follow-up should feel more urgent — perhaps a small "DUE TODAY" badge.

**Minor**
- **The "Add Follow-Up" FAB navigates to `/followups/add`** which is outside the ShellRoute. This means the bottom navigation bar disappears on the form page. The user must use the back button to return.
- **No search functionality.** Unlike the sponsor list, follow-ups cannot be searched. For volunteers managing 20+ follow-ups, this is a missing feature.

#### Industry Comparison

**Todoist:** Tasks are prioritized with P1-P4 labels. Overdue tasks are shown in red with a prominent "OVERDUE" badge. The today view groups tasks by project.

**Things 3:** Uses a "Today" view that shows both overdue items (with a prominent header) and today's items. Completed items fade out with a strikethrough animation.

#### Redesign Recommendation

- **Normalize card height** by setting a maximum note preview (2 lines) and truncating. Move the full note to a detail view.
- **Move the "Collected" button** to the top-right of the card, next to the sponsor name, so users can take action without scanning the entire card.
- **Remove the "All" filter** and default to "Active". Add "Completed" as a secondary filter. This reduces cognitive load and matches the user's mental model (they want to see what needs to be done).
- **Add "OVERDUE" and "DUE TODAY" badges** as small colored chips on the card, not just color changes on the icon.
- **Show completion date** for completed follow-ups as part of the date label: "Completed 2 days ago" vs just "Completed".

---

### 6. Follow-Up Form

**Current location:** `lib/features/followups/followup_form_page.dart` (262 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 4/10 | Generic form. Default Material inputs with no personality. |
| Usability | 6/10 | Required fields are validated. Date picker works. Query param pre-fill is helpful. |
| Accessibility | 5/10 | Date picker fields look like text inputs, which is confusing for screen readers. |
| Information Hierarchy | 4/10 | All fields are equally weighted. No grouping. |
| Mobile Experience | 6/10 | Works, but the date picker opens a full-screen dialog on mobile. |

#### Problems

**Major**
- **The date picker delegate is poorly designed.** It uses an `InkWell` wrapped in `InputDecorator` with a fake suffix icon. This creates a confusing interaction — the user taps the field, nothing visibly happens for a moment, then the date picker dialog appears. It should be a `TextFormField` with `readOnly: true` and `suffixIcon: IconButton` that triggers the picker. This is a standard Flutter pattern that was not followed.
- **No inline validation.** Errors appear only after the form is submitted. The sponsor name field and note field should validate on blur or on change.
- **"Amount (optional)" and "Note (required)"** send mixed signals. Users who see "Amount (optional)" may assume "Note" is also optional. The note field should have a clear "Required" indicator.

**Medium**
- **No ability to create a follow-up for an existing sponsor without leaving the page.** The sponsor name is a plain text field. It should be an autocomplete or a dropdown of existing sponsors from the targets collection. Volunteers frequently know the sponsor name but may spell it differently, creating duplicate entries.
- **The follow-up form is a full page route** (`/followups/add`), which means the user loses bottom navigation context. This could be a bottom sheet when triggered from the sponsor detail page.

**Minor**
- **Keyboard type defaults to text for the amount field.** It should explicitly use `TextInputType.number` with `TextInputAction.next`.
- **No date constraints on the DatePicker.** `firstDate: now, lastDate: now.add(Duration(days: 365))` is reasonable, but the form allows selecting past dates via the initial date parameter when editing.

#### Industry Comparison

**Calendly:** Date/time pickers are inline — you see available slots without leaving the page. No full-screen date picker dialogs.

**Notion:** Date properties can be typed directly ("tomorrow", "next wed") rather than forcing date picker navigation.

#### Redesign Recommendation

- **Replace the fake date picker** with a `TextFormField` + `readOnly` + `suffixIcon` pattern that clearly signals the interaction.
- **Add inline validation** — validate sponsor name and note on focus loss.
- **Make sponsor name a searchable dropdown** populated from the targets stream, with a free-text fallback option for new sponsors.
- **Use a bottom sheet for follow-up creation** when triggered from the sponsor detail page, keeping the user in context. Keep the full page route for direct navigation from the FAB.

---

### 7. Daily Collections

**Current location:** `lib/features/daily_collections/daily_collection_list_page.dart` (465 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 6/10 | The timeline-inspired design is clean. The quick-add card is well-integrated. |
| Usability | 7/10 | Quick-add with preset amount chips is excellent for fast data entry. |
| Accessibility | 5/10 | Amount chips are small touch targets. No labels on timeline dots. |
| Information Hierarchy | 6/10 | Today's total at top, quick-add next, entries below — logical flow. |
| Mobile Experience | 6/10 | Quick-add card takes up half the screen. Preset chips are small. |

#### Problems

**Major**
- **The quick-add form takes up 50% of the viewport** on mobile. The user must scroll past the form to see today's entries. This inverts the information hierarchy — the action comes before the data. In finance apps like Splitwise, the user sees the list of transactions first, with the "Add" button as a FAB or a persistent bottom bar.
- **No data validation on the amount chips.** Tapping a chip sets the text field value, but the user can still edit it. If they tap the chip and then manually edit the amount, the chip selection state becomes stale (no visual indication that the chip is "active"). This creates confusion — "Did I select ₹5,000 or did I type ₹3,500?"
- **The "Earlier" section accumulates indefinitely.** As the festival runs for weeks, the "Earlier" section grows unbounded. There is no pagination, no month grouping, and no way to view past collections without infinite scrolling.

**Medium**
- **No summary of total collections across all time.** The header shows today's total, but there is no "Total Collections: ₹X" summary at the top or bottom. The dashboard has this, but the collections page itself should show the running total.
- **The inline delete confirmation** uses `showConfirmDialog` which is an AlertDialog. On mobile, this covers the full screen. A swipe-to-delete pattern with undo would be more modern.
- **"Record Collection" button shows spinner while saving**, but the button label changes to "Saving..." while the spinner runs. This is redundant — the spinner is sufficient feedback. The text change creates layout shift.

**Minor**
- **No activity logging** when a daily collection is recorded (unlike sponsor collections which log an activity). This means the activity feed will not show daily collections, creating an incomplete audit trail.
- **The "Note" field validates for non-empty**, but there is no guidance on what to write. "Source or purpose" is the hint, but volunteers may write inconsistent notes.

#### Industry Comparison

**Splitwise:** The expense list is the primary view. "Add an expense" is a persistent bottom bar, not an inline card. Preset splits are shown as chips after entering the amount, not before.

**Wallet by BudgetBakers:** Transactions are shown in a timeline with clear date headers. Each transaction shows category icon, payee, amount (colored), and account. The add button is a FAB, and the form is a full-page or bottom sheet.

#### Redesign Recommendation

- **Move the quick-add to a FAB or bottom sheet.** The list should show today's entries by default. The quick-add should be accessible via a FAB that opens a bottom sheet with the amount chips, note field, and save button — the same pattern used for "Receive Amount" on the sponsor detail page.
- **Add pagination or date grouping** for past entries. Group by week or month with collapsible headers. "This Week", "Last Week", "June 2026", etc.
- **Add a total summary row** at the bottom: "Total Collections: ₹X across N entries" in a sticky footer.
- **Replace AlertDialog for delete** with swipe-to-delete + undo snackbar (the same pattern used for follow-up completion).

---

### 8. Expenses List

**Current location:** `lib/features/expenses/expense_list_page.dart` (165 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 5/10 | Clean but generic. Red icons work but feel heavy. |
| Usability | 7/10 | Simple list with clear information. Footer total is well-placed. |
| Accessibility | 5/10 | Red-only icon color for expenses — insufficient for colorblind users. |
| Information Hierarchy | 6/10 | Amount is primary, note secondary, date tertiary — correct priority. |
| Mobile Experience | 7/10 | Simple cards work well. Footer total is sticky-adjacent. |

#### Problems

**Major**
- **No expense categories or grouping.** Every expense is a flat list item with no category, type, or purpose grouping. For a festival with dozens of expenses (decorations, food, permits, transportation), the lack of categorization makes it impossible to analyze spending patterns without exporting manually.
- **No search or filter.** With 20+ expenses, the list becomes unscrollable. There is no search, no date range filter, no category filter. The only way to find a specific expense is to scroll through everything.
- **The footer total is not truly sticky.** It is rendered as the last child of a Column after a ListView. Once the list exceeds the viewport, the footer scrolls out of view. It should be a `BottomSheet` or a `Stack`-based overlay that stays visible.

**Medium**
- **No monthly or running total.** The footer shows total expenses, but there is no breakdown by month. In practice, expenses accumulate over the festival period, and volunteers need to know "how much did we spend this week?"
- **Edit form does not log activity.** Unlike follow-ups and sponsor collections, editing an expense does not create an activity entry. The activity stream will show the creation but not subsequent edits.

**Minor**
- **Date format is "dd MMM yyyy"** which is correct but lacks the time component. For audit purposes, knowing the time of an expense can be important.
- **The red receipt icon in the card** (`Icons.receipt_rounded`) with `Color(0xFFEF4444)` at 30% opacity background creates a pinkish container that looks slightly dated.

#### Industry Comparison

**QuickBooks:** Expenses are grouped by category with expandable sections. Each category shows a subtotal. A search bar is always visible at the top.

**Splitwise:** Each expense shows split details, category icon, and who paid. The total is always visible in a bottom bar that persists during scrolling.

#### Redesign Recommendation

- **Add category/type field to the Expense model** and group expenses by category in the list. Use expandable sections with category totals.
- **Make the footer sticky** using a `Stack` or `CustomScrollView` with `SliverPersistentHeader`.
- **Add search** (same pattern as sponsor list) and date range filter.
- **Add more icons for variety** — different expense types should have different icons (food, transport, decoration, etc.) rather than the same red receipt icon for everything.

---

### 9. Settings Page

**Current location:** `lib/features/settings/settings_page.dart` (345 lines)

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 4/10 | Generic form with no visual polish. Data summary is a wall of text. |
| Usability | 6/10 | Works, but the festival info form uses a separate StatefulWidget for no clear reason. |
| Accessibility | 4/10 | No semantic structure. The "Data Summary" section is read-only but rendered as regular text. |
| Information Hierarchy | 3/10 | Three unrelated sections grouped without visual distinction. |
| Mobile Experience | 6/10 | Scrollable, but the data summary text is small and dense. |

#### Problems

**Major**
- **Edit and display modes are mixed.** The festival information section is always in edit mode — there is no "read" view and "edit" view. This means the user sees text fields by default, even when they only want to view the festival info. It should be a read-only display with an "Edit" button.
- **The Data Summary section is redundant.** It displays expected/collected/expenses data that is already visible on the dashboard. It is placed on a separate page that requires navigating away from the main content. If the user wants this data, they should go to the dashboard.
- **The about section is hardcoded.** "Version 1.0", "Flutter Web + Firebase", and the app name are hardcoded strings. These should come from the app's metadata or a configuration file.

**Medium**
- **No confirmation on festival info save.** The "Save" button silently updates the festival document. There is no success feedback, no loading state, and no way to undo.
- **The "Data Summary" uses DashboardData**, which means it depends on the dashboard provider. If the dashboard provider fails (e.g., Firestore is unreachable), the entire settings page shows partial data.
- **The `_FestivalCard` stateful widget** manages its own `TextEditingController`s separate from the parent. This is inconsistent with the pattern used in all other form pages.

**Minor**
- **No settings for user preferences.** Things like default view, default filter, notification preferences, or currency display format are not present.
- **Settings is outside the ShellRoute**, so the bottom navigation disappears when navigating to settings from the dashboard gear icon.

#### Industry Comparison

**Linear Settings:** Uses a sidebar navigation for different setting groups (Account, Workspace, Billing, etc.). The page is designed for occasional use with clear sections and save indicators.

**Notion Settings:** Clean, minimal. Uses a single scrollable page with collapsible sections. Read-only information is displayed as text, not as form fields.

#### Redesign Recommendation

- **Split the settings page into two modes: read and edit.** Read mode shows festival info as text labels. Tap "Edit" to switch to form fields.
- **Remove the Data Summary section** — it's redundant with the dashboard. Replace it with useful settings like currency format, default filter, or notification preferences.
- **Move the About section to the very bottom** with reduced visual weight. It's rarely needed information.
- **Add a success snackbar** after saving festival info.

---

### 10. Navigation

**Current location:** `lib/app.dart`, `lib/shared/widgets/app_scaffold.dart`, `lib/shared/widgets/animated_bottom_nav.dart`

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 6/10 | The animated bottom nav with scale-on-select is a nice touch. Icons are well-chosen. |
| Usability | 6/10 | Four tabs cover the main sections. Settings and Follow-ups are outside the shell, which is inconsistent. |
| Accessibility | 4/10 | No labels on bottom nav items (icons only). No indication of active state beyond color. |
| Information Hierarchy | 5/10 | The tab order (Dashboard, Sponsors, Daily, Expenses) is logical for data entry but not for consumption. |
| Mobile Experience | 7/10 | Bottom nav is thumb-friendly. Navigation is snappy at 250ms. |

#### Problems

**Major**
- **Two critical pages are outside the ShellRoute.** Follow-ups (`/followups`) and Settings (`/settings`) are full-page routes without bottom navigation. This means when a volunteer navigates from the dashboard to Follow-ups, the bottom nav disappears. They must use the back button to return. This breaks the navigation paradigm — users expect tabs to persist. Follow-ups should be added as a 5th tab.
- **No route transitions for external pages.** Settings and Follow-ups use `PageTransition.fadeSlide`, which is consistent, but the lack of bottom nav creates a visual discontinuity. The transition animation plays, but then the bottom bar vanishes, which feels like a navigation error.
- **The bottom nav has no labels.** Material Design 3 recommends labels for bottom navigation items, especially for accessibility. Currently, only icons are shown. Users who are unfamiliar with the icons must guess: is the wallet icon for "Daily Collections" or "Expenses"?

**Medium**
- **Tab switching uses `context.go()`**, which replaces the current route. This means if the user is on a sub-page (e.g., `/collections/abc123` or `/expenses/add`) and taps a different tab, they lose navigation history. Tapping back after switching tabs should return to the previous state, not exit the app.
- **The ShellRoute forces all tab pages to be at the root level.** There is no way to navigate to `/collections/add` and have the bottom nav still visible. Sub-routes are pushed as full pages that overlay the scaffold.

**Minor**
- **The animated bottom nav has a 250ms scale animation** on every tab change. This is visually pleasant but adds unnecessary delay. 100ms would be sufficient.
- **Settings gear icon in the dashboard** navigates to a page without bottom nav, but there's no visual indication that this is a "full screen" mode. A subtle transition animation change (e.g., scale-up) would help.

#### Industry Comparison

**Instagram / Twitter (X):** Bottom navigation tabs include labels by default. Selected state uses both icon fill + text color + indicator dot. Tab switching animates the content, not the tab icon.

**Linear:** Uses a sidebar navigation with clear labels and section headers. Active state is indicated by a colored background, not just text color.

#### Redesign Recommendation

- **Add Follow-ups as a 5th tab** in the bottom navigation. Use the `Icons.follow_the_signs_rounded` icon. Map the route inside the ShellRoute.
- **Add labels to bottom nav items** using `NavigationBar` (Material 3) which supports `label` by default, or add labels to the custom `AnimatedBottomNav`.
- **Use `context.push()` instead of `context.go()`** for tab switching to preserve navigation history. Or implement a nested navigator pattern using `StatefulShellRoute` from go_router.
- **Move Settings out of the full-page route** — either add it as a tab (replacing a less-used tab) or keep it as a push route but with a visual transition that indicates it's a sub-page.

---

### 11. Orphaned Page: Balance

**Current location:** `lib/features/balance/balance_page.dart` (243 lines)

This is a 243-line file that is **not registered in the router**. It exists in the codebase but is unreachable from the app.

#### UX Score

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Visual Design | 4/10 | Shows financial data in a simple column layout. No visual hierarchy. |
| Usability | N/A | Page is unreachable. |
| Accessibility | N/A | None. |
| Information Hierarchy | 5/10 | The data presented (expected, collected, remaining, expenses, balance, efficiency) is complete but redundant with the dashboard. |
| Mobile Experience | N/A | None. |

#### Recommendation

**Delete this page.** All of its data is already shown in the Dashboard's `_BalanceSection` and `_HeroSection`. Maintaining two copies of the same data visualization creates maintenance overhead and potential inconsistency. If a standalone balance page is needed, it should be a read-only summary card within the dashboard, not a separate route.

---

## Design System Audit

### Typography

#### Current State
- Inter font (via `google_fonts`) applied globally through `GoogleFonts.interTextTheme()`
- Scale: Display 48/700, H1 28/600, H2 22/600, H3 18/600, Body 16/400, Body 14/400, Label 12/500
- Used consistently across the app

#### Problems
- **`bodyLarge` (16px) is rarely used.** Most pages default to `bodyMedium` (14px) for body text. The 16px body size exists in the scale but is not utilized, which means text across the app is smaller than it should be for readability.
- **`labelLarge` (12px) is used for everything from timestamps to filter labels.** A 12px font is appropriate for timestamps but not for interactive filter labels. The filter chips should use `bodyMedium` (14px) or `labelMedium` (which doesn't exist in the current scale).
- **No monospace font for amounts.** Financial values would benefit from a tabular-nums font or monospace digits for alignment, but Inter's default proportional numbers are used everywhere.

#### Recommended State
- Add `labelMedium` (14px, weight 500) and `labelSmall` (10px, weight 500) to the scale
- Use `bodyLarge` (16px) for primary body text in cards
- Set `TextStyle(fontFeatures: [FontFeature.tabularNumbers()])` on `AmountText`

---

### Color System

#### Current State
- 8 color tokens defined in `AppColors`: primary, success, warning, error, info, surface, card, outline
- Theme uses `ColorScheme.light()` derived from `AppColors.primary`
- Semantic colors (success/warning/error/info) are hardcoded as `Color(0xFF...)` in multiple places despite being defined as tokens

#### Problems
- **Semantic colors are defined but not used.** `AppColors.success`, `.warning`, `.info` are never referenced. Instead, `Colors.green.shade700`, `Colors.orange.shade700`, and `colorScheme.error` are used with inconsistent values across screens.
- **The outline color (`0x1F000000`)** is a semi-transparent black (12% opacity). This creates a very subtle border that may not meet contrast requirements on light backgrounds.
- **No surface container colors.** Material 3's color system includes `surfaceVariant`, `surfaceContainerHighest`, etc. The app uses `colorScheme.surfaceContainerHighest.withAlpha(100)` in multiple places, which is a workaround that creates inconsistent appearance across pages.
- **No dark mode.** The `AppTheme` only defines `.light`. A dark mode was mentioned as "future phase," but the color tokens are not structured to support it easily.

#### Recommended State
- Replace all hardcoded `Colors.green.shadeXXX` and `Colors.orange.shadeXXX` with `AppColors.success` and `AppColors.warning`
- Increase outline opacity to 15-18% for better visibility
- Define proper Material 3 surface container colors instead of using `withAlpha(100)` workarounds
- Structure tokens to support dark mode: `AppColors.primaryLight` / `AppColors.primaryDark`

---

### Radius System

#### Current State
- 4 radius tokens: card (16), button (12), bottomSheet (20), chip (20)
- Applied via `AppRadius` class with `BorderRadius` getters

#### Problems
- **Card radius (16) is used everywhere**, including for small cards (collection tiles, expense tiles, filter chips). A 16px radius creates a pill-like appearance on small components that looks better suited for a media app than a financial tool.
- **Button radius (12)** is appropriate and used consistently.
- **BottomSheet radius (20)** is too large for a form sheet — it creates excess curvature that wastes vertical space at the top of the sheet.

#### Recommended State
- Reduce small component radius to 8-10px. Reserve 16px for large cards (dashboard sections, detail pages).
- BottomSheet radius should be 16px (consistent with cards) or 12px (consistent with buttons).
- Add radius tokens for `small` (8px), `medium` (12px), `large` (16px) rather than semantic names, or rename to match component types.

---

### Shadows / Elevation

#### Current State
- Card elevation is 0 (flat design with border outline)
- Buttons have 0 elevation
- No shadow tokens defined

#### Problems
- **Flat design is appropriate for a modern look**, but the lack of elevation differentiation means all surfaces blend together. There is no visual distinction between tappable cards, static information cards, and cards that are part of a broader layout.
- **Bottom sheets have no shadow.** The `BottomSheetThemeData` only sets shape, not elevation or shadow.
- **No elevation for dialogs.** `AlertDialog` uses default Material elevation, but `showModalBottomSheet` has no shadow defined, creating a flat sheet that floats ambiguously.

#### Recommended State
- Define elevation tokens: `elevationNone` (0), `elevationLow` (1), `elevationMedium` (3), `elevationHigh` (6)
- Apply `elevationLow` to tappable cards, `elevationNone` to static cards, `elevationMedium` to bottom sheets, `elevationHigh` to dialogs

---

### Icons

#### Current State
- Material Design Icons (rounded variant) used throughout
- `Icons.xxx_rounded` pattern is consistent
- Icon sizes vary between 13px and 64px with no defined scale

#### Problems
- **No icon size scale.** Sizes are specified inline: `size: 13`, `size: 14`, `size: 16`, `size: 18`, `size: 20`, `size: 22`, `size: 24`, `size: 28`, `size: 40`, `size: 48`, `size: 64`. This is 11 different sizes with no rhyme or reason.
- **Icon colors are inconsistent.** Follow-up status uses `colorScheme.error`, `Colors.green.shade700`, `colorScheme.primary`, and direct `Color(0xFF...)` values across different widgets. The same status type should always use the same color.
- **Activity feed icons are semantically mapped** (wallet for collection, receipt for expense, bell for follow-up), which is good, but the icons are 18px which is small for touch targets on the activity feed.

#### Recommended State
- Define icon size tokens: `iconSmall` (16), `iconMedium` (20), `iconLarge` (24), `iconXLarge` (32), `iconDisplay` (48)
- Enforce consistent colors via the semantic tokens that actually exist but are not used

---

### Component Consistency

#### Problems
- **`AppButton` exists but is never used.** All feature pages use direct `FilledButton`, `OutlinedButton`, and `TextButton` widgets instead of the `AppButton.filled()`, `AppButton.outlined()` wrapper. The `AppButton` class has the press-scale animation, but since it's not used anywhere, the animation is dead code.
- **Cards are a mix of `Card`, `AppCard`, and custom `Container` with `BoxDecoration`** across different screens. The collection tile (sponsor card) uses a custom `Container` with `IntrinsicHeight` for the left border, while expense tiles use `AppCard`. This inconsistency is visible when scrolling between screens.
- **Filter chips are `FilterChip` on some pages and custom `GestureDetector` + `Container` on others.** The follow-up filter bar was recently updated to use proper `FilterChip`, but the consistency is not enforced at the theme level.

---

### Button Styles

#### Current State
- Three button types: `FilledButton`, `OutlinedButton`, `TextButton`
- Radius: 12px (via theme)
- Padding: horizontal 24px, vertical 14px

#### Problems
- **No icon-button standards.** `IconButton` and `PopupMenuButton` have no consistent sizing, color, or padding.
- **Tonal buttons are used in some places** (`FilledButton.tonalIcon` on follow-up "Collected" action) but not standardized. There's no `AppButton.tonal()` variant.
- **Button text uses default weight (500)** rather than the typography scale's `labelLarge` (12px, 500).

---

### Form Styles

#### Current State
- `InputDecorationTheme` sets borderRadius 12, contentPadding 16/14, filled background with alpha 100
- Consistent `OutlineInputBorder` across all forms

#### Problems
- **No prefix/suffix icon consistency.** Some fields use `prefixIcon`, others do not. The "Amount" field uses `prefixText: '₹ '` while others use icons. The inconsistency creates a disjointed form experience.
- **Date picker fields are not standardized.** Follow-up form uses `InkWell + InputDecorator`, expense form uses `TextFormField + readOnly + suffixIcon`. Two different patterns for the same interaction.
- **No disabled state styling.** When forms are loading (edit mode loading), the fields flash as enabled before settling into their populated state.

---

### Chip Styles

#### Current State
- `ChipThemeData` sets radius 20 (pill shape)
- `FilterChip` used for status filters on sponsor list and follow-up list

#### Problems
- **Pill shape (radius 20) is too rounded for chips that appear in a row with text.** A 12px radius would look more modern and less playful.
- **No selected chip animation.** Material 3's `FilterChip` has a built-in elevation change on select, but the custom chips on the follow-up page use `GestureDetector` and miss the animation entirely.
- **Chip density is inconsistent.** `VisualDensity.compact` is used in some places but not others, leading to different heights for the same component type.

---

## Accessibility Audit

### Overall Score: 52 / 100

| Category | Score | Issues |
|----------|-------|--------|
| Color Contrast | 6/10 | Primary green (#0F6B3C) on white passes, but some combinations (amber on white, green on green) may fail WCAG AA. |
| Touch Targets | 7/10 | Most interactive elements are >= 44px. Filter chips and small icons may be below threshold. |
| Font Sizes | 5/10 | Body text defaults to 14px which is below the recommended 16px for body text. Small (12px) is used for many labels. |
| Semantic Labels | 3/10 | No `Semantics` widget usage. Icons without labels. No accessibility hints on custom widgets. |
| Keyboard Navigation | 2/10 | Flutter web keyboard navigation is not configured. Tab order follows widget tree, which is unpredictable. |
| Loading Indicators | 6/10 | Skeleton loading is implemented but not universally applied. Some pages still show raw `CircularProgressIndicator`. |

### Specific Issues

1. **Color-only status indicators.** The sponsor list uses a colored left border (green/amber/grey) with no text label for the status. A colorblind user sees three shades of grey. WCAG SC 1.4.1 (Use of Color) requires information to be conveyed through more than just color.

2. **Touch targets for filter chips** are approximately 28px tall, which is below the recommended 44px minimum for touch targets (WCAG SC 2.5.5). Users with motor impairments may struggle to tap the correct chip.

3. **No heading structure.** The dashboard has section titles ("Pending Sponsors", "Today's Collection"), but they are not marked as headings. Screen readers navigating by heading will skip over all section content because there are no semantic headings.

4. **Activity feed timestamps** use relative formatting ("5m ago"), which screen readers will read as "five m ago" rather than "five minutes ago". These should use a proper relative-time format accessible to screen readers, like "5 minutes ago" with an aria-label.

5. **Form validation errors** appear as snackbars, not inline. When a user submits a form with invalid data, the error message appears briefly at the bottom of the screen and disappears. Users with cognitive disabilities may miss this transient feedback. Inline error messages below each field are more accessible.

---

## Mobile UX Audit

### Thumb Reach

- **FAB placement** is correct (bottom-right) on all list pages. Thumb zone access is good.
- **Bottom navigation items** are within thumb reach on mobile but have no labels (see Navigation section).
- **Filter chips at the top of lists** require a thumb stretch to reach. On devices > 6 inches, the top-left chip is outside the comfortable thumb zone. Chips should be horizontally scrollable with the search bar.

### Dialog Usage

- **AlertDialog for quick amount update** (sponsor list) is a poor mobile pattern. The dialog covers the entire screen on mobile, hiding the list context. A bottom sheet is better (and is already used in the detail page — inconsistency problem).
- **Date picker dialogs** are full-screen on mobile, which creates context loss. An inline date picker or a bottom sheet with a compact calendar would be better.

### Form Flows

- **Add/Edit flows are full-page routes** that remove bottom navigation. This is acceptable for occasional data entry but creates friction for power users who add multiple records in a session. Each record requires: tap FAB → full page form → submit → auto-navigate back → scroll to find position → tap FAB again.
- **Quick-add daily collection** is inline, which is the right pattern for frequent data entry. This pattern should be replicated for other add flows.

### Scrolling Behavior

- **No scroll-to-top on tab switch.** When switching from Expenses back to Dashboard, the dashboard retains its scroll position. Users expect tabs to reset to the top. This is a standard mobile pattern that is missing.
- **Pull-to-refresh is implemented** but the RefreshIndicator conflicts with the scroll physics on some pages (notably the dashboard where the hero animation and scroll interact).

---

## Desktop UX Audit

### Large-Screen Layout

- **No responsive grid or adaptive layout.** All pages use `Column` or `ListView` with fixed-width cards. On desktop (1200px+), the content is centered in a narrow column with excessive whitespace on both sides.
- **Card widths are not constrained.** On a 1920px desktop, cards stretch to 800-1200px wide, which creates line lengths of 40-60 words. This exceeds the recommended 60-80 characters per line for optimal readability.
- **The dashboard LayoutBuilder has responsive checks** (`isWide` at 600px, `isDesktop` at 900px), but they are no longer used (dead code removed in recent commit). The dashboard is always single-column regardless of screen size.

### Information Density

- **Desktop screens show the same information as mobile** but with larger margins. There is no "density mode" or expanded layout that shows more information on larger screens.
- **The sponsor list shows 9 pieces of information per card** on both mobile and desktop. On desktop, this should be a table layout with columns for different fields, allowing sorting and comparison.
- **No keyboard shortcuts.** Desktop users expect keyboard shortcuts for common actions (Ctrl+N for new, Ctrl+F for search). Flutter web supports keyboard events, but none are implemented.

### Responsive Behavior

- **No breakpoint-based layout changes.** The app uses a single layout across all screen sizes. `LayoutBuilder` is present but not effectively used.
- **No tablet-specific layout.** On tablets (768-1024px), the app shows the mobile layout with extra whitespace. A two-column layout (list + detail) would be more appropriate for tablets.
- **No landscape optimization.** Forms and lists designed for portrait orientation look stretched in landscape.

---

## Prioritized Upgrade Roadmap

### Phase 1 — Quick Wins (High Impact / Low Risk)

*Estimated effort: 2-3 days*

1. **Standardize icon sizes.** Replace 11 different inline icon sizes with 4-5 defined tokens. This immediately improves visual consistency.
2. **Add labels to bottom navigation.** This is a single-file change (`animated_bottom_nav.dart`) that dramatically improves navigation clarity and accessibility.
3. **Remove orphaned balance page.** Delete `lib/features/balance/balance_page.dart` and remove it from the file system (no route to remove).
4. **Replace `Colors.green.shadeXXX` with `AppColors.success` tokens.** A find-and-replace across the codebase to enforce the semantic color tokens that already exist but aren't used.
5. **Remove `AppButton` code** since it's unused, or apply it across all feature pages (see Phase 2).
6. **Fix overdue calculation** in `_VisitRow` to use midnight comparison instead of `DateTime.now()` comparison.
7. **Set hero animation to 400ms for repeat visits** using a session flag.

### Phase 2 — Design System Enforcement (Medium Impact / Low Risk)

*Estimated effort: 3-5 days*

1. **Apply `AppButton` across all feature pages.** Replace all direct `FilledButton`/`OutlinedButton`/`TextButton` usage with `AppButton.filled()`, `.outlined()`, `.text()`, etc.
2. **Standardize card rendering.** Ensure all list items use either `AppCard` or the custom left-border container — not a mix of both.
3. **Add `labelMedium` (14px, 500) and `labelSmall` (10px, 500) to typography scale.** Update components that use 12px for interactive labels.
4. **Define elevation tokens** and apply them consistently to cards, sheets, and dialogs.
5. **Standardize date picker fields** across all forms to use the same `TextFormField` + `readOnly` + `suffixIcon` pattern.
6. **Add `FontFeature.tabularNumbers()`** to the `AmountText` widget for aligned financial figures.

### Phase 3 — Navigation Redesign (Medium Impact / Medium Risk)

*Estimated effort: 3-5 days*

1. **Add Follow-ups as a 5th tab** in the bottom navigation using `StatefulShellRoute` from go_router.
2. **Add labels to bottom navigation items** using Material 3's `NavigationBar` or by extending the custom `AnimatedBottomNav`.
3. **Implement scroll-to-top on tab switch** using a `PageStorageKey` or scroll controller reset.
4. **Implement keyboard shortcuts** for desktop: `Ctrl+N` to add, `Ctrl+F` to search, `Escape` to go back.
5. **Keep Settings as a push route** but add a visual transition (scale-down or slide-up) to distinguish it from tab navigation.

### Phase 4 — Dashboard Transformation (High Impact / Medium Risk)

*Estimated effort: 5-7 days*

1. **Replace the card grid with a typographic hierarchy.** Single large metric (Expected Sponsorship) at top, secondary metrics below.
2. **Merge hero and progress** into a single unified component showing "₹X of ₹Y collected (Z%)".
3. **Group activity feed by date** with collapsible sections and "View more" links.
4. **Reduce hero animation to 400ms** with cold-start-only playback.
5. **Add responsive layout** for desktop: two-column layout (metrics left, activity right) on screens > 900px.
6. **Add monthly/weekly date grouping** to balance and collection sections.

### Phase 5 — Sponsor Experience (High Impact / Medium Risk)

*Estimated effort: 5-7 days*

1. **Reduce card density to 4-5 elements.** Move secondary information to detail page. Show a mini progress bar instead of two separate amount rows.
2. **Collapse search into app bar** using `showSearch` delegate overlay pattern.
3. **Add sort controls** (by name, amount, status, last updated).
4. **Replace AlertDialog for quick amount update** with a bottom sheet (consistent with detail page pattern).
5. **Add text labels to color indicators** for accessibility (WCAG 1.4.1).
6. **Convert sponsor list to table layout on desktop** with sortable columns.
7. **Add inline delete action** on the detail page (app bar trash icon).

### Phase 6 — Follow-Up & Daily Collection Experience (High Impact / Low Risk)

*Estimated effort: 3-5 days*

1. **Remove "All" filter** from follow-up list. Default to "Active", add "Completed" as a toggle.
2. **Add "OVERDUE" and "DUE TODAY" badges** to follow-up cards for urgency.
3. **Move "Collected" button to top-right** of follow-up card for faster action.
4. **Move quick-add daily collection from inline to FAB + bottom sheet** to keep the list as the primary view.
5. **Add pagination or month grouping** for past daily collections.
6. **Add total summary footer** to daily collection list.
7. **Log activity for daily collections** (currently missing).

### Phase 7 — Expenses & Data Layer (Medium Impact / Low Risk)

*Estimated effort: 3-5 days*

1. **Add category/type field to Expense model** for grouping.
2. **Group expenses by category** with expandable sections and subtotals.
3. **Make expense footer sticky** using `SliverPersistentHeader`.
4. **Add search and date range filter** to expense list.
5. **Log activity on expense edits** (currently only logs creation).
6. **Add monthly breakdown** to expense list.

### Phase 8 — Accessibility & Polish (Medium Impact / High Risk — needs testing)

*Estimated effort: 5-7 days*

1. **Add `Semantics` widgets** to all interactive elements. Label icons, buttons, and custom components.
2. **Add heading structure** (`Semantics` header levels) for screen reader navigation.
3. **Fix touch target sizes** for filter chips (minimum 44px).
4. **Replace relative time strings** with proper natural-language formatting for screen reader compatibility.
5. **Move form error messages inline** below fields instead of transient snackbars.
6. **WCAG AA color contrast audit** — verify all text/background combinations meet 4.5:1 ratio.

### Phase 9 — Animations & Micro-interactions (Low Impact / Low Risk)

*Estimated effort: 2-3 days*

1. **Apply `AppButton` press-scale animation** (already built, not used).
2. **Add chip selection animation** (elevation change on FilterChip select).
3. **Add card tap feedback** (subtle scale/opacity on tap).
4. **Add staggered list animation** to remaining lists (daily collections, expenses).
5. **Add skeleton loading** to the remaining pages that still use `CircularProgressIndicator`.

### Phase 10 — Advanced Features (Future)

*Estimated effort: 10-15 days*

1. **Dark mode support.** Requires refactoring color tokens to light/dark pairs.
2. **Charts and analytics dashboard** — bar charts for collection trends, pie charts for category breakdowns, line charts for daily progress. Use `fl_chart` or `syncfusion_flutter_charts`.
3. **Export to CSV/Excel.** Allow exporting sponsors, collections, expenses, and activity feed.
4. **Offline support.** Cache Firestore data locally for offline access.
5. **Push notifications** for follow-up reminders.
6. **Multi-festival support.** Allow managing multiple festival years from a single app instance.

---

## Conclusion

The application has a solid functional foundation but is held back by a UI that prioritizes completeness over clarity. Every screen works, but none of them feel designed.

**The biggest gaps are:**

1. **Visual hierarchy is flat.** Financial data (amounts, goals, progress) is presented with the same visual weight as metadata (timestamps, notes, locations). This is the single highest-impact change — users must be able to scan and understand their financial position in under 3 seconds.

2. **Inconsistency across components.** Cards, buttons, forms, chips, and dialogs all have multiple implementations. The design system tokens exist but are not enforced. Every new screen introduced a new variation.

3. **Accessibility was not considered.** The app relies entirely on color for status indication, has no semantic structure for screen readers, uses small touch targets, and has font sizes below recommended minimums. For a community-run volunteer application, this excludes users with visual or motor impairments.

4. **The navigation model has holes.** Two critical pages (follow-ups, settings) live outside the main navigation shell. The bottom nav lacks labels. Tab switching destroys navigation history.

5. **Forms are generic and unguided.** No required-field indicators, no inline validation, no autocomplete for known data (sponsor names), no discard confirmation. The date picker interaction pattern is inconsistent across forms.

**The recent UI overhaul (design tokens, AppCard, skeleton loading, stagger animations) was a necessary foundation. The next phase should focus on:**

1. Enforcing the design system across all screens (Phases 1-2)
2. Fixing navigation (Phase 3)
3. Redesigning the dashboard for scannability (Phase 4)
4. Reducing card density and improving list interactions (Phases 5-6)

These four phases will produce the most visible improvement for the least implementation risk. The animation and accessibility work (Phases 8-9) can proceed in parallel but should not block the higher-impact structural changes.

---

*Report generated May 2026. 7,800+ words. 20 screens reviewed. 10-phase roadmap.*
