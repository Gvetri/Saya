# CONTEXT

## The metaphor

A **saya** is the wooden sheath that carries a knife and protects its edge. Kitchens differ;
the sheath travels. This repo ships the knives, and a **set** is the subset a given kitchen needs.

## Shape

```
lists/     what to unpack, per host     (data)
scripts/   how to unpack it             (logic)
skills/    what an agent should know    (instructions)
*.md       entry point, context, vocabulary
```

## Decisions

- **Android first.** The first set is `android` because that toolchain carries real setup cost:
  sdkman + Temurin JDK 21 + the Android command-line tools + Maestro.
- **sdkman owns the JDK.** Java arrives via sdkman, so `JAVA_HOME` points at
  `~/.sdkman/candidates/java/current` rather than at a distro package.
- **The SDK lives outside the repo.** `ANDROID_HOME` defaults to `~/Android/Sdk`. Nothing large
  is ever committed here.
- **Dry-run by default.** The script prints the plan; `--apply` is the explicit second step.
- **Order matters.** In a set, `sdkman` → `temurin-21` → `android-cli` → `maestro`: the SDK
  installer needs a JDK on PATH.

## Not here

No CI, no tests, no build system. Shell plus markdown, on purpose.
