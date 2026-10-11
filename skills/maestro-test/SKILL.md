---
name: maestro-test
description: Use when an agent must prove a change in an Android app works end to end — drive the app by hand through Maestro MCP while building the change, then turn what it saw into a flow that runs green as a file and stays as the test. Runs on the agent's own device, provisioned by maestro-setup.
---

# maestro-test

This skill drives one device at a time through Maestro MCP and owns the **flow**: how to see the screen,
when to write the test down, and when to call it done. Call the MCP tools by their bare names —
`list_devices`, `run`, `inspect_screen`, `cheat_sheet` — which Hermes exposes as `mcp_maestro_<tool>`.

Work in two halves: **drive the app by hand while you build the change, and write the flow only once you
have seen the journey.** Inline commands are debugging; the flow is the deliverable, and it is the file
that passes.

The device is this agent's own AVD, `<agent>-api34`. `maestro-setup` step 3 creates and boots it and
step 5 stops and wipes it — this skill runs those commands and decides when.

## Do this

1. **Take your own device.** `maestro-setup` step 1 exports the toolchain and step 3 boots the device and
   prints `$serial`; re-derive it in each new shell. `list_devices` also shows your cold AVD
   (`connected: false`), so the id to drive is the one it prints as connected, whatever `emulator-<n>` it
   happens to be. Done when `list_devices` shows your device connected — the device-scoped tools answer
   `device_id is required` without that id.

2. **Know the outcome you are proving.** For a change you built, install its APK and take the `appId`
   from the manifest; for an app that is already installed — Maestro's sample, a third-party build — skip
   the build and read the package from `adb -s "$serial" shell pm list packages`. Done when you can state
   the user-visible outcome in one sentence: that sentence is what the flow asserts.

3. **Work the change on the device.** Driving the app through the MCP *is* the debugging loop: `run` with
   inline `{ yaml }` to move around and change state, `cheat_sheet` before commands you have not used,
   `inspect_screen` to see what a screen actually holds, `take_screenshot` when a visual would help.
   Explore freely and keep nothing yet. Two things about what comes back: every tool result is prefixed
   with a Maestro Viewer banner line before its payload, and the hierarchy is abbreviated — read the
   `abbreviations` map it sends (text, resource id, content description, `hint` for a placeholder, …)
   rather than the field names you expect, and never mistake the schema header for a list of elements.
   Done when the change works on the device and you hold, in context, the elements every screen on the
   journey offers.

4. **Write the flow from the hierarchies you gathered.** One flow, in YAML, saved as
   `.maestro/<flow>.yaml` in the repo that owns the app — the kitchen that drove it is not that repo,
   and an app with no repo here keeps the flow in the agent's own workspace. `appId` first, then
   `launchApp`, then the journey you just walked, with strings **copied** from the hierarchies rather
   than retyped. Leave the values that change per run out of the assertions — wall-clock times, counts,
   list order, generated ids — while stable resource-ids stay the durable selectors they are. Done when
   the file asserts the outcome from step 2.

5. **Run the file, from a clean start, until it is green twice.** Your exploration was stateful and the
   flow cannot be: re-enter through the flow's own entry point — `clearState: true`, or an explicit
   `runFlow` setup subflow when the feature needs seeded data — and run it as a file, through the MCP
   (`{ files }` or `{ dir }`; give absolute paths, as the server resolves relative ones against its own
   working directory) or the CLI:

   ```sh
   maestro --device "$serial" test \
     --test-output-dir .maestro/artifacts/report --debug-output .maestro/artifacts/logs \
     .maestro/<flow>.yaml
   ```

   First-launch dialogs, permission prompts and empty states are where a device that already carries
   your taps lies; handling them is the flow's job now. Green is `success: true` from the MCP, or
   `COMPLETED` per step and exit 0 from the CLI. Red is information, not a verdict: the failure names the
   command (`Assertion is false: "…" is visible`) and the artifacts hold that step's screenshot and
   screen hierarchy — fix the flow, or the app, which is the point of the exercise, and run again. Done
   when a second run passes with nothing changed in between.

6. **Retire your device once the PR has merged.** The device is this agent's, not this feature's, so
   whoever saw the merge says so — an agent cannot observe one. Stop it with `maestro-setup` step 5, then
   wipe it with the `avdmanager delete avd --name <device>` command that step names. Done when
   `adb devices` and `emulator -list-avds` no longer show it.

## Rules

- **Ship the file.** An inline session that never ran from disk is not a test.
- **Name your device where it takes one.** `run`, `inspect_screen` and `take_screenshot` need
  `device_id`; `list_devices`, `cheat_sheet` and `open_maestro_viewer` take none. On the CLI and adb pass
  `--device <serial>` / `-s <serial>`. Drive one Maestro process at a time per device.
- **Assert the feature, not the launch.** A flow that only starts the app proves the app runs and
  nothing about the change.
- **One whole journey per flow.** A single flow that carries the user from entry point to outcome beats
  a pile of single-command calls.
- **The app is the app.** Fix the flow when the flow is wrong; when the flow is right and the app is
  not, that failure is the finding — report it rather than loosening the selector.
- **No run artifacts in the repo.** Screenshots, logs and reports go to a directory the owning repo
  ignores, never to the kitchen that drove them.
- **Maestro Cloud is out of scope.** The local device only — never `run_on_cloud` or
  `list_cloud_devices`.
