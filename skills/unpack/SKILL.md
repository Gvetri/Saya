---
name: unpack
description: Use when provisioning a host from the Saya knife roll — installing the cherry-picked tools for that host (e.g. the Android toolchain). Fetches the roll, shows the plan, installs only after a yes, then deletes the clone.
---

# unpack

Saya is the sheath; a **rack** in `racks/` is what a given kitchen needs.

The roll is fetched, used, and **thrown away**. Only the installed skills stay on the host;
every run re-downloads the roll.

## Do this

1. **Plan first, always.** Fetch, plan, delete — show the user the plan, then wait:

   ```sh
   roll="$(mktemp -d)"; git clone --depth 1 -q https://github.com/Gvetri/Saya "$roll" \
     && "$roll/scripts/unpack.sh" android; rm -rf "$roll"
   ```

2. **Only after a yes** — the same, with `--apply`:

   ```sh
   roll="$(mktemp -d)"; git clone --depth 1 -q https://github.com/Gvetri/Saya "$roll" \
     && "$roll/scripts/unpack.sh" android --apply; rm -rf "$roll"
   ```

3. **Verify** it actually works:

   ```sh
   export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
   export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
   export MAESTRO_CLI_NO_ANALYTICS=1
   export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.maestro/bin:$PATH"
   java -version && android sdk list && maestro --version
   ```

   A clean `android sdk list` (not an exit code of 0 alone) is the proof the SDK is real.

## Rules

- Never install without showing the plan and getting an explicit yes.
- **Leave no repo behind.** The `rm -rf "$roll"` is separated by `;` so it runs even when the
  clone or the unpack fails — a half-finished run must not leave a checkout on the host. The end
  state is always: the installed tools plus the npx-installed skill, and no clone.
- **Never edit inside the clone** — it is deleted by design; rack changes belong in the repo.
- Never guess a version — `sdk list java` and `android sdk list` confirm the exact id before
  pinning one.
- **Prerequisites are declared, not installed.** A rack lists what it needs in `prereqs=(...)`;
  unpack names the ones that are missing rather than installing them — the package manager is the
  host's. `git` is the one the unpack flow itself needs, to fetch the roll.
- A rack is *sourced*, so it is code — unpack only racks you trust.
- Adding a knife = one `knife_<name>()` in `scripts/unpack.sh` plus a line in `racks/<rack>.conf`.
