# The Android stack's own names

Kotlin, Java and Gradle — the roll's first rack (`racks/android.conf`). Read this before judging, and hand it
to the auditor along with the leash in `SKILL.md`. Nothing here overrides the leash; it only says what the
stack's words are.

## Comments a tool reads

- `//region` / `//endregion`, and `//<editor-fold>` — Android Studio's custom folding regions, which exist only
  so the file can be folded. Deleting the pair is deleting the feature.
- `//noinspection <id>` — an IDE inspection suppression: read by Android Studio's inspections, not by the
  compiler, and the reason it exists is usually that the inspection is wrong here.
- `@file:Suppress(...)` at the top of a file — the file-level form of the annotation below.
- **Not** `// ktlint-disable` or `// ktlint-enable`: ktlint stopped reading those directives in 0.50.0 and
  suppresses through `@Suppress` / `@SuppressWarnings` annotations now, with its own `ktlint-suppression` rule
  migrating the leftovers. A directive still in the tree is a comment **no tool reads** — meat, unless it is
  the annotation that replaced it.
- `@Suppress` on a declaration is the live equivalent, and the one to audit: ktlint and detekt both read it.

## Suppressions written as code

- `@Suppress("UNCHECKED_CAST")`, `@SuppressLint("MissingPermission")`, `@SuppressWarnings(...)`.
- `@Keep` — R8 keeping a symbol reachable; it is the annotation form of "the framework calls this reflectively".
- Config-level: `lint.xml` issue entries and `<ignore>` paths, a detekt baseline file, ktlint's `.editorconfig`
  properties (`ktlint_<ruleset>_<rule> = disabled`).
- A correctness or safety rule underneath one of these is a `MUST KILL` on the symbol it covers — a permission
  (`MissingPermission`), an API level (`NewApi`), a hardware identifier (`HardwareIds`), an unchecked cast. One
  silencing a style rule (`MaxLineLength`, naming, spacing) is protected.

## The fence

- `build/` and `app/build/`; `build/generated/**` — KSP output, Room and Hilt `_Impl`, Compose's generated
  code; `R` and `BuildConfig`; `.gradle/`.
- Vendored SDK sources, an `AAR` unpacked into the tree, anything carrying `@Generated`.

## What a claimed constraint can be handed to

- **Annotations the toolchain already reads.** `@RequiresApi(33)` / `@TargetApi` where a comment asked the
  reader to remember a level, `@IntDef` / `@StringDef` where it listed the legal values, `@RequiresPermission`,
  `@VisibleForTesting`, `@Deprecated`.
- **Lint and detekt config.** A `lint.xml` issue entry; a detekt rule — its `comments` ruleset reports docs
  over private code and undocumented public API, and `AbsentOrWrongFileLicense` is where a licence header
  stops being a comment and becomes a check; ktlint's `.editorconfig`. All wired into `./gradlew check`.
- **A test.** JUnit or Robolectric, a Compose UI test, or a Maestro flow — `maestro-test` is the roll's own
  route to a flow that drives the app, and it is the strongest proof of a UI claim.
- **KDoc.** A contract on a published module's API: parameters, return, what it throws, a `@sample`. In an app
  module nothing outside consumes, a doc that restates the signature is narration — and detekt's own comments
  ruleset already treats docs over private code as the smell it is.
