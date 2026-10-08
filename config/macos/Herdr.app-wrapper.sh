#!/bin/bash
# Ghostty-only: focus the Ghostty window running Herdr, or create it.
# `open -a Ghostty --args ...` drops args when Ghostty is already running,
# so go through herdr-focus (Ghostty AppleScript) instead.
exec "$HOME/.local/bin/herdr-focus"
