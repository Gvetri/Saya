---
name: maestro-setup
description: Use when a kitchen needs a live Android device for an agent driving Maestro MCP — pick the image with the user, boot a headless device named for that agent, prove it with a throwaway sample app, wire the MCP, then stop it. Ends with a sample flow green and the device cold.
---

# maestro-setup

`maestro mcp` is the server and it ships inside the Maestro CLI — nothing else to install. What it has
no answer for is a device: it drives whatever `adb` sees, and it needs one of those ids before any of
its local tools will run. A kitchen is one host; the device is one agent's own. This skill provisions
it, proves it against Maestro's throwaway sample app, wires the MCP, and hands it over cold — device
stopped, AVD kept.

Creating and stopping a device is this skill's job in full. `maestro-test` reuses those two blocks for
the per-agent device it makes for a feature, then wipes that one after the PR merges.

## Do this

1. **Check the rack.** Every shell starts fresh, so export the toolchain first:

   ```sh
   export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
   export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
   export ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-$HOME/.android/avd}"
   export MAESTRO_CLI_NO_ANALYTICS=1
   export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$HOME/.maestro/bin:$PATH"
   java -version && maestro --version && android info
   ```

   `android info` naming the SDK path is the check that passes. Anything missing means the rack is not
   unpacked yet — `skills/unpack`, rack `android`. Two of those exports are the non-obvious ones:
   `ANDROID_AVD_HOME` puts both Android tools on one AVD home (step 3 says why), and
   `MAESTRO_CLI_NO_ANALYTICS` keeps Maestro from reporting the run anywhere.

2. **Pick the image, with the user.** Default `android-34` — the Cloud-equivalent, and a level this
   CLI supports. Offer it, show what else is available, and wait for the choice:

   ```sh
   maestro list-devices
   android sdk list --all | grep 'system-images'
   ```

   `list-devices` names the levels this CLI can create; `android sdk list --all` names the images this
   SDK can install. The level is the only knob: the tag stays `google_apis` (never
   `google_apis_playstore` — Google APIs is what Maestro Cloud reproduces locally) and the ABI stays
   `x86_64` (this host's CPU). Then plan first, then apply; the image is ~1.6 GB:

   ```sh
   android sdk install emulator system-images/android-34/google_apis/x86_64
   ```

   One image, two syntaxes: the `android` CLI takes slash paths, while `avdmanager` and `--device-os`
   take the `;`-separated form (`system-images;android-34;google_apis;x86_64`).

   The emulator and the image are installed here, on demand, rather than by the rack: an unpack should
   stay lean, and a kitchen that never drives a UI should not pay 1.6 GB for one. The AVD it creates
   belongs to the host, in `$ANDROID_AVD_HOME`.

3. **Create or reuse this agent's device.** Named for the agent, so agents never share one:

   ```sh
   device="<agent>-api34"
   mkdir -p "$ANDROID_AVD_HOME"
   avdmanager list avd | grep -q "Name: $device" || echo no | avdmanager create avd \
       --name "$device" \
       --package "system-images;android-34;google_apis;x86_64" \
       --device pixel_6
   emulator -list-avds | grep -qx "$device"
   "$ANDROID_HOME/emulator/emulator" -avd "$device" \
       -no-window -no-snapshot -no-audio -no-boot-anim -no-metrics -accel on \
       > "${TMPDIR:-/tmp}/$device-emulator.log" 2>&1 &
   for _ in $(seq 1 100); do
     [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ] && break
     sleep 3
   done
   serial="$(for s in $(adb devices | awk '/emulator/ {print $1}'); do
     [ "$(adb -s "$s" emu avd name 2>/dev/null | tr -d '\r' | head -1)" = "$device" ] && echo "$s"
   done | head -1)"; echo "$serial"
   ```

   The name is the agent's own: `maestro start-device` would derive one from model and level and reuse
   it, so several agents on one kitchen land on a single emulator — and a wipe would take out a device
   its own agent did not create.

   **`ANDROID_AVD_HOME` is not optional.** `avdmanager` is a Java tool and honours `XDG_CONFIG_HOME`,
   so on a host where that is set it writes the AVD to `~/.config/.android/avd` — while the emulator
   binary searches only `$ANDROID_AVD_HOME`, `$ANDROID_SDK_HOME/avd` and `$HOME/.android/avd`, finds
   nothing, and exits with `Unknown AVD name`. Pinning the home puts both tools on one directory; the
   `emulator -list-avds` line is the check that they really do.

   Headless is the default because the agent drives the device through adb and Maestro Viewer, and a
   window is something the human can grab, nudge or block by accident. Drop `-no-window` (keep the
   rest) when the user asks to watch it run. No `-gpu` value is pinned: the emulator picks its own back
   end, so a kitchen with a working GPU gets the GPU. Where the terminal tool tracks background
   processes, start it as one — the emulator never exits by itself — and the boot wait is bounded, so a
   dead emulator fails the run instead of hanging it, with its reason in
   `$TMPDIR/<device>-emulator.log`.

   Done when `adb -s "$serial" emu avd name` prints `$device` — its output carries a trailing CR, so
   strip it. Safe to re-run: an existing AVD is reused, and a booted device is left alone.

4. **Prove the chain with Maestro's throwaway sample app.** Downloaded into a probe directory, deleted
   with it:

   ```sh
   probe="$(mktemp -d)" && echo "$probe"
   ( cd "$probe" && maestro download-samples )
   adb -s "$serial" install -r "$probe/samples/wikipedia.apk"
   ( cd "$probe" && maestro --device "$serial" test \
       --test-output-dir "$probe/report" --debug-output "$probe/logs" \
       samples/android-flow.yaml )
   ```

   One `download-samples` writes `samples/` and gives both halves: the app
   (`samples/wikipedia.apk`, `appId: org.wikipedia`) and a `launchApp` smoke flow, plus an
   `advanced`-tagged flow for a deeper check. It fetches both platforms — ~200 MB, an 82 MB Android APK
   and a 117 MB iOS bundle — so the probe is the only place that weight ever lands, and every setup run
   pays it again. The output flags keep Maestro's own artifacts — session log, and on a failure
   screenshots and screen hierarchy — inside the probe instead of `~/.maestro/tests`.

   Green is this skill's completion criterion, and it proves four links at once: the emulator booted,
   the driver installed, the app launched, and Maestro is driving the same device the MCP will see.
   **Red**: leave the probe alone and report it — `report/` and `logs/` are the evidence — then stop.

5. **Clear the probe and stop the device.** The kitchen goes cold, the AVD stays:

   ```sh
   rm -rf "$probe"
   adb -s "$serial" emu kill
   adb devices
   ```

   Done when this agent's emulator is gone from `adb devices`, the probe is gone, and this run added
   nothing under `~/.maestro/tests`. **Stopping is not wiping**: the AVD survives with the sample app
   inside it, and Maestro installs and removes its own driver APKs around each run, so nothing of that
   run stays on the device. Booting again is step 3; the wipe is `avdmanager delete avd --name
   <device>` — it belongs to whoever created that device for a feature, and it is how an agent retires
   its emulator once its PR has merged.

6. **Hand off the kitchen.** Give the agent the MCP block for its own config:

   ```yaml
   mcp_servers:
     maestro:
       command: "/home/<you>/.maestro/bin/maestro"
       args: ["mcp"]
       env:
         JAVA_HOME: "/home/<you>/.sdkman/candidates/java/current"
         MAESTRO_CLI_NO_ANALYTICS: "1"
   ```

   Hermes reads `~/.hermes/config.yaml`, Codex the same block as `[mcp_servers.maestro]` in
   `~/.codex/config.toml`. Agents launch MCP servers with a filtered environment, so `JAVA_HOME`,
   `MAESTRO_CLI_NO_ANALYTICS` and an absolute path to the binary belong in that block even though your
   own shell has them. Connections are read at startup — restart the agent to pick it up. For whoever
   wants to watch, the server logs `mcp_viewer_ready` with a local Viewer URL and prefixes every tool
   result with that same link — hand it to the user; it drives the device this skill provisioned.

   Kitchen facts to report: the device name and its image, the sample `appId` (`org.wikipedia`,
   re-derivable with `adb shell pm list packages`), and that step 3 — not `maestro start-device` — is
   what boots this agent's device.

## Rules

- **One name per agent.** A kitchen hosts several agents; two of them sharing an AVD name share one
  emulator and overwrite each other's state, and a wipe takes out a device it does not own. Name yours,
  boot yours, wipe yours.
- **Target your serial.** With several agents' devices up, pass `--device <serial>` to Maestro and
  `-s <serial>` to adb on every command. `adb -s <serial> emu avd name` says which AVD a serial is.
- **Headless unless asked.** The window belongs to the human and is theirs to nudge; the agent's view
  is Maestro Viewer. A run goes windowed only when the user asks for it — dropping `-no-window` and
  keeping the rest of the flags.
- **The sample app is a target, not a test.** Drive it, never edit it; the feature's own flows belong
  to `maestro-test`.
- **KVM is a prerequisite** the rack does not install; `-accel on` makes a host without it fail loudly
  instead of booting an emulator that crawls. A display is needed only for the windowed mode.
- **Pin the level in one place.** The image in step 2 and the AVD in step 3 are the device's Android
  version; moving a level means editing those two lines, deliberately.
