# Kreo Swarm65 keyd remaps

[`keyd`](https://github.com/rvaiya/keyd) configs for the Kreo Swarm65 keyboard, covering both its Bluetooth and wired connection modes.

## Bindings

| Physical control | Sends | Purpose |
|---|---|---|
| Right Shift | `F13` | Push-to-talk key for dictation/voice apps |
| Knob rotate CW | `Alt+Down` | Cycle forward (e.g. next workspace/tab in an app that binds Alt+Down) |
| Knob rotate CCW | `Alt+Up` | Cycle backward |
| Knob press | `F6` | App-specific (bind `F6` in your WM to whatever you want the knob-press to open) |

`Alt+Up`/`Alt+Down` and `F6` were picked because they're standard, widely-recognized bindings that most terminal emulators and window managers already forward correctly — unlike `F13`-`F24`, which many terminals don't decode at all unless the Kitty keyboard protocol is enabled. See [`NOTES.md`](NOTES.md) for the debugging story behind that choice.

## Install

```sh
./install.sh
```

This copies both config files to `/etc/keyd/` and restarts the `keyd` service.

## Wired mode: knob is a separate device

When wired (USB-C), the knob's volume/mute events come from a distinct
`Kreo Swarm65 Consumer Control` evdev node, not the main Keyboard node used
for Right Shift. Over Bluetooth, no such separate node exists — the same
Keyboard node emits everything, so `kreo-swarm65.conf` handles it all in one
file. Wired therefore needs a third file, `kreo-swarm65-wired-consumer.conf`,
targeting that Consumer Control node's own id. Find it the same way as any
other id (see below); it prints as a separate `DEVICE: ignoring ... Consumer
Control` line in `journalctl -u keyd` until it's added to a config.

## Your keyboard's IDs will differ

The `[ids]` line in each config (`3151:5004:...` / `3151:5002:...`) includes a device-instance hash that's tied to *this* keyboard's Bluetooth pairing slot and USB enumeration on the machine this was built on. Yours will be different. To find your own:

```sh
sudo journalctl -u keyd | grep -i kreo
```

Reconnect the keyboard (or replug the cable) right before running that, then copy the printed `vendor:product:hash` id into the `[ids]` section.

## Known gotcha

`sudo keyd reload` can crash (`SEGV`) the `keyd` daemon after a config change on some setups, silently killing all remapping (including on unrelated keyboards). If remaps stop working after an edit, check `systemctl status keyd` for a crashed unit before re-diagnosing the config. `systemctl restart keyd` (what `install.sh` uses) doesn't have this problem.

## License

[PolyForm Noncommercial 1.0.0](LICENSE) — personal, non-commercial use only.
