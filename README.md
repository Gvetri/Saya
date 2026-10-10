# Saya

**Saya** (鞘) — the wooden sheath that carries a knife. This repo carries mine: the skills
and scripts I want on hand when I sit down at a new workstation.

The sheath travels; the kitchen doesn't. Unpack only the knives that kitchen needs.

## Layout

| Path | Purpose |
|---|---|
| `AGENTS.md` | entry point for an agent — how to unpack on a new host |
| `CONTEXT.md` | what this is, the metaphor, the decisions |
| `GLOSSARY.md` | shared vocabulary |
| `lists/` | the cherry-picked sets — one file per kind of host |
| `scripts/` | the logic; small, one job per knife |
| `skills/` | agent skills — instructions, not libraries |

## Unpack

```sh
scripts/unpack.sh android           # plan: prints what would be installed
scripts/unpack.sh android --apply   # do it
```

Today there is one set — **`android`**: sdkman, Temurin JDK 21, the Android command-line
tools + SDK, and Maestro.

## Status

Early. Android set only.
