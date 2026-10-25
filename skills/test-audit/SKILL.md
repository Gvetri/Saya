---
name: test-audit
description: "Use when writing, changing, reviewing, or deleting tests. Gate new tests on one provable behavior; hunt fake tests in review; demand remaining proof before deletion."
---

# Test Audit

A general proof checklist for any repo. It owns proof quality; each repo owns its tools.

## Step 0 — Read the repo's own rules first

Tool rules live in each repo (AGENTS.md, CONTRIBUTING.md, repo skills). Read them before you write or review a test. On conflict, the repo's rules win.

## The gate — before you add or change a test

Answer four questions. A missing answer means: no test.

1. **What real behavior does it protect?** State what the code should do, not how it is written.
2. **Which bug would make it fail?** Name a credible regression. No bug to catch = no proof.
3. **Does existing proof already cover it?** One test owns one rule, at the best place. Add a second layer only for a risk the first layer cannot reach (different transport, different lifecycle).
4. **Does it need code that only tests use?** Extra exports, flags, or hooks with no production caller are a smell. Test the real boundary instead.

## Fake tests — hunt these when you review

Judge a test by its assertions, not its name. A fake test looks busy and proves nothing:

- Cannot fail: compares a value to itself, or expects what the test just built.
- Copies the source: asserts on code text, imports, or file lists rather than behavior.
- Checks how, not what: internal call shapes or private details instead of the observable result.
- Duplicate: a stronger test elsewhere already owns the rule.
- Mock supplies the answer: the mock returns the asserted value, so the test checks the mock, not the code.
- Wrong-guard negative: the control fails on a different guard than the one it exists to test.
- Overpromising name: the assertions check less than the name promises.

## Keep — these stay

- Slow and old tests stay when they catch a real regression. Speed is not proof quality.
- A real promise (public interface, saved file format, config default, security rule) keeps its proof even when static.
- A failing old test may be a product bug. Reproduce it, fix the owner. The test stays.

## Test-only code

- Production code serves production callers. Test the real boundary.
- A seam a test needed dies with that test, in the same change.

## Before you delete a test

- Read the full test, the code it tests, and who calls that code.
- Record what proof remains after deletion. No remaining proof = no deletion.
- Prefer few high-confidence candidates.
