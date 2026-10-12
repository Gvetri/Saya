---
name: no-comments
description: Sweep the Android code you are working on for explanatory comments — a read-only auditor reports every kill and keep, the accepted kills are deleted at the root cause, and every claimed constraint ends as a check or as open work.
disable-model-invocation: true
---

# no-comments

A comment is prose standing where a name, a type or a test belongs. Inside the roll that is already
settled; this skill carries the rule into the **Android code the roll builds** — Kotlin, Java and Gradle in
the app repo, not the roll's own markdown.

The agent that wrote a comment is the wrong pair of eyes to judge it: the reason arrives attached, already
believed. So the sweep runs on a subagent with no stake in the code and exactly one leash, *What survives*
below. Everything outside that leash is meat — fair game, no argument owed.

## Do this

1. **Fix the scope.** The caller's files or diff; with none, the diff against the app repo's base branch
   (default `main`), working tree included. Fence off what nobody edits by hand — `build/`, anything under a
   `generated` path (`R`, `BuildConfig`, KSP and Compose output), vendored SDK sources, `@Generated` files.
   Done when the report's first line names every file the sweep may touch, and what the fence kept out.

2. **Send in the auditor.** One read-only subagent — `comment-sicko` (Hermes: `delegate_task`) — whose whole
   brief is the scope, the fence and *What survives*, handed over verbatim rather than paraphrased. It reads
   the code around a claim before judging it, and it writes nothing: no code, no comment, no file. Done when
   its report gives, per file, every comment **and** every suppression, each marked guilty or protected with
   the leash clause quoted, plus one line per `MUST KILL` naming the symbol the comment hides in.

3. **Judge the report.** Reject a flag outside the scope or the fence, a keep whose reason is no clause in the
   leash, a kill that treats *our* code's surprise as foreign, and a `MUST KILL` whose reason you cannot
   restate from the leash. Sweep what the auditor missed: the `@Suppress`, `@SuppressLint` and
   `@SuppressWarnings` annotations, the IDE's `//noinspection <id>`, and `lint.xml` and detekt-baseline
   ignores. A suppression holding up a correctness or safety rule is a `MUST KILL` on the symbol underneath
   it; one silencing a style or pedantry rule is protected. Ambiguity resolves toward deletion — a doubtful
   keep goes, a doubtful kill stands. One rejected report may be rerun, with the failure named; a second
   rejection ends the sweep, reported open.

4. **Show the plan, then delete.** Per file: the count, each kill on one line, each protected comment with
   the clause that saved it. Then wait — a caller's pre-approval is the only thing that skips the wait — and
   delete exactly what was kept killed. Done when the tree carries no guilty comment.

5. **Fix each accepted flag at its root cause.** A trivial flag is a deletion: the dead path, the unused
   parameter, the call to the real API. A flag that needs a shape gets one sketch from the auditor, and the
   sketch is where it stops — a reshape is its own change, never cargo inside a comment sweep. Remove every
   workaround the flags named; where the root cause sits outside the fence, land the in-scope fix and report
   the rest open. Done when every accepted flag is either fixed or named in the report.

6. **Encode a claimed constraint, or delete it.** `do not remove`, `IMPORTANT`, `too risky`, "ask X first"
   are claims, not proof: the comment goes unless a check can carry the claim. Offer the cheapest check the
   app's own build can enforce, and let the caller choose:

   - **An annotation the build already checks.** `@RequiresApi(33)` where a comment asked the reader to
     remember the level, `@IntDef`, `@Keep` for R8, `@VisibleForTesting`, `@RequiresPermission`. The compiler
     or lint re-checks them on every build, at no runtime cost.
   - **A rule in the app's own lint config.** `lint.xml` or `detekt.yml` — `ForbiddenComment` for a `TODO`,
     `NewApi`, `MaxLineLength` — wired into `check`, so the next offending edit is caught instead of
     described.
   - **A test.** A JUnit or Robolectric test, a Compose UI test, or a Maestro flow; `maestro-test` is the
     roll's own route to the last of those, and a flow that drives the app is the strongest proof of a
     user-visible claim.

   Encode it, then delete the comment. With no check in reach, delete the comment and report the constraint
   open — an unenforced constraint is a finding, and the report is where it lives. Done when every constraint
   comment is either gone behind a check or gone with its constraint named open.

7. **Report.** Deletions per file, `MUST KILL` flags, the rejected report and the reason, any rerun, fixes
   landed, encodings made, constraints left unenforced, and work outside the fence left open. Done when every
   item above has a line.

## What survives

The auditor's whole leash. Hand it over verbatim, judge against it, add nothing to it.

- **A licence header** — the project's own, where the project requires one.
- **A constraint we cannot reshape** — the platform or API level, the framework, an OEM or device quirk, a
  vendor SDK's behaviour, R8 needing a rule, an entry point reached reflectively. A surprise in our own code
  is not one of these: it is meat, and it earns a `MUST KILL` naming the symbol to rename or extract so the
  surprise reads.
- **A comment a tool reads** — a folding region (`//region`, `//<editor-fold>`), `// ktlint-disable`,
  `//noinspection <id>`, a formatter's off switch. It survives only while the rule it silences is faulty,
  pedantic or style-only.
- **KDoc that defines a public API contract** — parameters, return, what it throws, a `@sample`. A doc that
  only restates the signature is narration, and narration dies.
- **A link that says what code cannot** — an AOSP or vendor issue, an RFC, a Play policy page. The link
  stays; the prose wrapped around it does not.
- **Certainty, or death.** When a clause is not clearly true of this comment, the comment dies.

## Rules

- **The auditor reports; the sweep deletes.** Read-only on the repo, one auditor per sweep, and nobody who
  spawns it rewrites its rules.
- **Plan before apply, always.** A sweep is one more place where the roll shows the kills and waits.
- **Our code's surprises are meat; foreign constraints are not.** The line is who can reshape the behaviour:
  us, or something we only call.
- **Deleting beats explaining.** A comment that is the only thing making a line make sense wants a better
  name, a narrower type or a check — a shorter comment is still a comment, and a polished alibi is still an
  alibi.
- **The fence holds.** Generated and vendored code is read at most, never edited, and a sweep never widens its
  own scope to reach a guilty comment.
- **One sweep, one change.** Deletions plus the fixes a flag named, nothing else, so the sweep reverts alone.
