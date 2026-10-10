---
name: unpack
description: Use when provisioning a new host from the Saya knife roll. Unpacks a cherry-picked rack of tools by running scripts/unpack.sh for that host's rack.
---

# unpack

Saya is the sheath; a **rack** in `racks/` is what a given kitchen needs.

## Do this

1. Pick the rack for this host — today there is one: `android`.
2. **Plan first, always.** Dry-run and show the user what would happen, then wait:
   ```sh
   scripts/unpack.sh android
   ```
3. Only after a yes:
   ```sh
   scripts/unpack.sh android --apply
   ```
4. Export the toolchain and verify it actually works:
   ```sh
   export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
   export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
   export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
   java -version && android sdk list && maestro --version
   ```
   A clean `android sdk list` (not an exit code of 0 alone) is the proof the SDK is real.

## Rules

- Never install without showing the plan and getting an explicit yes.
- Never guess a version — `sdk list java` and `android sdk list` to confirm the exact id
  before pinning one.
- `unzip` and `curl` are prerequisites the rack does not install.
- Adding a knife = one `knife_<name>()` in `scripts/unpack.sh` plus a line in the rack file.
