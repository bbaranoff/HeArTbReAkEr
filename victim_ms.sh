#!/bin/bash
tmux new-session -d -s "mysession"
tmux new-window -n "TRX"
tmux send-keys -t "TRX" '/opt/GSM/bb-attack/src/host/osmocon/osmocon -m c123 -p /dev/ttyUSB1 -c layer1.highram.bin' Enter
tmux new-window -n "MS"
tmux send-keys -t "MS" '/opt/GSM/bb-attack/src/host/layer23/src/mobile/mobile'
tmux attach
