#!/usr/bin/env bash
# nmtui for the bar popup, recoloured to sit on the transparent Nord kitty
# instead of newt's default blue. Names map to kitty's Nord palette;
# "default" is the terminal background.

export NEWT_COLORS='
root=white,default
roottext=white,default
helpline=white,default
window=white,default
border=white,default
shadow=default,default
title=cyan,default
label=white,default
textbox=white,default
acttextbox=black,cyan
listbox=white,default
actlistbox=black,cyan
sellistbox=cyan,default
actsellistbox=black,cyan
button=white,gray
actbutton=black,cyan
compactbutton=white,default
checkbox=white,default
actcheckbox=black,cyan
entry=white,gray
disentry=gray,default
emptyscale=,gray
fullscale=,cyan
'
exec nmtui "$@"
