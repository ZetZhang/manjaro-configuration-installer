#!/usr/bin/env bash
killall fcitx
killall sogou-qimpanel
sleep 1
echo "restart fcitx..."
fcitx &
echo "finish"
