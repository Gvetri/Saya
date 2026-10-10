# Saya

**Saya** (鞘) — the wooden sheath that carries a knife. This repo carries mine: the skills
and scripts I want on hand when I sit down at a new workstation.

The sheath travels; the kitchen doesn't. Unpack only the knives that kitchen needs.

## Scope

This is a **personal** roll, for my own machines — not a distribution and not a framework.

- It holds what I actually use, not everything a developer might want. No attempt to be
  complete or to cover every feature of any tool.
- It is **not a replacement for anything else** — not for dotfiles, not for a package manager,
  not for a distro's tooling, and not for anyone else's setup. It sits beside them.
- Where a tool ships its own installer, Saya calls that installer rather than reimplementing it.

## Layout

| Path | Purpose |
|---|---|
| `AGENTS.md` | entry point for an agent — how to unpack on a new host |
| `CONTEXT.md` | what this is, the metaphor, the decisions |
| `GLOSSARY.md` | shared vocabulary |
| `racks/` | the knives kept out for one kind of kitchen — one rack per host |
| `scripts/` | the logic; small, one job per knife |
| `skills/` | agent skills — instructions, not libraries |

## Unpack

```sh
scripts/unpack.sh android           # plan: prints what would be installed
scripts/unpack.sh android --apply   # do it
```

Today there is one rack — **`android`**: sdkman, Temurin JDK 21, the Android command-line
tools + SDK, and Maestro.

A rack is `racks/<name>.conf`: a tiny shell file declaring `knives=(...)` (plus any versions or
packages it needs). It is *sourced*, so the shell itself is the parser — no parser to install,
no parsing code, nothing reinvented.

## Status

Early. Android rack only.
