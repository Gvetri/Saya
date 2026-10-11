---
name: maestro-test
description: Use when an agent must prove a change in an Android app works end to end — see the live screen, author a Maestro flow, run it until it is green, and leave the YAML behind as a deterministic test. Runs on the agent's own device, provisioned by maestro-setup.
---

# maestro-test

Maestro MCP ships inside the Maestro CLI and drives one device at a time. This skill owns the **flow**:
what to assert, how to see the screen, and when to call it done. The device is `maestro-setup`'s — that
skill creates, boots, stops and wipes it, and this one only decides when each of those happens.

The MCP tools appear in the agent as `mcp_maestro_*` (Hermes wires `mcp_<server>_<tool>`).

## Do this

1. **Take your own device.** `maestro-setup` steps 1 and 3 create and boot a headless AVD named for the
   agent and print its serial; that serial is the `device_id` everything below needs. `list_devices`
   also lists your cold AVD, with `connected: false` — the id to use is the connected one
   (`emulator-5554`) — and it hands you a Maestro Viewer URL to pass to the user. Done when
   `list_devices` shows your device connected; the local tools refuse to run without an id from there
   (`device_id is required`).

2. **Know the outcome you are proving.** Build and install the feature's APK, and take the `appId` from
   the manifest. Done when `adb -s "$serial" shell pm list packages | grep <appId>` prints it, and you
   can state the user-visible outcome in one sentence — that sentence is what the flow asserts.

3. **Look before you write.** Call `cheat_sheet` before authoring commands you have not used, then
   `inspect_screen` for the current view hierarchy, and `take_screenshot` when a visual would help. The
   hierarchy comes back abbreviated — `txt`, `rid` and `a11y` for text, resource id and content
   description — and the schema header above the elements is not itself a list of elements; read the
   `abbreviations` map before picking anything. Done when every element the flow will target is one you
   saw named on screen — Maestro targets text, ids and content descriptions, never coordinates.

4. **Author one flow.** Run it inline first (`run` with `{ yaml }`, always with `device_id`) to explore,
   then save the working flow as YAML in the project, beside the app it drives. A mobile flow declares
   `appId` and starts with `launchApp`. Done when the file asserts the outcome from step 2, not just
   that the app launched.

5. **Drive it green, twice.** Run the saved flow — `run` with `{ files }` or `{ dir }` through the MCP,
   or the same flow through the CLI, aiming the artifacts at a directory the project ignores:

   ```sh
   maestro --device "$serial" test \
     --test-output-dir .maestro/artifacts/report --debug-output .maestro/artifacts/logs \
     .maestro/<flow>.yaml
   ```

   Green is `success: true` from the MCP, or `COMPLETED` per step and exit 0 from the CLI. Red is
   information, not a verdict: the failure names the command (`Assertion is false: "…" is visible`) and
   the artifacts hold that step's screenshot and screen hierarchy — fix the flow, or the app, which is
   the point of the exercise, and run again. Done when a second run passes with nothing changed in
   between.

6. **Retire your device when the PR merges.** It was created for this feature and belongs to no one
   else: stop it and wipe it with `maestro-setup` step 5's commands, so a kitchen never accumulates
   AVDs. Done when `adb devices` and `emulator -list-avds` no longer show it.

## Rules

- **Device work belongs to `maestro-setup`.** Creating, booting, stopping and wiping live in that skill;
  this one decides when they happen.
- **Name your device on every call.** With several agents on one kitchen, pass `device_id` to every MCP
  tool and `--device <serial>` (or `-s <serial>`) to every CLI and adb command.
- **Assert the feature, not the launch.** A flow that only starts the app proves the app runs and
  nothing about the change.
- **One whole journey per flow.** A single flow that carries the user from entry point to outcome beats
  a pile of single-command calls.
- **The app is the app.** Fix the flow when the flow is wrong; when the flow is right and the app is
  not, that failure is the finding — report it rather than loosening the selector.
- **No run artifacts in the repo.** Screenshots, logs and reports go to a directory the project ignores.
- **Maestro Cloud is out of scope.** The local device only — never `run_on_cloud` or
  `list_cloud_devices`.
