#!/usr/bin/env bash
# Power menu for the bar popup (replaces wlogout).
# ↑/↓ or j/k: select, Enter: run, s/r/p/l: run directly, q or Esc: close.

icons=('󰤄' '󰜉' '󰐥' '󰍃')
labels=('Sleep' 'Reboot' 'Shut down' 'Log out')
keys=(s r p l)
actions=(
    'systemctl suspend'
    'systemctl reboot'
    'systemctl poweroff'
    'loginctl kill-session "$XDG_SESSION_ID"'
)

sel=0

draw() {
    local i
    tput cup 0 0
    printf '\e[K\n'
    for i in "${!labels[@]}"; do
        if ((i == sel)); then
            printf ' \e[30;46m %s  %-10s %s \e[0m\e[K\n' "${icons[i]}" "${labels[i]}" "${keys[i]}"
        else
            printf '  %s  %-10s \e[2m%s\e[0m\e[K\n' "${icons[i]}" "${labels[i]}" "${keys[i]}"
        fi
    done
    printf '\e[K\n \e[2m↑/↓ select  ⏎ run  q close\e[0m\e[J'
}

run() {
    tput cnorm
    clear
    eval "${actions[$1]}"
    exit 0
}

tput civis
trap 'tput cnorm' EXIT
clear

while true; do
    draw
    IFS= read -rsn1 key
    if [[ $key == $'\e' ]]; then
        read -rsn2 -t 0.01 key || exit 0   # bare Esc
    fi
    case $key in
        k|'[A') sel=$(( (sel + 3) % 4 )) ;;
        j|'[B') sel=$(( (sel + 1) % 4 )) ;;
        '') run "$sel" ;;                  # Enter
        s) run 0 ;;
        r) run 1 ;;
        p) run 2 ;;
        l) run 3 ;;
        q) exit 0 ;;
    esac
done
