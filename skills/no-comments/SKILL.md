---
name: no-comments
description: Sweep the code under review for comments, and delete everything the exceptions do not save.
disable-model-invocation: true
---

# no-comments

A comment is prose standing where a name, a type or a test belongs, and whoever wrote it cannot judge it: the
reason arrives attached, already believed. So the pass runs in a second pair of eyes — one read-only subagent,
handed the scope and the exceptions verbatim — and you act on what survives your reading of its report.

## Scope

The code under review: the files the caller hands over — a diff, a patch, a branch against its base — minus the
files it only deletes and anything the fence keeps out. With nothing handed over, the working diff against the
base branch. Wider only when a human asks, and the ask names the width: a path, or the repo.

The fence is generated and vendored code: read, never edited, never a reason to widen.

## Steps

1. The auditor is read-only: it reads the code around a claim before judging it, and writes nothing — no code,
   no comment, no file. Its report gives, per file, every comment and every suppression as a delete or a keep
   with the exception that saved it, and flags each symbol whose comment was standing in for code that does not
   read — the rename, the narrower type, the extraction the comment should have been. With no second agent to
   spawn, take that pass yourself against the diff alone.
2. Judge the report: reject a flag outside the scope, a keep no exception covers, and a pass given to a
   surprise in our own code. Sweep the suppressions it missed — a directive comment, an annotation, an
   ignore entry, a baseline — and send the one holding up a correctness or safety rule back as a flag on the
   symbol under it. Doubt resolves to deletion. Rerun one rejected report, its failure named; a second goes
   back open.
3. Show the plan — per file, the deletions, and each keep with the exception that saved it — then delete what
   survived. In a review the plan is the finding: it goes back as the note, and the deletions belong to whoever
   owns the code.
4. Fix each accepted flag at its root cause: the dead path, the unused parameter, the real API. Sketch a shape
   if one is needed and stop at the sketch. Remove every workaround a flag named, and report the causes outside
   the scope.
5. A claimed constraint — `do not remove`, `IMPORTANT`, `too risky` — is a claim, not proof: encode the cheapest
   check the project's build already runs (a declaration the compiler or linter reads, a lint rule, a test) and
   delete the comment; with no check in reach, delete it and report the constraint open.
6. Report the deletions per file, the flags, the rejected report and why, the fixes, the encodings, the
   constraints left open. One sweep, one change: the deletions and the fixes a flag named, nothing else.

## What survives

Hand this over verbatim: nothing outside it survives, and doubt counts as outside.

- A licence header.
- A constraint we cannot reshape: the runtime, the framework, the platform, a vendor or device quirk, a build
  tool's requirement, a symbol reached reflectively. A surprise in our own code is not one of these — it gets a
  flag naming the symbol to rename or extract.
- A comment a tool reads — a folding marker, a suppression directive, a formatter's off switch, a build tag —
  while the rule it silences is faulty, pedantic or style-only.
- The doc comment that defines a published API contract: KDoc, Javadoc, JSDoc or TSDoc, rustdoc, a Python
  docstring, a Go doc comment. On a private symbol, or restating the signature, it is narration and dies.
- A link that says what code cannot: an issue, an RFC, a policy page.
- Certainty, or death — when a clause is not clearly true of this comment, the comment dies.

`references/android.md` holds the Kotlin, Java and Gradle names for all of it.
