---
name: release
description: Ships a version by way of the gh milestone/issue workflow — verifies every issue in the release's GitHub milestone is actually closed (not just marked closed), tags, pushes, and creates a GitHub release with English Markdown notes. Use whenever the user asks to release, ship, tag, or publish a version: "/release 1.3.0", "publica la 2.1.0", "crea el tag y la release de esta versión", "ship 1.3.0". Works in any git repo with a `gh`-tracked milestone, not just Expo projects.
---

# Release

Ships a version that has been tracked as a GitHub milestone: confirms the milestone's work is
genuinely done, then tags, pushes, and creates the GitHub release. This is the flow documented in
`~/.claude/CLAUDE.md` under "Flujo de releases (gh)" — read that section, it's the source of truth
for the parts of this skill that touch permissions (tag/push still need the user's go-ahead in the
moment, same as any other `git push`).

## 1. Resolve the version and the milestone

Take the version from the skill argument (e.g. `/release 1.3.0` → `1.3.0`). If none was given,
look for the project's own version source (`app.json`'s `expo.version` for Expo projects,
`package.json`'s `version` otherwise) and confirm that's the one being released before proceeding.

Confirm the milestone exists and matches:

```
gh api repos/:owner/:repo/milestones --jq '.[] | {number,title,open_issues,closed_issues}'
```

If there's no milestone with that title, stop and ask — don't create one silently, the user may
have named it differently or not created it yet.

## 2. Verify the milestone is actually done — don't trust the label

```
gh issue list --milestone <version> --state all --json number,title,state,closedAt
```

Any issue still `OPEN` is a hard stop: list them and ask the user how to proceed (finish them now,
defer them to the next milestone, or confirm they're fine to ship without). Don't tag past open
issues on your own judgment.

**A `CLOSED` issue is not automatically verified work.** This came up for real on Foliato 1.2.0: a
device-testing issue got closed with every box ticked before the actual device pass matched what
was checked. If the milestone includes an issue whose checklist or acceptance criteria you can
cross-check against something concrete — a test suite, a build log, another issue's linked
evidence — do that before treating it as done. If a closed issue's claims can't be verified from
here (it needed a real device, a manual store-console action, something only the user could have
done), take the user's word for it, but don't independently upgrade "closed" to "verified" without
either checking or asking. When in doubt, ask specifically what was confirmed, the way you would
for anything else you can't verify yourself — see `~/.claude/CLAUDE.md` "Pensar antes de
programar."

## 3. Preflight

- `git status` — working tree clean, on the release branch (usually `main`), nothing unstaged
  that looks like leftover work.
- If the project has a version field committed in source (`app.json`, `package.json`, an Android
  `versionCode`), confirm it already matches the version being released — this should already be
  true going in, not something this skill bumps for you. If it doesn't match, stop and ask; don't
  silently edit a version field as part of releasing.
- Check whether the tag already exists (`git tag -l <version>`) — if it does, stop, this has
  likely already shipped.

## 4. Tag and push

This is a `git push` — the global rule requires the user's explicit go-ahead in the moment. Being
asked to run `/release <version>` for a specific version **is** that go-ahead for this tag; you
don't need to ask a second time inside the skill unless step 2 or 3 raised something that changes
the picture.

```
git tag <version>
git push origin <version>
```

## 5. Write the release notes

English, Markdown, regardless of the conversation's language (same reasoning as commit messages —
this is technical/shipped-artifact content, see the Idioma rule). Structure:

- One-line summary of what the version is about.
- A "Highlights" section: what shipped, in the order that matters to a user, not the order it was
  built. Pull this from the project's own changelog/history doc if one exists (`doc/history.md`,
  `CHANGELOG.md`), not from raw `git log` — commit messages describe individual changes, not the
  shape of the release.
- A "Milestone issues" section listing each issue from step 2 as `#N — title`, with a one-clause
  note on anything non-obvious (e.g. a decision issue, noting which way it was decided).

Write it to a temp file, then:

```
gh release create <version> --title <version> --notes-file <file> --target <branch>
```

## 6. Close the loop

If the project has a roadmap/TODO doc that names this release as pending work (Foliato's
`TODO.md` §1 is the precedent), update it to reflect that the release shipped — link the GitHub
release, don't duplicate its content. Commit that (commits don't need permission, per the global
rule).

Report back: the tag, the release URL, and anything from step 2 that got resolved or deferred
along the way.
