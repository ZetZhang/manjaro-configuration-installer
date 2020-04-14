#!/usr/bin/env bash
#declare i=`ps -ef | grep dock | awk '{print $2}' | head -n 1`
#echo $i
wh=`which cairo-dock`
killall cairo-dock
$wh -f -o & nohup
