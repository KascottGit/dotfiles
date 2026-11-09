#!/usr/bin/env bash
# Month calendar for the clock popup.
# ←/→ or h/l: previous/next month, t: back to today, q or Esc: close.

month=$(date +%-m)
year=$(date +%Y)

tput civis
trap 'tput cnorm' EXIT

while true; do
    clear
    echo
    cal --color=always "$month" "$year" | sed 's/^/ /'

    read -rsn1 key
    if [[ $key == $'\e' ]]; then
        read -rsn2 -t 0.01 key || exit 0   # bare Esc
    fi
    case $key in
        h|'[D') ((month--)) ;;
        l|'[C') ((month++)) ;;
        t) month=$(date +%-m); year=$(date +%Y) ;;
        q) exit 0 ;;
    esac
    if ((month < 1)); then month=12; ((year--)); fi
    if ((month > 12)); then month=1; ((year++)); fi
done
