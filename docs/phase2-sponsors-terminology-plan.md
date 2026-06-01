# Phase 2 — Sponsors Terminology Migration Plan

> Created: 2026-06-01
> Branch: `terminology-phase-1` (Phase 1.1 complete)
> Next step: Awaiting approval to create `terminology-phase-2` branch
> Status: Planning document — do not implement

---

## Dashboard Context After Phase 1.1

Current dashboard terminology for reference:

| Location | Label | Status |
|---|---|---|
| HeroCard — section | Festival Mission | ✅ Phase 1 |
| HeroCard — amount label | Raised | ✅ Phase 1 |
| HeroCard — target line | Goal: ₹{amount} | ✅ Phase 1 |
| HeroCard — remaining text | ₹{amount} to reach | ✅ Phase 1.1 |
| HeroCard — metric row | Sponsors / Raised / Pending / Goal Left | ⚠️ Mixed (Phase 1 + untouched) |
| KPI — card 1 | Today's Collection | 🔄 Reverted (Phase 1.1) |
| KPI — card 2 | Pending Sponsors | ❌ Untouched (Phase 2 target) |
| KPI — card 3 | Expenses | ❌ Untouched (Phase 3 target) |
| KPI — card 4 | Next Visits | ✅ Phase 1 |
| Chart header | Progress Trend | ✅ Phase 1 |
| Feed header | Activity Feed | ✅ Phase 1 |

---

## Per-Term Migration Plan

---

### 1. Expected → Commitment

| Property | Value |
|---|---|
| **Reason** | "Expected" sounds uncertain / corporate. "Commitment" frames the sponsor's pledge as a promise, aligning with festival mission language. |
| **Occurrences** | **6 total** across 4 files |

| File | Line | Current Text | Context |
|---|---|---|---|
| `collection_list_page.dart` | 321 | `'Expected: ₹{amount}'` | Quick-update dialog text |
| `collection_tile.dart` | 208 | `'Expected'` | Amount block label on card |
| `collection_detail_page.dart` | 71 | `'Expected: ₹{amount}'` | Receive amount bottom sheet |
| `collection_detail_page.dart` | 278 | `'Expected'` | Amount row label |
| `collection_form_page.dart` | 99 | `'Expected Sponsorship'` | Form field label |
| `collection_form_page.dart` | 110 | `'Expected sponsorship is required'` | Validation message |

| Risk Level | Visual Impact |
|---|---|
| **Low** — All occurrences are UI labels with no database/code dependencies. "Expected Sponsorship" (form field) becomes "Commitment Amount" — both are clearly input fields. | **Medium** — Sponsor cards currently show `Expected: ₹10,000`. Changing to `Commitment: ₹10,000` shifts the mental model from accounting to stewardship. Every sponsor card and detail page will display this change. |

**Validation to check:** None of these strings appear in shared widgets (metric cards, empty states, etc.) — they are all inside sponsor-specific widgets. Low collision risk.

---

### 2. Received → Raised

| Property | Value |
|---|---|
| **Reason** | Align with Phase 1 "Raised" on the dashboard. Consistency across the app. "Received" is passive accounting; "Raised" is active fundraising. |
| **Occurrences** | **6 total** across 4 files |

| File | Line | Current Text | Context |
|---|---|---|---|
| `collection_list_page.dart` | 308 | `'Update Received Amount'` | Dialog title |
| `collection_list_page.dart` | 331 | `'Received Amount'` | Dialog text field label |
| `collection_tile.dart` | 215 | `'Received'` | Amount block label on card |
| `collection_detail_page.dart` | 287 | `'Received'` | Amount row label |
| `collection_form_page.dart` | 123 | `'Received Amount'` | Form field label |
| `collection_form_page.dart` | 134 | `'Received amount is required'` | Validation message |

| Risk Level | Visual Impact |
|---|---|
| **Low-Medium** — The form field "Received Amount" is a label for user input. Changing it to "Amount Raised" or "Raised Amount" is clear. The card labels change from `Received: ₹4,000` to `Raised: ₹4,000`. | **High** — Every sponsor card, detail page, and form shows this. Directly visible to all users. Creates consistency with the dashboard HeroCard "Raised" label. |

**⚠️ Conflict to resolve:** The "Received Amount" label appears in two different form contexts:
- `collection_form_page.dart` (Add/Edit Sponsor form — an input field where the user enters the amount)
- `collection_list_page.dart` (Quick-update dialog — also an input field)

Both should change consistently. Proposed: **"Amount Raised"** for input fields, **"Raised"** for display labels.

---

### 3. Remaining → Opportunity

| Property | Value |
|---|---|
| **Reason** | "Remaining" is neutral to slightly negative (what's left, what's undone). "Opportunity" frames it as potential — positive and forward-looking. |
| **Occurrences** | **3 total** across 3 files |

| File | Line | Current Text | Context |
|---|---|---|---|
| `collection_list_page.dart` | 171 | `'Remaining'` | Metric card label |
| `collection_tile.dart` | 224 | `'Remaining'` | Amount block label on card |
| `collection_detail_page.dart` | 295 | `'Remaining'` | Amount row label |

| Risk Level | Visual Impact |
|---|---|
| **Low** — Only 3 occurrences, all display-only labels. No form fields or validation messages involved. | **Medium** — Every sponsor card currently shows `Remaining: ₹6,000`. Changing to `Opportunity: ₹6,000` is the most noticeable terminology shift in Phase 2. May briefly confuse users who are used to "Remaining". |

**⚠️ Dashboard note:** The KPI Grid still shows `₹{amount} remaining` on the "Pending Sponsors" card (trend text, not yet changed in Phase 1). This should also be updated to "opportunity" or "to reach" during Phase 2 to avoid inconsistency with sponsor cards.

---

### 4. Not Started → Ready

| Property | Value |
|---|---|
| **Reason** | "Not Started" is neutral but implies a to-do list. "Ready" implies preparedness and forward action. The sponsor is ready to be engaged. |
| **Occurrences** | **1 total** across 1 file |

| File | Line | Current Text | Context |
|---|---|---|---|
| `collection_tile.dart` | 27 | `'Not Started'` | Status chip label in `_statusLabel()` switch |

| Risk Level | Visual Impact |
|---|---|
| **Lowest** — Single occurrence in a private enum mapping function. No external dependencies. | **Low** — Only visible on sponsor cards where the sponsor has given zero amount. Lower-traffic state. |

---

### 5. Pending → Active

| Property | Value |
|---|---|
| **Reason** | "Pending" sounds like a backlog / administrative queue. "Active" implies work is in progress. More energizing. Aligns with the goal of progress language. |
| **Occurrences** | **4 total** across 3 files |

| File | Line | Current Text | Context |
|---|---|---|---|
| `collection_list_page.dart` | 161 | `'Pending'` | Metric card label |
| `collection_list_page.dart` | 241 | `'Pending'` | Filter chip label |
| `collection_tile.dart` | 28 | `'Pending'` | Status chip label |
| `collection_detail_page.dart` | 559 | `'Pending'` | Visit history row status |

| Risk Level | Visual Impact |
|---|---|
| **Medium** — See conflict note below. The term "Pending" is **not unique to sponsors**. It also appears in the dashboard HeroCard metric row (line 360 — untouched in Phase 1), the "Pending Sponsors" KPI card (line 519), and in the visits section (followup_list_page.dart). A partial rename could create **inconsistencies across pages**. | **High** — The sponsor filter chip "Pending" → "Active" is the most visible change. Users filtering sponsors will see the label change. |

**⚠️ Cross-section conflict — HIGH IMPORTANCE:**

"Pending" appears in 3 distinct contexts across the app:
1. **Sponsor status** (Phase 2 target) — partial collection, active engagement
2. **Dashboard metric** (HeroCard line 360) — `_Metric(label: 'Pending', ...)` — was intentionally left as-is in Phase 1
3. **Visit status** (followup_list_page.dart) — `'Pending'` visit status labels

A decision is needed:
- Option A: **Rename all "Pending" → "Active"** across sponsor + dashboard + visits (creates full consistency but Phase 2 scope bleeds into visits)
- Option B: **Rename only sponsor "Pending" → "Active"** and defer dashboard/visits (creates temporary inconsistency)
- Option C: **Keep "Pending" for now** and include it in a later phase that covers all three contexts simultaneously

**Recommendation: Option A** — it's only ~8 total occurrences across 4 files. Renaming them all in one phase prevents mid-project inconsistency.

---

### 6. Collected → Achieved

| Property | Value |
|---|---|
| **Reason** | "Collected" is transactional (money was picked up). "Achieved" is celebratory (a milestone was reached). Aligns with mission language for completed sponsors. |
| **Occurrences** | **5 total** across 3 files |

| File | Line | Current Text | Context |
|---|---|---|---|
| `collection_list_page.dart` | 151 | `'Collected'` | Metric card label |
| `collection_list_page.dart` | 248 | `'Collected'` | Filter chip label |
| `collection_tile.dart` | 29 | `'Collected'` | Status chip label |
| `collection_detail_page.dart` | 92 | `'e.g. Collected by Sanjay'` | Note field placeholder (hint text) |
| `collection_detail_page.dart` | 560 | `'Collected'` | Visit history row status |

| Risk Level | Visual Impact |
|---|---|
| **Low-Medium** — The hint text `'e.g. Collected by Sanjay'` may need to change to avoid using "Achieved" in a note example (sounds awkward: "e.g. Achieved by Sanjay"). Consider changing to `'e.g. Received from Sanjay'` or simply removing the example. | **Medium** — The filter chip "Collected" → "Achieved" and the status chip on fully paid sponsors are the most visible changes. The hint text change is minor. |

**⚠️ Conflict to resolve:** The hint text `'e.g. Collected by Sanjay'` on line 92 of `collection_detail_page.dart` uses "Collected" as a verb example in a free-text note field. This should probably change to `'e.g. Received from Sanjay'` or `'e.g. Paid by Sanjay'` rather than forcing "Achieved" into a sentence context.

---

## Summary Table

| Current Term | Proposed Term | Occurrences | Files | Risk | Dashboard Alignment |
|---|---|---|---|---|---|
| Expected | Commitment | 6 | list, tile, detail, form | Low | New term (no dashboard overlap) |
| Received | Raised | 6 | list, tile, detail, form | Low-Medium | ✅ Aligns with HeroCard "Raised" |
| Remaining | Opportunity | 3 | list, tile, detail | Low | ⚠️ HeroCard uses "to reach" / "Goal Left" — different terms for same concept |
| Not Started | Ready | 1 | tile | Low | N/A |
| Pending | Active | 4 | list, tile, detail | Medium | ⚠️ Also appears in HeroCard metric + KPI + visits. Needs cross-phase coordination. |
| Collected | Achieved | 5 | list, tile, detail | Low-Medium | ⚠️ HeroCard uses "Raised" for amount. "Achieved" is a status label, not an amount. Different contexts — acceptable. |

---

## Total Phase 2 Scope

| Metric | Count |
|---|---|
| Terms to rename | 6 |
| Total occurrences | **25** |
| Files affected | 4 (`collection_list_page.dart`, `collection_tile.dart`, `collection_detail_page.dart`, `collection_form_page.dart`) |
| New terms shared with Phase 1 | 1 ("Raised" — consistent with dashboard) |
| Cross-phase conflicts to resolve | 1 ("Pending" appears in dashboard + visits) |
| Hint text to adjust | 1 (`'e.g. Collected by Sanjay'`) |

---

## Pre-Implementation Decisions Needed

1. **"Pending" → "Active"** — Rename across all contexts (sponsor + dashboard + visits) in Phase 2, or defer the dashboard/metric row to a later phase?
2. **"Received Amount" form field** — Use "Amount Raised" or "Raised Amount" for the input label?
3. **"Collected" hint text** — Change `'e.g. Collected by Sanjay'` to `'e.g. Received from Sanjay'` or remove the example?
4. **"Remaining" KPI trend overlap** — The KPI Grid still shows "₹{amount} remaining" on the Pending Sponsors card. Should this be updated in Phase 2 or Phase 3?
5. **"Sponsors" page title** — No change proposed. The entity name "Sponsor" stays as-is. Confirm this is intentional.

---

## Map of All Sponsor-Facing Strings After Phase 2 (Projected)

| UI Element | Current Text | Phase 2 Text |
|---|---|---|
| Page title | Sponsors | Sponsors (unchanged) |
| Metric card | Total Sponsors | Total Sponsors (unchanged) |
| Metric card | Collected | Achieved |
| Metric card | Pending | Active |
| Metric card | Remaining | Opportunity |
| Filter chip | All | All (unchanged) |
| Filter chip | Pending | Active |
| Filter chip | Collected | Achieved |
| Search placeholder | Search sponsors... | Search sponsors... (unchanged) |
| Empty state | No sponsors yet / Tap + to add your first sponsor | Unchanged |
| Card — status | Not Started / Pending / Collected | Ready / Active / Achieved |
| Card — amount | Expected / Received / Remaining | Commitment / Raised / Opportunity |
| Card — action | Collect / Visit / View | Collect (unchanged) / Visit (unchanged) / View (unchanged) |
| Card — menu | Edit / Delete | Unchanged |
| Detail — amount row | Expected / Received / Remaining | Commitment / Raised / Opportunity |
| Detail — button | Receive Amount | Record Contribution (or keep) |
| Detail — sheet title | Receive Amount | Record Contribution (or keep) |
| Detail — tooltips | Add Visit / Edit Sponsor / Delete Sponsor | Unchanged |
| Detail — hint | e.g. Collected by Sanjay | e.g. Received from Sanjay |
| Detail — overdue | {n} visit(s) overdue | (deferred to visits phase) |
| Form — appbar | Add Sponsor / Edit Sponsor | Unchanged |
| Form — field | Expected Sponsorship | Commitment Amount |
| Form — field | Received Amount | Amount Raised |
| Form — field | Notes (optional) | Unchanged |
| Form — validation | Expected sponsorship is required / Enter a valid amount / Received amount is required | Commitment amount is required / Enter a valid amount / Amount raised is required |
| Form — button | Add Sponsor / Update Sponsor | Unchanged |
| Quick-update dialog | Update Received Amount | Record Contribution |
| Quick-update dialog | Expected: ₹{amount} | Commitment: ₹{amount} |
| Quick-update dialog | Received Amount | Amount Raised |
| Delete dialog | Delete Sponsor | Unchanged |

---

## Implementation Order (for Phase 2 branch)

1. `collection_tile.dart` — Status labels + amount block labels (highest visibility)
2. `collection_list_page.dart` — Metric cards + filter chips + dialog
3. `collection_detail_page.dart` — Amount rows + sheet title + hint text
4. `collection_form_page.dart` — Form field labels + validation messages
5. Verify consistency with dashboard HeroCard metric row and KPI "Pending Sponsors" labels

---

**This document is a planning artifact only. Do not implement until approved.**
