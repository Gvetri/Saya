---
name: unpack
description: Use when provisioning a host from the Saya knife roll — installing the cherry-picked tools for that host (e.g. the Android toolchain). Fetches the roll, shows the plan, and installs only after the user says yes.
---

# unpack

Saya is the sheath; a **rack** in `racks/` is what a given kitchen needs.

## Do this

1. **Get the roll.** This skill carries no scripts — they live in the repo, so fetch it:

   ```sh
   roll="${SAYA_DIR:-$HOME/.saya}"
   if [ -d "$roll/.git" ]; then git -C "$roll" pull --ff-only; else git clone https://github.com/Gvetri/Saya "$roll"; fi
   ```

2. **Pick the rack** for this host — today there is one: `android`.

3. **Plan first, always.** Show the user what would happen, then wait:

   ```sh
   "$roll/scripts/unpack.sh" android
   ```

4. **Only after a yes:**

   ```sh
   "$roll/scripts/unpack.sh" android --apply
   ```

5. **Verify** it actually works:

   ```sh
   export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
   export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
   export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
   java -version && android sdk list && maestro --version
   ```

   A clean `android sdk list` (not an exit code of 0 alone) is the proof the SDK is real.

## Rules

- Never install without showing the plan and getting an explicit yes.
- Never guess a version — `sdk list java` and `android sdk list` confirm the exact id before
  pinning one.
- `git`, `curl` and `unzip` are prerequisites the rack does not install.
- The roll is a personal repo: a rack is *sourced*, so it is code — unpack only racks you trust.
- Adding a knife = one `knife_<name>()` in `scripts/unpack.sh` plus a line in `racks/<rack>.conf`.
