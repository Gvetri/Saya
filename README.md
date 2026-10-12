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

## Install, then unpack

Install the skill into your agent — the CLI knows Hermes as `hermes-agent`, and also handles codex,
pi and cursor:

```sh
npx skills add Gvetri/Saya -g -a hermes-agent
```

Then, in the agent, ask it to **unpack** a rack. The skill fetches the roll into a temp dir, runs
it, and deletes it again — so the host ends up with the installed tools and **no clone**:

```sh
roll="$(mktemp -d)"; git clone --depth 1 -q https://github.com/Gvetri/Saya "$roll" \
  && "$roll/scripts/unpack.sh" android; rm -rf "$roll"
```

Re-running unpack simply clones again. Nothing of the roll persists between runs.

Today there is one rack — **`android`**: sdkman, Temurin JDK 21, the Android CLI
(cmdline-tools 23.0) + SDK, and Maestro.

A rack is `racks/<name>.conf`: a tiny shell file declaring `knives=(...)` (plus any versions or
packages it needs). It is *sourced*, so the shell itself is the parser — no parser to install,
no parsing code, nothing reinvented.

## Skills

Skills split on one axis: who can invoke them. **Model-invoked** skills carry a description, so the
agent reaches for one when the task fits — and you can still type its name yourself. **User-invoked**
skills are reachable only when you type them, and they orchestrate: one may invoke a model-invoked
skill, never another user-invoked one.

### Android

Getting a host ready to build and drive Android apps.

- **unpack**: Fetch the roll, show the plan for a rack, install its knives only after a yes, then delete the clone.
- **maestro-setup**: Give an agent a live Android device for Maestro MCP — pick the image with the user, boot a headless AVD named for that agent, prove the chain with a throwaway sample app, wire the MCP, then stop the device.
- **maestro-test**: Prove a change end to end on Android — see the live screen, author the flow, run it until it is green, and leave the YAML behind as the test. Runs on the agent's own device.

### Code

The code a kitchen works on, whatever the stack.

- **no-comments** (typed): Sweep the code a review hands over for explanatory comments — a module or the whole repo only when you ask. A second pair of eyes reports every delete and keep, the accepted ones go at the root cause, and every claimed constraint ends as a check or as open work.
