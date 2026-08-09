---
name: execute-plan
description: Reads a plan document written beforehand (typically by a stronger model in a separate planning pass) and implements it end to end — following its architecture decisions, running the validations it names, and checking off its acceptance criteria before declaring the work done. Use whenever the user asks to execute, implement, or run a plan file: "/execute-plan", "/execute-plan dark-mode", "ejecuta el plan de plans/dark-mode.md", "implementa el plan que dejé en .claude/plans/", "sigue el plan.md que tienes en el proyecto". The plan file is the source of truth for scope and approach, not this skill's own judgment — this is meant to run in a fresh conversation that has no memory of how the plan was written.
---

# Execute plan

Implements a feature from a plan document someone else (often a different model, in a different
conversation) already wrote and thought through. The point of this skill is to separate two jobs
that want different amounts of exploration: planning benefits from a strong model reasoning freely
across the whole codebase, execution benefits from a clean context that just follows the plan
without re-litigating decisions already made. Respect that split — don't redesign the approach,
don't second-guess architecture calls the plan already made, just build what it describes.

## 1. Locate the plan file

The plan's location is not fixed — it can live inside the project (`plans/<feature>.md`,
`docs/plans/...`) or in `.claude/plans/` alongside other Claude Code state. Resolve it in this
order, using whatever argument was passed to the skill (a path, a bare feature name, or nothing):

1. **An argument that resolves to an existing file** (absolute, or relative to the repo root) —
   use it directly.
2. **An argument with no slash and no `.md` extension** (a bare feature name, e.g. `dark-mode`) —
   search for `<name>.md` under `.claude/plans/`, `plans/`, and `docs/plans/`, in that order. Use
   the first match.
3. **No usable argument** — glob `*.md` under those same three directories.
   - Exactly one match anywhere: use it.
   - More than one: list them (path + first heading or first line) and ask the user which one via
     AskUserQuestion — don't guess.
   - None: tell the user no plan was found in the usual locations and ask for the path.

Once resolved, confirm the path back to the user in one line before reading it, so a wrong guess
is caught immediately rather than after implementing the wrong feature.

## 2. Read the whole plan before touching any code

Read it fully first — not just the step list. The sections that aren't "Plan de implementación"
(objetivo, contexto, requisitos técnicos, casos límite, riesgos) constrain *how* the steps should
be implemented, and skipping them is how a plan gets implemented technically-correctly but wrong.

## 3. Track progress against the plan's own steps

Create a task list (TaskCreate, or the equivalent in-conversation tracking) mirroring the plan's
"Plan de implementación" section one task per step, plus one task per item in "Criterios de
aceptación". This keeps a long implementation auditable against the document that authorized it,
and makes it obvious at the end whether anything was skipped.

## 4. Implementation discipline

- The plan defines the scope. Don't add, refactor, or "improve" anything it doesn't ask for — the
  same discipline as any surgical change, just anchored to the plan instead of to a chat request.
- Follow its architecture and technical requirements even where you'd have chosen differently —
  the planning pass already made that call, often with context (alternatives considered, trade-offs
  weighed) that doesn't fully survive into the plan's prose.
- **If reality contradicts the plan** — a referenced file doesn't exist, an approach turns out to be
  technically impossible, a dependency isn't actually available — stop, explain the discrepancy and
  the best alternative, then continue with it. Don't silently deviate, and don't halt and wait for
  approval on something you can already reason through; explaining first and proceeding is enough.
- Don't ask "should I proceed?" for decisions the plan already made. The plan *is* the approval.
  Only stop for genuine blockers the plan couldn't have anticipated.

## 5. Before declaring it done

- Run every check the plan lists under "Validaciones" and/or "Criterios de aceptación" (tests,
  lint, typecheck, a manual smoke check, etc.). If the plan is silent on this, fall back to the
  project's own standard checks — for an Expo/React Native project under this workspace's RULES.md
  that means `make test`, `make lint`, `npx tsc --noEmit` (never a heavy target like
  `screenshots`/`android-device`/an EAS build unless the plan or the user explicitly asks for it);
  for anything else, whatever the repo's own lint/test/build scripts are.
- Fix whatever fails. Don't report failures back as someone else's problem to triage.
- Go down "Criterios de aceptación" explicitly, item by item, and confirm each one is actually met
  — don't infer from "the steps are done" that the criteria are too, they're often not the same
  list.

## 6. Final report

Summarize: what changed, which acceptance criteria are confirmed met, and any point where the
implementation deviated from the plan and why. If something in the plan's "Riesgos" section
materialized, say so explicitly rather than letting it pass silently.
