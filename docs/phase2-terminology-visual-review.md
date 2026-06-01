# Phase 2 — Terminology Visual Review

> Created: 2026-06-01
> Status: Design review only — no code changes

---

## Review Method

Every Phase 2 term evaluated in its actual UI context across 5 files (33 total occurrences). Terms inherited from Phase 1 are reviewed for completeness but not part of the Phase 2 scope.

---

## Term-by-Term Review

---

### 1. Commitment

| Property | Value |
|---|---|
| Screen(s) | Sponsor Card, Sponsor List (dialog), Sponsor Detail, Add/Edit Form |
| Context | Amount label (expected target), form field, validation message |
| Example Renders | `Commitment ₹10,000` · `Commitment Amount` · `Commitment: ₹10,000` |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **8/10** |
| Professional? | **9/10** |
| **Verdict** | **Keep** |

**Notes:** Strong replacement for "Expected". Frames the target as a pledge rather than a prediction. Pairs naturally with "Raised" on the same card. No ambiguity — volunteers understand it as "the amount the sponsor committed to."

---

### 2. Amount Raised

| Property | Value |
|---|---|
| Screen(s) | Sponsor List (dialog), Add/Edit Form |
| Context | Form field label for entering collected amount |
| Example Renders | `Amount Raised` (TextField label) |
| Looks Natural? | Yes |
| Too Long? | Slightly (13 chars vs "Received" at 8) |
| Clear To First-Time Volunteer? | **8/10** |
| Professional? | **9/10** |
| **Verdict** | **Keep** |

**Notes:** Clear input label. A volunteer sees "Amount Raised" and knows to enter the money collected. Matches the dashboard "Raised" terminology. Better than "Received Amount" which sounded passive.

---

### 3. Raised

| Property | Value |
|---|---|
| Screen(s) | Sponsor Card, Sponsor Detail, Dashboard HeroCard |
| Context | Display label for collected amount |
| Example Renders | `Raised ₹4,000` (sponsor card) · `Raised ₹1,50,000` (HeroCard) · `₹4,000 of ₹10,000 raised (40%)` (progress text) |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **9/10** |
| Professional? | **9/10** |
| **Verdict** | **Keep** |

**Notes:** Best Phase 2 change. Active, energizing language. Creates consistent terminology from sponsor card to dashboard. The progress text `₹4,000 of ₹10,000 raised (40%)` reads naturally as English.

---

### 4. Opportunity

| Property | Value |
|---|---|
| Screen(s) | Sponsor Card, Sponsor List (metric card), Sponsor Detail |
| Context | Amount label (what's left to collect) |
| Example Renders | `Opportunity ₹6,000` (sponsor card) · `Opportunity 3` (metric card) |
| Looks Natural? | **No** |
| Too Long? | No |
| Clear To First-Time Volunteer? | **5/10** |
| Professional? | **7/10** |
| **Verdict** | **Modify → "To Reach"** |

**Review notes:**

**Sponsor Card context:** The amounts row shows three columns:
```
Commitment    Raised    Opportunity
₹10,000       ₹4,000    ₹6,000
```

"Opportunity ₹6,000" does not immediately communicate "this is the amount still to collect." A volunteer scanning the card sees three labels: first is the commitment, second is what's raised, third is... an abstract concept. The positive reframe loses clarity.

**Metric card context:**
```
Opportunity
3
```
In the sponsor list summary grid, "Opportunity 3" could mean "3 potential opportunities for fundraising" rather than "3 sponsors with remaining amounts."

**"To Reach" vs "Opportunity":** "To Reach" maps directly to the action needed. The HeroCard already uses `₹{amount} to reach` for the same concept (line 359, Phase 1.1). Changing the sponsor card from "Opportunity" to "To Reach" creates consistency:
- HeroCard: `₹30,000 to reach`
- Sponsor Card: `To Reach ₹6,000`
- Metric Card: `To Reach 3`

| Alternative | Score | Reason |
|---|---|---|
| **To Reach** | 9/10 | Consistent with HeroCard. Action-oriented. |
| Opportunity | 5/10 | Abstract. Not immediately clear. |
| Outstanding | 8/10 | Clear accounting term but feels corporate. |
| Remaining | 7/10 | Familiar but neutral/negative. Already changed. |

**Recommendation: Replace "Opportunity" → "To Reach"** across all 3 occurrences.

---

### 5. Active

| Property | Value |
|---|---|
| Screen(s) | Sponsor Card (status chip), Sponsor List (filter chip + metric card), Dashboard (HeroCard metric) |
| Context | Status label for partially-collected sponsors |
| Example Renders | `Active` (chip) · `Active 3` (metric) · `Active 24` (HeroCard) |
| Looks Natural? | Yes |
| Too Long? | No (shorter than "Pending") |
| Clear To First-Time Volunteer? | **8/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep** |

**Notes:** "Active" works well as a status. The three-status progression is clear: Ready → Active → Achieved. Minor concern: on the dashboard HeroCard metric row, `Active 24` could be ambiguous without context (active what?). But surrounded by "Sponsors" and "Raised" metrics, it's clear in context.

---

### 6. Achieved

| Property | Value |
|---|---|
| Screen(s) | Sponsor Card (status chip), Sponsor List (metric card + filter chip) |
| Context | Status label for fully-collected sponsors |
| Example Renders | `Achieved` (chip) · `Achieved 18` (metric) |
| Looks Natural? | **Marginally** |
| Too Long? | No |
| Clear To First-Time Volunteer? | **7/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep** |

**Notes:** "Achieved" is celebratory and fits the mission language. However, on a sponsor card, the adjacent amounts show `Raised ₹10,000` while the status says `Achieved`. A fast-reading volunteer might parse "Achieved" as "the sponsor achieved their goal" which is correct. Minor risk: a new volunteer might think "Achieved" means "the volunteer achieved something" rather than "payment is complete." Acceptable trade-off for mission-aligned language.

---

### 7. Record Contribution

| Property | Value |
|---|---|
| Screen(s) | Sponsor Detail (button + bottom sheet), Sponsor List (dialog) |
| Context | Action label for recording a payment |
| Example Renders | `[ Record Contribution ]` (FilledButton) · Dialog title |
| Looks Natural? | Yes |
| Too Long? | Slightly (19 chars vs "Receive Amount" at 14) |
| Clear To First-Time Volunteer? | **8/10** |
| Professional? | **9/10** |
| **Verdict** | **Keep** |

**Notes:** "Record Contribution" is more professional and broader than "Receive Amount." A volunteer understands "I need to record the contribution this sponsor made." Minor length concern — the button text is wider, but the button already uses `FilledButton.icon` with adequate padding.

---

### 8. Active Sponsors

| Property | Value |
|---|---|
| Screen(s) | Dashboard KPI Grid (second card) |
| Context | KPI card label showing sponsors with partial collections |
| Example Renders | `Active Sponsors` · `₹1,20,000 still to reach` |
| Looks Natural? | Yes |
| Too Long? | No (same length as "Pending Sponsors") |
| Clear To First-Time Volunteer? | **6/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep with note** |

**Notes:** The label "Active Sponsors" is slightly ambiguous — it could mean "currently active/engaged sponsors" rather than "sponsors with remaining amounts." However, the trend text `₹1,20,000 still to reach` provides clarifying context. The KPI card's full reading is:
```
Active Sponsors
24
₹1,20,000 still to reach
```
The trend text disambiguates the label. Consider this a pass for now. If usage data shows confusion, rename to "In Progress" later.

---

### 9. Goal Left

| Property | Value |
|---|---|
| Screen(s) | Dashboard HeroCard (metric row) |
| Context | Metric label in the bottom row of HeroCard |
| Example Renders | `Goal Left    ₹30,000` |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **9/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep** (Phase 1.1 — no change needed) |

---

### 10. Festival Mission

| Property | Value |
|---|---|
| Screen(s) | Dashboard HeroCard (section header) |
| Context | Section label above the progress bar |
| Example Renders | `Festival Mission` · `72.5% complete` |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **9/10** |
| Professional? | **9/10** |
| **Verdict** | **Keep** (Phase 1 — no change needed) |

---

### 11. Next Visits

| Property | Value |
|---|---|
| Screen(s) | Dashboard KPI Grid (fourth card) |
| Context | KPI label for upcoming follow-up visits |
| Example Renders | `Next Visits` · `24` · `Needs visit` |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **9/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep** (Phase 1 — no change needed) |

---

### 12. Progress Trend

| Property | Value |
|---|---|
| Screen(s) | Dashboard chart section |
| Context | Section header for 14-day collection chart |
| Example Renders | `Progress Trend` · `14 days` |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **8/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep** (Phase 1 — no change needed) |

---

### 13. Activity Feed

| Property | Value |
|---|---|
| Screen(s) | Dashboard timeline section |
| Context | Section header for recent activity list |
| Example Renders | `Activity Feed` |
| Looks Natural? | Yes |
| Too Long? | No |
| Clear To First-Time Volunteer? | **9/10** |
| Professional? | **8/10** |
| **Verdict** | **Keep** (Phase 1 — no change needed) |

---

## Summary

### Terms That Should Remain

| Term | Reason |
|---|---|
| Commitment | Clear, professional, pairs well with Raised |
| Amount Raised | Clear input label, matches dashboard |
| Raised | Best change. Consistent across all screens. |
| Active | Works as status. Good progression with Ready/Achieved. |
| Achieved | Celebratory, mission-aligned. Acceptable clarity trade-off. |
| Record Contribution | Professional, unambiguous action label. |
| Goal Left | Already validated in Phase 1.1. |
| Festival Mission | Already validated in Phase 1. |
| Next Visits | Already validated in Phase 1. |
| Progress Trend | Already validated in Phase 1. |
| Activity Feed | Already validated in Phase 1. |

### Terms That Should Be Modified

| Term | Current | Proposed | Occurrences | Reason |
|---|---|---|---|---|
| Opportunity | `Opportunity` | **`To Reach`** | 3 | Abstract label. "To Reach" is action-oriented and consistent with HeroCard `₹{amount} to reach` (Phase 1.1). |

### Terms That Should Be Reverted

**None.** All Phase 2 terminology is an improvement over the original.

### Terms Flagged for Future Monitoring

| Term | Concern | Action |
|---|---|---|
| Active Sponsors (KPI) | Mild ambiguity. Could mean "currently active" vs "in progress." | Keep for now. Monitor volunteer feedback. Trend text disambiguates. |
| Achieved (status) | "Achieved" on a sponsor card with amount shows "Raised ₹10,000" and status "Achieved" — two different terms for the same concept. | Acceptable. Different contexts (metric vs status). Keep. |

---

## Proposed Modification Detail

### Opportunity → To Reach (3 occurrences)

**File 1: `collection_tile.dart:224`**
```dart
// Before:
label: 'Opportunity',
// After:
label: 'To Reach',
```

**File 2: `collection_list_page.dart:171`**
```dart
// Before:
label: 'Opportunity',
// After:
label: 'To Reach',
```

**File 3: `collection_detail_page.dart:295`**
```dart
// Before:
label: 'Opportunity',
// After:
label: 'To Reach',
```

**Expected rendering after change:**

| Context | Before | After |
|---|---|---|
| Sponsor Card | `Commitment ₹10,000` `Raised ₹4,000` `Opportunity ₹6,000` | `Commitment ₹10,000` `Raised ₹4,000` `To Reach ₹6,000` |
| Metric Card | `Opportunity 3` | `To Reach 3` |
| Sponsor Detail | `Opportunity ₹6,000` | `To Reach ₹6,000` |

**Consistency check:** The HeroCard already uses `₹{amount} to reach` (dashboard_page.dart:359). Changing the sponsor-domain "Opportunity" to "To Reach" creates full consistency:
- Dashboard HeroCard: `₹30,000 to reach`
- Sponsor card amount label: `To Reach ₹6,000`
- Sponsor list metric: `To Reach 3`

---

## Overall Terminology Score

| Category | Score |
|---|---|
| Clarity | **8.5/10** |
| Professionalism | **8.5/10** |
| Consistency | **7.5/10** → **8.5/10** (after Opportunity → To Reach) |
| Mission Alignment | **9/10** |
| **Overall** | **8.4/10** |

---

## Go/No-Go for Implementation

**GO** — Proceed with implementation after applying the single modification:
1. Change `Opportunity` → `To Reach` (3 occurrences)

No reversion needed. No other modifications required.

**Ready to proceed to Visits terminology phase after the Opportunity fix is applied.**

---

*End of review — no code changes have been made.*
