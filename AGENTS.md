# AGENTS.md

Entry point for an agent working in this repo.

## What this is

Saya is a knife roll: small skills and scripts for developer workstations. Plain shell and
markdown — nothing to build, no dependencies of its own.

## Unpacking on a new host

1. `README.md` for the layout, `CONTEXT.md` for why.
2. Pick the set in `lists/` for that host (today: `android`).
3. Follow `skills/unpack/SKILL.md`: plan, get a yes, then `--apply`.
4. `scripts/unpack.sh` is the only executable logic, and it is a **dry-run by default**.

## Conventions

- **Plan before apply, always.** Show the plan and wait for a yes; never install unprompted.
- **One job per file.** A knife is one small `knife_<name>()` function: idempotent and readable.
- **Public repo.** No secrets, tokens, private hostnames or work context — ever.
- **Use the tool's own installer** (sdkman, `sdkmanager`, Maestro's script) instead of
  reimplementing it.
- **Keep it short.** If a file needs explaining, the file is too long.

## Adding a knife

1. Add `knife_<name>()` to `scripts/unpack.sh`.
2. Add `<name>` to the relevant `lists/<set>.txt`.
3. Note anything host-specific under `CONTEXT.md` → Decisions.
