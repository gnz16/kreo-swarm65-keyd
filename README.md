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

## macOS (Karabiner-Elements + Herdr CLI)

`keyd` is Linux-only. On macOS, [Karabiner-Elements](https://karabiner-elements.pqrs.org/) remaps the keys and two small scripts in [`bin/`](bin/) drive [Herdr](https://herdr.dev/). The profile is [`config/macos/karabiner.json`](config/macos/karabiner.json).

| Physical control | Runs | Purpose |
|---|---|---|
| Right Shift | sends `fn` | Push-to-talk (Voxtype's hotkey on macOS) |
| Knob rotate CW | `herdr-nav next` | Next Herdr workspace (wraps around) |
| Knob rotate CCW | `herdr-nav prev` | Previous Herdr workspace (wraps around) |
| Knob press | `herdr-focus` | Bring the Ghostty window running Herdr to the front (creates it if missing) |

The knob no longer changes system volume while this profile is active.

### Why a CLI instead of keystrokes

`herdr workspace focus <id>` switches workspaces over Herdr's socket, so rotation needs no terminal focus, no key encoding and cannot type into the wrong app. `herdr-nav` lists workspaces, finds the focused one and focuses the neighbour. This replaced two earlier approaches that failed on macOS:

- **`Alt+Up`/`Alt+Down`**: Terminal.app drops the Option modifier on arrow keys (`Option+Down` arrives as plain `ESC[B`), so Herdr's `alt+up`/`alt+down` bindings never fire. Ghostty with `macos-option-as-alt = true` fixes this, but a global remap would still send arrows to whatever app is focused.
- **Prefix chain** (`ctrl+space`, `shift+n`): works, but only while the terminal is focused.

### Install

```sh
brew install --cask karabiner-elements ghostty
cp bin/herdr-nav bin/herdr-focus ~/.local/bin/
cp config/macos/karabiner.json ~/.config/karabiner/karabiner.json   # or merge rules + devices
echo 'macos-option-as-alt = true' >> ~/.config/ghostty/config
```

Approve the Karabiner driver extension (System Settings, Login Items & Extensions, Driver Extensions) and grant Input Monitoring. `herdr-focus` needs Ghostty 1.3 or newer (AppleScript) and Automation permission for the process that calls it.

### Dock icon (Herdr.app)

`/Applications/Herdr.app` is a wrapper whose stock `Contents/MacOS/Herdr` runs `open -a Ghostty --args <launcher>`. `open` drops `--args` when Ghostty is already running, so the Dock icon opened an empty Ghostty. [`config/macos/Herdr.app-wrapper.sh`](config/macos/Herdr.app-wrapper.sh) replaces it with a call to `herdr-focus`, so the Dock icon and the knob press do the same thing. After replacing the script, re-sign the bundle:

```sh
cp config/macos/Herdr.app-wrapper.sh /Applications/Herdr.app/Contents/MacOS/Herdr
codesign --force --deep -s - /Applications/Herdr.app
```

### Gotchas

- The knob sends Consumer Control usages, so the rules use `consumer_key_code` (`volume_increment`, `volume_decrement`, `mute`), not `key_code`.
- The Kreo reports as both a keyboard and a pointing device, which Karabiner ignores by default. The `devices` entries with `ignore: false` are required.
- Product IDs: `20484` (`0x5004`) is Bluetooth, `20482` (`0x5002`) is wired, vendor `12625` (`0x3151`).
- A Ghostty launched from inside a Herdr pane inherits `HERDR_ENV` and Herdr then refuses to start ("nested herdr is disabled"). `herdr-focus` unsets the `HERDR_*` variables.
- Herdr rewrites window titles, so `herdr-focus` tracks its window by Ghostty's stable window id (`~/.local/state/herdr-nav/window_id`), not by title.

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
