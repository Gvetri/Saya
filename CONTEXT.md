# CONTEXT

## The metaphor

A **saya** is the wooden sheath that carries a knife and protects its edge. Kitchens differ;
the sheath travels. This repo ships the knives, and a **rack** is the subset a given kitchen needs.

## Shape

```
racks/     the knives kept out, per host (shell-native)
scripts/   how to unpack it             (logic)
skills/    what an agent should know    (instructions)
*.md       entry point, context, vocabulary
```

## Decisions

- **Android first.** The first rack is `android` because that toolchain carries real setup cost:
  sdkman + Temurin JDK 21 + the Android command-line tools + Maestro.
- **sdkman owns the JDK.** Java arrives via sdkman, so `JAVA_HOME` points at
  `~/.sdkman/candidates/java/current` rather than at a distro package.
- **The SDK lives outside the repo.** `ANDROID_HOME` defaults to `~/Android/Sdk`. Nothing large
  is ever committed here.
- **Dry-run by default.** The script prints the plan; `--apply` is the explicit second step.
- **Racks are shell-native.** `racks/<rack>.conf` is a shell file declaring `knives=(...)`; it is
  *sourced*, so the shell is the parser — no parser dependency, no parsing code, and a rack can
  carry its own versions/packages. The trade-off: a rack is executable, so keep it to declarations
  and only run racks you trust.
- **Distributed as a skill, not a bundle.** `npx skills add Gvetri/Saya -g -a hermes-agent`
  installs only `skills/unpack/SKILL.md`. The skill deliberately carries no scripts: it clones the
  repo to `~/.saya` and runs `scripts/unpack.sh` from the clone, so there is exactly one copy of
  the logic and the racks. Bundling a second copy inside the skill would drift.
- **Order matters.** In a rack, `sdkman` → `temurin-21` → `android-cli` → `maestro`: the SDK
  installer needs a JDK on PATH.
- **Android CLI, not `sdkmanager`.** cmdline-tools 23.0 ships a new `android` binary and marks
  `sdkmanager` deprecated; the knife uses `android sdk install <pkg>` with slash paths
  (`platforms/android-35`). Licences need no separate step — they are accepted during install,
  which also removes the old `yes | … --licenses` pipefail trap.
- **`android init` is deliberately NOT in the knife.** It installs an `android-cli` skill into
  *every* agent's skills directory (`~/.hermes`, `~/.codex`, `~/.cursor`, `~/.pi`, …) and ignores
  `HOME`, so it cannot be sandboxed or dry-run. Run it by hand, on purpose, if the skill is wanted.

## Not here

No CI, no tests, no build system. Shell plus markdown, on purpose.

## Scope — deliberately narrow

This is one person's roll, for one person's machines.

- **Not a distribution or a framework.** No plugin system, no config schema, no versioning story.
- **Not exhaustive.** It carries the knives I actually reach for. Missing features are not bugs.
- **Not a replacement for anything.** Not for dotfiles, not for a package manager, not for distro
  tooling, not for another person's setup — it sits beside them.
- **Not a product.** Nobody else's workflow has to fit it, and it should not be grown to fit one.

Where a tool ships its own installer, Saya calls it instead of reimplementing it. The repo stays
small precisely because it refuses the above.
