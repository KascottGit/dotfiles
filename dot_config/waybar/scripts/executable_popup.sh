#!/usr/bin/env bash
# Toggle a floating kitty popup opened from the bar.
# Usage: popup.sh <name> <command...>
#
# The window gets the class "waybar-popup-<name>"; size and position come from
# the window rules in ~/.config/hypr/modules/waybar.lua.
# Only one popup is open at a time: clicking the same button again closes it,
# clicking another button swaps it.

name=$1
shift
class="waybar-popup-$name"

was_open=false
while read -r c pid; do
    [[ $c == "$class" ]] && was_open=true
    kill "$pid"
done < <(hyprctl -j clients | jq -r '.[] | select(.class | startswith("waybar-popup-")) | "\(.class) \(.pid)"')

$was_open && exit 0

# 360px is narrow: bluetui drops its device name column above size 8
font_size=8
[[ $name == calendar || $name == media || $name == power ]] && font_size=10

setsid -f kitty --class "$class" \
    -o font_size="$font_size" \
    -o window_padding_width=8 \
    -o confirm_os_window_close=0 \
    -e "$@" >/dev/null 2>&1
