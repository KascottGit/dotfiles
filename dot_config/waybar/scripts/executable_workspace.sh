#!/usr/bin/env bash
# One workspace button (custom/ws#N in config.jsonc).
#
# Replaces the built-in hyprland/workspaces module: its click handler sends the
# old "dispatch workspace N" IPC command, which the Lua config rejects.
# Prints nothing (which hides the button) when workspace N isn't on this bar's
# output. Re-run on SIGRTMIN+8, sent from ~/.config/hypr/modules/waybar.lua.

id=$1

hyprctl --batch "j/workspaces;j/monitors" | jq -sc --argjson id "$id" --arg out "$WAYBAR_OUTPUT_NAME" '
    .[0] as $ws | .[1] as $mons
    | ($mons[] | select(.name == $out)) as $mon
    | ($mons[] | select(.focused) | .activeWorkspace.id) as $active
    | if any($ws[]; .id == $id and .monitor == $out) then
        { text: ($id | tostring),
          class: [ if $id == $active then "active" else empty end,
                   if $id == $mon.activeWorkspace.id then "visible" else empty end ] }
      else { text: "" } end'
