# AGENTS.md

Entry point for an agent working in this repo.

## What this is

Saya is a knife roll: small skills and scripts for developer workstations. Plain shell and
markdown — nothing to build, no dependencies of its own.

## Unpacking on a new host

1. `README.md` for the layout, `CONTEXT.md` for why.
2. Pick the rack in `racks/` for that host (today: `android`).
3. Follow `skills/unpack/SKILL.md`: plan, get a yes, then `--apply`.
4. `scripts/unpack.sh` is the only executable logic, and it is a **dry-run by default**.

## Conventions

- **Plan before apply, always.** Show the plan and wait for a yes; never install unprompted.
- **One job per file.** A knife is one small `knife_<name>()` function: idempotent and readable.
- **Public repo.** No secrets, tokens, private hostnames or work context — ever.
- **Personal scope — stay narrow.** One person's roll: add only knives that are actually used,
  never grow it toward completeness, and never present it as a replacement for other setups
  (dotfiles, package managers, distro tooling, or anyone else's installer).
- **Use the tool's own installer** (sdkman, the Android CLI's `android sdk`, Maestro's script) instead of
  reimplementing it.
- **Keep it short.** If a file needs explaining, the file is too long.

## Adding a knife

1. Add `knife_<name>()` to `scripts/unpack.sh`.
2. Add `<name>` to the relevant `racks/<rack>.conf`, and declare anything it needs there
   (`knives=(...)` is the only required entry; versions/packages belong in the rack, not the script).
3. Note anything host-specific under `CONTEXT.md` → Decisions.
