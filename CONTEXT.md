# CONTEXT

## The metaphor

A **saya** is the wooden sheath that carries a knife and protects its edge. Kitchens differ;
the sheath travels. This repo ships the knives, and a **set** is the subset a given kitchen needs.

## Shape

```
racks/     the knives kept out, per host (data)
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
- **Order matters.** In a rack, `sdkman` → `temurin-21` → `android-cli` → `maestro`: the SDK
  installer needs a JDK on PATH.

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
