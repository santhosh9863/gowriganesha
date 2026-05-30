# Bug Log

> Track bugs, workflow friction, and UX issues discovered during testing.
> Last updated: 30 May 2026

---

## Critical Bugs

_(None yet)_

---

## Major Bugs

- **Follow-Up History ignores legacy follow-ups**
  `collection_detail_page.dart:158` filters by `sponsorId == target.id`. Follow-ups created before the sponsor detail page existed have `sponsorId = ''` (model default). These legacy items never appear on the detail page.
  *Fix need:* Fallback to matching by `sponsorName` when `sponsorId` is empty.

- **Activity feed not reverted on UNDO**
  `followup_list_page.dart:151` writes a `followup_completed` activity immediately. If the user taps UNDO (SnackBar), the follow-up status reverts but the activity remains. The feed shows a completion that was undone.
  *Fix need:* Delete the activity on UNDO, or defer activity write until UNDO timeout expires (3s delay).

---

## Minor Bugs

- **Empty sponsorId in follow-up form**
  `followup_form_page.dart` passes `_sponsorId` when creating a follow-up from the detail page. But when creating directly from the FAB on the Follow-Ups list page, `_sponsorId` remains `''`. New orphan follow-ups with no link to any sponsor are easy to create accidentally.
  *Fix need:* Make `sponsorId` required in the form, or show a warning when it's empty.

- **Future timestamps show as "Updated X days ago"**
  `collection_tile.dart` `_relativeTime()` does not check if the timestamp is in the future. A sponsor with `updatedAt` set to a future date shows "Updated -3 days ago" or misleading text.
  *Fix need:* Add a `diff.isNegative` check: show "Updated just now" for future timestamps.

- **Activity stream reads all documents**
  `firestore_service.dart` `watchActivities` has no limit. Over months of use, the stream will read every activity document ever created. The dashboard only displays 20 items.
  *Fix need:* Add `.limit(50)` to the Firestore query to cap reads.

- **Filter chip style inconsistency**
  `collection_list_page.dart` uses Material `FilterChip` widgets. `followup_list_page.dart` uses custom styled `GestureDetector` + `Container` chips. Visual inconsistency between the two list pages.
  *Fix need:* Unify on one pattern (prefer Material `FilterChip`).

- **Progress bar overflow on zero expectedAmount**
  `collection_detail_page.dart:153-155` guards against `expectedAmount == 0` by defaulting progress to `0.0`. However the progress bar still renders with `value: 0.0` which is correct, but the percentage text shows `0%` — acceptable. No crash.

- **Note field not cleared after Quick Receive cancel**
  `collection_detail_page.dart` — `amountCtrl` and `noteCtrl` are disposed in all paths. Verified correct. No bug here. (False alarm.)

---

## UX Issues

- **Pending Sponsors filter lost on tab switch**
  Dashboard → Pending Sponsors card → `/collections?filter=pending`. If user switches to another bottom nav tab and returns, the query param is lost and the filter resets to "All". The user must re-navigate from Dashboard to re-apply the filter.
  *Suggestion:* Pass filter as a shared state (e.g., Riverpod provider) so it persists across tab switches, or keep it simple and accept the reset.

- **Activity items not tappable**
  Dashboard Recent Activity items have no `onTap`. Users expect to tap an activity (e.g., "Collection Recorded") to navigate to the related record. Currently it's read-only.
  *Suggestion:* Add `onTap` to navigate to the relevant page based on `activity.type`.

- **Receive Amount dialog has no max-width on desktop**
  The dialog stretches across the full width on wide screens. Amount input feels lost.
  *Suggestion:* Constrain dialog width, or use a bottom sheet on mobile.

- **Follow-Up History does not highlight overdue items**
  The detail page shows active follow-ups with a "Pending" badge but doesn't visually distinguish overdue ones (date in the past). The Pending Visits widget on Dashboard does this with a warning icon.
  *Suggestion:* Apply the same overdue styling (red/warning icon) to overdue items in the detail follow-up history.

- **No way to see all follow-ups for a sponsor from the list page**
  The Follow-Ups list page (`/followups`) shows all follow-ups globally. There's no way to filter by specific sponsor. If a volunteer wants to see all follow-ups for "Doctor", they must open the sponsor detail page.
  *Suggestion:* Add sponsor name search on the follow-ups list page, or make the sponsor name tappable to navigate to the detail page.

- **"Add Follow-Up" from detail page does not pre-fill sponsorId on edit**
  When navigating from detail page to `/followups/add?sponsorId=X`, the follow-up form correctly pre-fills the sponsor name and saves `sponsorId`. However, if the user later edits this follow-up, the edit form does not show or preserve the sponsorId (only reads from Firestore model, which does include it — verified). Actually this works correctly. (False alarm.)

---

## Future Ideas

- **Payment history collections** — Track each collection event as a separate record instead of accumulating into `givenAmount`.
- **Expense categories** — Group expenses by type (Pooja, Decoration, Food, etc.) for reporting.
- **Overdue follow-up notifications** — Alert volunteers when a follow-up date has passed without being marked collected.
- **Backup / export** — Download a CSV or PDF report of all sponsors, collections, expenses.
- **Multiple volunteers** — User login, attribution for activities ("Collected by Sanjay"), per-volunteer dashboard.
- **Sponsor notes** — Free-text notes attached to a sponsor (not just follow-ups).
- **Bulk mark collected** — Select multiple follow-ups and mark them collected in one action (e.g., after a festival event where many sponsors pay at once).
