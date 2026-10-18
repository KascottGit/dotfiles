#!/usr/bin/env bash
# OSD popups through notify-send (shown by swaync).
#
# Usage:
#   osd.sh volume up|down [step]   change output volume (default 5%, capped at 100%)
#   osd.sh volume mute             toggle output mute
#   osd.sh volume                  just show the current volume
#   osd.sh mic mute                toggle microphone mute
#   osd.sh mic                     just show mic state
#   osd.sh brightness up|down [step]
#   osd.sh brightness
#   osd.sh kbd-backlight up|down
#   osd.sh caps                    show Caps Lock state
#   osd.sh num                     show Num Lock state
#
# Each OSD type reuses one notification (synchronous hint), so holding a key
# or swiping updates the same popup instead of stacking new ones.

ICONS="$HOME/.config/swaync/icons"
QOGIR="/usr/share/icons/Qogir-Light/24/panel"
TIMEOUT=1500

RUN="${XDG_RUNTIME_DIR:-/tmp}"

# Running many "wpctl/brightnessctl +1%" at once makes them overwrite each
# other, so steps are added to a running total and applied in one go.
# pending_add <name> <delta>   add to the total
# pending_take <name>          print the total and reset it to 0
pending_add() {
    local f="$RUN/hypr-osd-$1.delta" v=0
    {
        flock 8
        [[ -s $f ]] && v=$(<"$f")
        echo $((v + $2)) >"$f"
    } 8>>"$f.lock"
}

pending_take() {
    local f="$RUN/hypr-osd-$1.delta" v=0
    {
        flock 8
        [[ -s $f ]] && v=$(<"$f")
        echo 0 >"$f"
    } 8>>"$f.lock"
    echo "$v"
}

# refresh <name> <show-function>
# Gestures and held keys call this script many times a second. Value changes
# run right away, but only one process redraws the popup at a time. Others
# just mark it as stale and exit, and the drawing process redraws until it
# is up to date. This keeps the popup current without a queue building up.
refresh() {
    local name=$1 show=$2
    local stale="$RUN/hypr-osd-$name.stale"
    : >"$stale"
    exec 9>"$RUN/hypr-osd-$name.lock"
    while :; do
        flock -n 9 || return 0
        while [[ -e $stale ]]; do
            rm -f "$stale"
            "$show"
        done
        flock -u 9
        # A call may have marked it stale just before we unlocked
        [[ -e $stale ]] || return 0
    done
}

# notify <tag> <icon> <title> [percent]
notify() {
    local tag=$1 icon=$2 title=$3 value=$4
    local args=(
        -a "OSD" -u low -t "$TIMEOUT" -e
        -h "string:x-canonical-private-synchronous:osd-$tag"
        -h "string:synchronous:osd-$tag"
    )
    [[ -n $icon ]] && args+=(-i "$icon")
    [[ -n $value ]] && args+=(-h "int:value:$value")
    notify-send "${args[@]}" "$title"
}

# Pick a file from the swaync icon folder, or fall back to a theme icon name.
icon() {
    local file=$1 fallback=$2
    if [[ -f $file ]]; then echo "$file"; else echo "$fallback"; fi
}

# ---- Volume ----------------------------------------------------------------

show_volume() {
    local out vol muted
    out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@) || return
    vol=$(awk '{printf "%d", $2 * 100 + 0.5}' <<<"$out")
    [[ $out == *MUTED* ]] && muted=1

    local ic
    if [[ -n $muted || $vol -eq 0 ]]; then
        ic=$(icon "$ICONS/volume-mute.png" audio-volume-muted)
    elif ((vol < 34)); then
        ic=$(icon "$ICONS/volume-low.png" audio-volume-low)
    elif ((vol < 67)); then
        ic=$(icon "$ICONS/volume-mid.png" audio-volume-medium)
    else
        ic=$(icon "$ICONS/volume-high.png" audio-volume-high)
    fi

    if [[ -n $muted ]]; then
        notify volume "$ic" "Volume: Muted" "$vol"
    else
        notify volume "$ic" "Volume: ${vol}%" "$vol"
    fi
}

volume() {
    local step=${2:-5}
    case $1 in
        up)   pending_add volume "$step" ;;
        down) pending_add volume "-$step" ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac
    refresh volume apply_volume
}

apply_volume() {
    local d
    d=$(pending_take volume)
    if ((d > 0)); then
        # -l 1.0 caps volume at 100%
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "${d}%+"
    elif ((d < 0)); then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$((-d))%-"
    fi
    show_volume
}

# ---- Microphone ------------------------------------------------------------

mic() {
    [[ $1 == mute ]] && wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    local out vol
    out=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@) || return
    vol=$(awk '{printf "%d", $2 * 100 + 0.5}' <<<"$out")

    if [[ $out == *MUTED* ]]; then
        notify mic "$(icon "$ICONS/microphone-mute.png" microphone-sensitivity-muted)" "Microphone: Muted"
    else
        notify mic "$(icon "$ICONS/microphone.png" audio-input-microphone)" "Microphone: On (${vol}%)"
    fi
}

# ---- Screen brightness -----------------------------------------------------

brightness() {
    local step=${2:-5}
    case $1 in
        up)   pending_add brightness "$step" ;;
        down) pending_add brightness "-$step" ;;
    esac
    refresh brightness apply_brightness
}

apply_brightness() {
    local d
    d=$(pending_take brightness)
    if ((d > 0)); then
        brightnessctl -q -e4 -n2 set "${d}%+"
    elif ((d < 0)); then
        brightnessctl -q -e4 -n2 set "$((-d))%-"
    fi
    show_brightness
}

show_brightness() {
    # brightnessctl -m prints: device,class,current,percent%,max
    local pct
    pct=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

    local ic level=$(( (pct + 19) / 20 * 20 ))
    ((level < 20)) && level=20
    ((level > 100)) && level=100
    ic=$(icon "$ICONS/brightness-$level.png" display-brightness)

    notify brightness "$ic" "Brightness: ${pct}%" "$pct"
}

# ---- Keyboard backlight ----------------------------------------------------

kbd_backlight() {
    local dev
    dev=$(brightnessctl -l -m -c leds | cut -d, -f1 | grep -m1 kbd_backlight) || return
    case $1 in
        up)   brightnessctl -q -d "$dev" set 1+ ;;
        down) brightnessctl -q -d "$dev" set 1- ;;
    esac
    local pct
    pct=$(brightnessctl -m -d "$dev" | cut -d, -f4 | tr -d '%')
    notify kbd "keyboard-brightness" "Keyboard backlight: ${pct}%" "$pct"
}

# ---- Lock keys -------------------------------------------------------------

# lock_state capsLock|numLock -> prints true/false for the main keyboard
lock_state() {
    hyprctl devices -j | jq -r --arg k "$1" \
        'first(.keyboards[] | select(.main)) | .[$k]'
}

caps() {
    if [[ $(lock_state capsLock) == true ]]; then
        notify caps "$(icon "$QOGIR/caps-lock-on.svg" input-keyboard)" "Caps Lock: On"
    else
        notify caps "$(icon "$QOGIR/caps-lock-off.svg" input-keyboard)" "Caps Lock: Off"
    fi
}

num() {
    if [[ $(lock_state numLock) == true ]]; then
        notify num "input-keyboard" "Num Lock: On"
    else
        notify num "input-keyboard" "Num Lock: Off"
    fi
}

# ---- Dispatch --------------------------------------------------------------

cmd=$1
shift
case $cmd in
    volume)        volume "$@" ;;
    mic)           mic "$@" ;;
    brightness)    brightness "$@" ;;
    kbd-backlight) kbd_backlight "$@" ;;
    caps)          caps ;;
    num)           num ;;
    *)
        sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
        exit 1
        ;;
esac
