# Phase 1 Terminology Review

> Created: 2026-06-01
> Branch: `terminology-phase-1`
> File: `lib/features/dashboard/dashboard_page.dart`
> Status: Pre-Phase 2 validation checkpoint

---

## Per-Term Analysis

---

### 1. Festival Mission

| Property | Value |
|---|---|
| **Original** | `Festival Goal` |
| **Location** | `_HeroCard` section label (line 277) — left of the percentage ring |
| **Context** | Paired with `"{n}% complete"` directly below |
| **User Understanding** | 8 / 10 — "Mission" is broadly understood in organizational contexts |
| **Clarity Score** | 7 / 10 — Slightly more abstract than "Goal". A volunteer scanning the dashboard might pause on "Festival Mission" and wonder "what mission?" |
| **Recommendation** | **Keep** with caveat. The word "Mission" works well for the festival fundraising purpose. However, if this label appears on a line by itself above a progress bar, consider whether the average volunteer immediately associates it with a fundraising target. |

- Pro: More purposeful than "Goal"
- Con: Slightly more abstract; could be perceived as corporate jargon if overused elsewhere

---

### 2. Raised

| Property | Value |
|---|---|
| **Original** | `Collected` |
| **Location** | Two places in `_HeroCard`: (a) label above the large amount display (line 303), (b) `_Metric` row label (line 358) |
| **Context** | Both show `db.collectedTotal` — a currency amount |
| **User Understanding** | 10 / 10 — Universally understood in fundraising |
| **Clarity Score** | 10 / 10 — Clear, unambiguous, familiar |
| **Recommendation** | **Keep**. This is the strongest change in Phase 1. "Raised" immediately communicates fundraising progress. |

- No downsides. Perfect fit for a festival fundraising platform.

---

### 3. Goal

| Property | Value |
|---|---|
| **Original** | `Target: ₹{amount}` |
| **Location** | `_HeroCard` line below the raised amount (line 320) |
| **Context** | Prefixed to the expected total: `"Goal: ₹50,00,000"` |
| **User Understanding** | 10 / 10 — Simple, clear, universal |
| **Clarity Score** | 10 / 10 — Reads naturally |
| **Recommendation** | **Keep**. Strict improvement over corporate-sounding "Target". |

- No downsides.

---

### 4. To Reach

| Property | Value |
|---|---|
| **Original** | `remaining` |
| **Location** | Two places in `_HeroCard`: (a) text line below the progress bar (line 341): `"₹{amount} to reach"`, (b) `_Metric` row label (line 362): `"To Reach"` |
| **Context** | (a) Paired with a small amount below the progress bar — secondary text. (b) The last of 4 column headers in the metric row: `Sponsors / Raised / Pending / To Reach` |
| **User Understanding** | 7 / 10 — "To reach" is a forward-looking phrase. Users understand it means "remaining until the goal", but the phrase requires a split-second of parsing. |
| **Clarity Score** | 6 / 10 — "Remaining" is instantly parsed. "To reach" is grammatically incomplete (what needs to be reached? The goal). The context provides the answer, but it's one extra brain cycle. |
| **Recommendation** | **Keep in line text, consider for metric label.** In full context (`"₹10,000 to reach"`), it reads naturally. As a standalone metric column header (`"To Reach"`), it's less clear — users may scan and momentarily misread it. Consider against alternatives. |

- Pro: Forward-looking, aspirational
- Con: Slightly ambiguous as a standalone column header
- Alternative considered: **"Remaining"** (original — neutral but backward-looking), **"Outstanding"** (corporate), **"Left"** (too casual), **"To Go"** (too informal)
- The line text `"₹{amount} to reach"` is stronger than the column header `"To Reach"`. Consider whether the column label should differ from the line text.

---

### 5. Today's Impact

| Property | Value |
|---|---|
| **Original** | `Today's Collection` |
| **Location** | `_KpiGrid` → first KPI card label (line 514) |
| **Context** | Top-left KPI card showing today's collection amount with entry count |
| **User Understanding** | 6 / 10 — "Impact" is abstract. A volunteer who just collected money sees "Today's Collection" and knows exactly what happened. "Today's Impact" requires interpretation — was the money impactful? Was something else impactful? |
| **Clarity Score** | 5 / 10 — "Collection" is concrete: money was collected. "Impact" is subjective and harder to measure. |
| **Recommendation** | **Revert.** Or keep the full context: keep "Today's Collection" as the label but pair it with the "Raised" terminology elsewhere. This KPI card displays a concrete financial figure (money collected today). "Impact" is too abstract for a precise amount display. The original "Today's Collection" was clear, neutral, and immediately understood. |

- **This is the riskiest change in Phase 1.** "Impact" works in mission statements but feels mismatched when paired with a precise rupee figure.
- If the goal is to elevate language, consider: **"Today's Progress"** (clearer than "Impact" but still forward-looking) or **keep "Today's Collection"** (it was never broken).

---

### 6. Next Visits

| Property | Value |
|---|---|
| **Original** | `Pending Visits` |
| **Location** | `_KpiGrid` → last KPI card label (line 533) |
| **Context** | Bottom-right KPI card showing a count with trend "Needs visit" |
| **User Understanding** | 9 / 10 — "Next" is universally understood as upcoming |
| **Clarity Score** | 9 / 10 — Clear improvement over administrative "Pending" |
| **Recommendation** | **Keep.** The change from "Pending" (backlog/negative) to "Next" (forward/neutral) is the clearest win. |

- Minor note: the KPI currently shows `db.pendingSponsorCount` — this counts sponsors with pending visits, not scheduled visits. The data model doesn't perfectly match "Next" (which implies a schedule). But for a KPI summary, this is acceptable.

---

### 7. Progress Trend

| Property | Value |
|---|---|
| **Original** | `Collection Trend` |
| **Location** | `_CollectionTrend` chart section header (line 763) |
| **Context** | Paired with "14 days" on the right — title for a line chart of daily collection amounts |
| **User Understanding** | 8 / 10 — "Progress" is clear and relevant |
| **Clarity Score** | 7 / 10 — "Progress Trend" is slightly redundant (progress implies movement over time). "Collection Trend" was more specific (you immediately knew it tracked collection amounts). "Progress" is broader but still fits since the chart shows contribution progress. |
| **Recommendation** | **Keep, but consider shortening.** "Progress Trend" → just **"Progress"** . The "Trend" part is redundant when followed by a line chart and the "14 days" label. |


- Alternative: Just **"Progress"** — shorter, cleaner, and the chart context makes the "trend" nature obvious.

---

### 8. Activity Feed

| Property | Value |
|---|---|
| **Original** | `Recent Activity` |
| **Location** | `_ActivityTimeline` section header (line 1000), with "Timeline" subtitle on the right |
| **Context** | Header for a list of recent actions (collections, expenses, visits) grouped by day |
| **User Understanding** | 9 / 10 — "Feed" is a modern UX pattern (news feed, activity feed) |
| **Clarity Score** | 8 / 10 — "Recent Activity" is more descriptive but wordier. "Activity Feed" is contemporary and shorter. |
| **Recommendation** | **Keep.** "Activity Feed" is cleaner and matches modern UI conventions. The existing "Timeline" subtitle provides additional context if needed. |

- Consider whether the redundant "Timeline" subtitle (line 1002) should be removed or repurposed now that the header itself is clearer.

---

## Inconsistency Analysis

The dashboard now has a **split terminology profile**. Some parts speak "impact language" and others still speak "administrative language".

### HeroCard

| Label | Status | Term Language |
|---|---|---|
| Festival Mission | ✅ Changed | Mission |
| Raised (amount) | ✅ Changed | Impact |
| Goal: ₹{amount} | ✅ Changed | Mission |
| ₹{amount} to reach | ✅ Changed | Impact |
| Sponsors | ❌ Untouched | Neutral |
| Raised (_Metric) | ✅ Changed | Impact |
| Pending (_Metric) | ❌ Untouched | Administrative |
| To Reach (_Metric) | ✅ Changed | Impact |

### KPI Grid

| Label | Status | Term Language |
|---|---|---|
| Today's Impact | ✅ Changed | Impact (newly applied) |
| {n} entries | ❌ Untouched | Administrative |
| Pending Sponsors | ❌ Untouched | Administrative |
| ₹{amount} remaining (trend) | ❌ Untouched | Administrative |
| Expenses | ❌ Untouched | Neutral |
| % of collected (trend) | ❌ Untouched | Administrative |
| Next Visits | ✅ Changed | Progress |
| Needs visit (trend) | ❌ Untouched | Neutral |

### Chart & Feed

| Label | Status | Term Language |
|---|---|---|
| Progress Trend | ✅ Changed | Progress |
| 14 days | ❌ Untouched | Neutral |
| Activity Feed | ✅ Changed | Modern |

### Impact of Inconsistencies

**1. HeroCard metric row reads awkwardly:**
```
Sponsors | Raised | Pending | To Reach
```
"Sponsors" and "Pending" (old vocabulary) sit right next to "Raised" and "To Reach" (new vocabulary). This creates visual/mental friction. A user sees the shift and may suspect a labeling error.

**2. KPI Grid has two updated labels and two untouched labels:**
```
Today's Impact  |  Pending Sponsors
(updated)       |  (old)

Next Visits     |  Expenses
(updated)       |  (old)
```
The top row is especially jarring: "Today's Impact" (abstract) next to "Pending Sponsors" (specific + administrative).

**3. "Pending" survives in the HeroCard metric row:**
The very component that received the most updates (`_HeroCard`) still displays "Pending" in the 3rd metric column. This is the most visible inconsistency on the page.

---

## Summary Recommendations

| Term | Decision | Rationale |
|---|---|---|
| Festival Mission | **Keep** | Purposeful, appropriate |
| Raised | **Keep** | Best change in Phase 1 |
| Goal | **Keep** | Clear improvement |
| To Reach (line) | **Keep** | Reads naturally in context |
| To Reach (metric) | **Keep with awareness** | Slightly ambiguous as standalone column header |
| Today's Impact | **Revert or modify** | Too abstract for a concrete financial KPI |
| Next Visits | **Keep** | Clear improvement |
| Progress Trend | **Keep; consider shortening to "Progress"** | Redundant with chart context |
| Activity Feed | **Keep** | Modern, clear |

---

## Pre-Phase 2 Action Items

Before expanding terminology changes to other sections:

1. **Resolve "Today's Impact"** — Revert to "Today's Collection" or find a middle ground like "Today's Progress".
2. **Address the HeroCard metric row inconsistency** — "Pending" should be updated alongside "Sponsors" once Phase 2 covers those terms.
3. **Align KPI Grid labels** — "Pending Sponsors" and "Expenses" will need to change in Phase 2-3 to match the new dashboard voice.
4. **Decide on "To Reach" as a column header** — If it feels ambiguous as a standalone label, consider shortening to "Reach" (verb-as-label) or keeping "Remaining" for column headers while using "to reach" in sentence context.

---

## Vote

Before starting Phase 2, confirm:

- [ ] All 8 terms reviewed and scored
- [ ] "Today's Impact" decision made (keep / revert / modify)
- [ ] Phase 2 scope refined based on inconsistencies discovered
- [ ] This document merged to `terminology-phase-1` branch
