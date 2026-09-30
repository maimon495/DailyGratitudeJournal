# App Review — Guideline 5.2.5 Legal: Intellectual Property

Apple rejected 1.0 (17) on 2026-09-29 under **Guideline 5.2.5**: the app name used
"Inkwell", which Apple treats as its own term — Inkwell is the handwriting
recognition built into macOS. The 4.3(a) Spam finding from build 16 was **not**
repeated, so the rename, recategorisation and keyword rewrite from
`app-review-4.3-response.md` appear to have cleared it.

Lesson: check a candidate name against Apple's own product and feature names, not
only against other App Store listings. Other words to avoid for this app: Scribble,
Pencil, Freeform, Notes, Memories, and "Journal" on its own as the name.

## Changes made 2026-09-30

| | Before | After |
|---|---|---|
| App Store name | Inkwell: Gratitude Journal | **Quill: Gratitude Journal** |
| Description | "Inkwell is a quiet place…" (2 mentions) | "Quill" |
| Home screen name (`CFBundleDisplayName`) | Inkwell | **Quill** |
| Build | 17 | **18** |

Subtitle, keywords and App Review notes did not mention Inkwell and are unchanged.
The API accepted the new name, so it is not taken on another account.

## Reply text — paste into Resolution Center

```
Thank you for the review. We did not realise Inkwell is an Apple term and have
removed it completely.

- The app has been renamed "Quill: Gratitude Journal".
- The description no longer uses the old name.
- Build 18 changes the home screen display name to "Quill", so the App Store
listing and the app on the device match.

No other metadata used the old name. Please let us know if anything else needs
attention.
```
