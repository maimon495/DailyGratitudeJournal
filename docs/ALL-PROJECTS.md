# All dev projects — handoff index

_Snapshot 2026-10-01, written when moving to a new Claude account. Each repo below
has its own `STATUS.md` (this repo: `STATUS.md` + `CLAUDE.md`)._

| Project | Repo | State | Next |
|---|---|---|---|
| **Quill: Gratitude Journal** (iOS) | `DailyGratitudeJournal` | 1.0 (18) in App Review | Approval → link AdMob → verify banner |
| **subway-agent** (transit AI backend) | `subway-agent` | Live on Cloud Run; active through 2026-09-28 | See its STATUS.md |
| **MTAGPT** (iOS client for subway-agent) | `MTAGPT-IOS` (private) | TestFlight build 3, expires 2026-12-24 | Move hardcoded key out before any public release |
| **pebble-index-webhook** | `pebble-index-webhook` | Built and published 2026-09-15 | Maintenance only |
| **Developer site** | `maimon495.github.io` | Live; hosts `app-ads.txt` + privacy policy | Rename "Daily Gratitude Journal" → Quill |
| **ThreadKeeper** | `Threadkeeper` (private) | Built; last change 2026-06-17 | Deploy to Railway if still wanted |
| **LIRR Radar** | `LIRR-Radar` (private) | ⚠️ **Code lost** — repo is empty | Rebuild from spec in its STATUS.md, or find another copy |
| Subway-Agent-V2 | `Subway-Agent-V2` | Superseded by `subway-agent` (Feb 2026) | Archive |
| Meter-to-Cash | `Meter-to-Cash` (private) | StackBlitz scaffold, Mar 2026 | Archive or revive |
| PickleballCoordinator (iOS) | `PickleballCoordinator` | Initial commit only, Jan 2026 | Archive or revive |

## Shared local-only setup (not in any repo)
- `~/.appstoreconnect/` — App Store Connect API key (`SZA976J3UV`) and status tool.
  Used by Quill and MTAGPT. Secret; never commit.
- Apple developer team `F669HYU266`.
- `gcloud` logged in as the personal Google account; project `subway-agent-nyc`.
- Claude memory and scheduled tasks are per-account and do not carry over.

## Working preferences
- Feature branch + PR, never commit to `main`; Brian merges.
- Do work end to end; only hand back secrets, spending, irreversible outward-facing
  actions and product calls.
