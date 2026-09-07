# Notes / dead ends

Two things that looked reasonable but didn't work, in case they save someone else time:

1. **Sending a tmux-style prefix chord (e.g. `macro(C-b n)`) from the knob.** Works only if the target app's prefix actually matches — if it doesn't, the trailing plain key (`n`) gets typed as a literal character into whatever has focus. Don't assume an app's *documented default* keybinding config matches what's actually configured; check the app's real config file first.

2. **Binding the knob to `F15`/`F16` for use inside a terminal app.** `keyd` sent the keys cleanly (confirmed with `sudo keyd monitor`), but the receiving terminal app never reacted. `F13`-`F24` aren't decoded by most terminal emulators unless the Kitty keyboard protocol (CSI-u) is enabled and the app opts in — there's no universal legacy escape sequence for them, unlike `F1`-`F12`. They're fine for a global, WM-level hotkey (caught before the terminal ever sees them) but unreliable for anything that needs to reach an app running inside a terminal. `Alt+Up`/`Alt+Down` (or any already-standard combo) is the safer choice there.
