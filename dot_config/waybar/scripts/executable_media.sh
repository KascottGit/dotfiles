#!/usr/bin/env bash
# Media controller for the bar popup, driven by playerctl.
# space: play/pause, n/p: next/previous, ←/→: seek 5s, ↑/↓: volume, q or Esc: close.

fmt_time() {   # microseconds -> m:ss
    local s=$(( ${1:-0} / 1000000 ))
    printf '%d:%02d' $((s / 60)) $((s % 60))
}

fit() {        # cut a string to the terminal width
    local s=$1 max=$(( $(tput cols) - 2 ))
    (( ${#s} > max )) && s="${s:0:max-1}…"
    printf '%s' "$s"
}

draw() {
    local cols status player artist title album pos len vol
    cols=$(tput cols)
    # \x1f separator: unlike tabs, empty fields (no album) don't collapse
    IFS=$'\x1f' read -r status player artist title album pos len vol < <(
        playerctl metadata --format \
            $'{{status}}\x1f{{playerName}}\x1f{{artist}}\x1f{{title}}\x1f{{album}}\x1f{{position}}\x1f{{mpris:length}}\x1f{{volume}}' 2>/dev/null)
    pos=${pos%.*} len=${len%.*}   # some players (Firefox) report floats

    tput cup 0 0
    if [[ -z $status ]]; then
        printf ' \e[2mNothing playing\e[0m\e[J'
        return
    fi

    local icon='󰐊'
    [[ $status == Playing ]] && icon='󰏤'
    printf ' \e[2m%s\e[0m\e[K\n\n' "$(fit "$player · $status")"
    printf ' \e[1m%s\e[0m\e[K\n' "$(fit "${title:-Unknown title}")"
    printf ' %s\e[K\n' "$(fit "${artist:-Unknown artist}")"
    printf ' \e[2m%s\e[0m\e[K\n\n' "$(fit "$album")"

    # progress bar: " 1:23 ━━━━━━──── 4:56"
    local cur total width filled=0
    cur=$(fmt_time "$pos")
    total=$(fmt_time "$len")
    width=$(( cols - ${#cur} - ${#total} - 4 ))
    (( ${len:-0} > 0 )) && filled=$(( ${pos:-0} * width / len ))
    (( filled > width )) && filled=$width
    printf ' %s \e[36m%s\e[2m%s\e[0m %s\e[K\n\n' "$cur" \
        "$(printf '━%.0s' $(seq 1 $filled) 2>/dev/null)" \
        "$(printf '─%.0s' $(seq 1 $((width - filled))) 2>/dev/null)" "$total"

    printf ' 󰒮 p   %s space   󰒭 n   vol %s%%\e[K\n' "$icon" "$(awk -v v="${vol:-0}" 'BEGIN{printf "%d", v*100+0.5}')"
    printf ' \e[2m←/→ seek  ↑/↓ volume  q close\e[0m\e[J'
}

tput civis
trap 'tput cnorm' EXIT
clear

while true; do
    draw
    IFS= read -rsn1 -t 1 key || continue
    if [[ $key == $'\e' ]]; then
        read -rsn2 -t 0.01 key || exit 0   # bare Esc
    fi
    case $key in
        ' ') playerctl play-pause ;;
        n) playerctl next ;;
        p) playerctl previous ;;
        '[C') playerctl position 5+ ;;
        '[D') playerctl position 5- ;;
        '[A') playerctl volume 0.05+ ;;
        '[B') playerctl volume 0.05- ;;
        q) exit 0 ;;
    esac
done
