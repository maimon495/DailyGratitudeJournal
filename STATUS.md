# Status — Quill: Gratitude Journal (DailyGratitudeJournal)

_Handoff snapshot, 2026-10-01. Detailed history and gotchas are in `CLAUDE.md`;
see `docs/ALL-PROJECTS.md` for every other project._

## Where it stands
- **In App Review.** Version 1.0, build 18, `WAITING_FOR_REVIEW` since 2026-09-30.
- App Store name **"Quill: Gratitude Journal"**, home-screen name **Quill**. Renamed
  from "Inkwell" after a **Guideline 5.2.5** rejection (Inkwell is an Apple term).
  The earlier **4.3(a) Spam** finding was not repeated. See `docs/app-review-5.2.5-response.md`.
- Release is set to **automatic**, so approval publishes the app.

## Next steps
1. Wait for review. Check with:
   `~/.appstoreconnect/tools/venv/bin/python ~/.appstoreconnect/tools/check_status.py`
   (must use the venv python; system python lacks `jwt`).
2. If rejected: Resolution Center text is not readable by API, so paste it into a
   session. Resubmitting can be done fully by API (see CLAUDE.md, "Or skip the web UI").
   If it is trademark again, the likely suspect is "Memories" (review notes + keywords).
3. On approval: **link the app in AdMob** (AdMob > Apps > "Link to app store"). This is
   what turns ads on; until then an empty banner is expected.
4. Confirm the banner renders on a real iPhone (Today screen). Never yet verified.
5. Update the developer site (`maimon495/maimon495.github.io`): it still says
   "Daily Gratitude Journal". Privacy policy URL must keep working.

## Not in git — lives only on the old Mac/account
| Item | Where | Notes |
|---|---|---|
| App Store Connect API key | `~/.appstoreconnect/private_keys/AuthKey_SZA976J3UV.p8` | Secret. Issuer `1fef01fb-08c0-4557-93ad-4be5d0467efb`. Re-download not possible; create a new key in App Store Connect > Users and Access > Integrations if lost. |
| Status script + venv | `~/.appstoreconnect/tools/check_status.py`, `venv/` | Uses `pyjwt`, `requests`, `cryptography`. |
| `GoogleService-Info.plist` | gitignored; copy in any `.xcarchive` under `~/Library/Developer/Xcode/Archives/` | Required to archive. Re-downloadable from Firebase console. |
| Claude scheduled tasks | `~/.claude/scheduled-tasks/quill-app-review-check` (daily 9am) and an older, stale `app-store-review-watch` | Recreate on the new account if wanted; delete the stale one. |

## Working preferences (from Claude memory)
- Work on a feature branch and open a PR; don't commit to `main`. Brian merges.
- Do the work end to end; only hand back secrets, spending, irreversible
  outward-facing actions, and product decisions (e.g. naming).
