#!/usr/bin/env bash
# Run by hypridle after resume. A wake with the lid still closed (logind
# re-suspends it shortly) keeps the screens dark; only a real lid open lights them.

grep -q closed /proc/acpi/button/lid/*/state 2>/dev/null && exit 0
hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = "on" }))' >/dev/null
