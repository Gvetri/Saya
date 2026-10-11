---
name: maestro-test
description: Use when an agent must prove a change in an Android app works end to end — drive the app by hand through Maestro MCP while building the change, then turn what it saw into a flow that runs green as a file and stays as the test. Runs on the agent's own device, provisioned by maestro-setup.
---

# maestro-test

Maestro MCP ships inside the Maestro CLI and drives one device at a time. This skill owns the **flow**:
how to see the screen, when to write the test down, and when to call it done. The device is
`maestro-setup`'s — that skill creates, boots, stops and wipes it, and this one only decides when each
of those happens.

Work in two halves: **drive the app by hand while you build the change, and write the flow only once you
have seen the journey.** Inline commands are debugging; the flow is the deliverable, and it is the file
that has to pass.

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

3. **Work the change on the device.** Driving the app through the MCP *is* the debugging loop: `run`
   with inline `{ yaml }` to move around and change state, `cheat_sheet` before commands you have not
   used, `inspect_screen` to see what a screen actually holds, `take_screenshot` when a visual would
   help. Explore freely and keep nothing yet — the hierarchy comes back abbreviated (`txt`, `rid` and
   `a11y`, behind a schema header that is not itself a list of elements), so collect the hierarchies of
   the screens the journey passes. Done when the change works on the device and you hold, in context,
   the elements each of those screens offers.

4. **Write the flow from the hierarchies you gathered.** One flow, in YAML, saved beside the app it
   drives: `appId` first, then `launchApp` to enter, then the journey you just walked — with strings
   **copied** from the hierarchies rather than retyped, and with clocks, counts, ids and list order left
   out of the assertions. Done when the file asserts the outcome from step 2, not just that the app
   launched.

5. **Run the file, from a clean start, until it is green twice.** Your exploration was stateful and the
   flow cannot be: re-enter through the flow's own entry point — `clearState: true`, or an explicit
   setup subflow when the feature needs seeded data — and run it as a file, through the MCP (`{ files }`
   or `{ dir }`) or the CLI:

   ```sh
   maestro --device "$serial" test \
     --test-output-dir .maestro/artifacts/report --debug-output .maestro/artifacts/logs \
     .maestro/<flow>.yaml
   ```

   First-launch dialogs, permission prompts and empty states are where a device that already carries
   your taps lies; handling them is the flow's job now. Green is `success: true` from the MCP, or
   `COMPLETED` per step and exit 0 from the CLI. Red is information, not a verdict: the failure names
   the command (`Assertion is false: "…" is visible`) and the artifacts hold that step's screenshot and
   screen hierarchy — fix the flow, or the app, which is the point of the exercise, and run again. Done
   when a second run passes with nothing changed in between.

6. **Retire your device when the PR merges.** It was created for this feature and belongs to no one
   else: stop it and wipe it with `maestro-setup` step 5's commands, so a kitchen never accumulates
   AVDs. Done when `adb devices` and `emulator -list-avds` no longer show it.

## Rules

- **Explore by hand, ship a file.** Inline `run` is for debugging. The deliverable is a saved flow, and
  it must be the thing that goes green — an inline session that never ran from disk is not a test.
- **Device work belongs to `maestro-setup`.** Creating, booting, stopping and wiping live in that skill;
  this one decides when they happen.
- **Name your device on every call.** With several agents on one kitchen, pass `device_id` to every MCP
  tool and `--device <serial>` (or `-s <serial>`) to every CLI and adb command — and drive one Maestro
  process at a time per device.
- **Assert the feature, not the launch.** A flow that only starts the app proves the app runs and
  nothing about the change.
- **One whole journey per flow.** A single flow that carries the user from entry point to outcome beats
  a pile of single-command calls.
- **The app is the app.** Fix the flow when the flow is wrong; when the flow is right and the app is
  not, that failure is the finding — report it rather than loosening the selector.
- **No run artifacts in the repo.** Screenshots, logs and reports go to a directory the project ignores
  — in the repo that owns the app, not in the kitchen that drove it.
- **Maestro Cloud is out of scope.** The local device only — never `run_on_cloud` or
  `list_cloud_devices`.
