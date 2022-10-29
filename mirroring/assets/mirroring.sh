#!/usr/bin/env bash
cd ./mirroring_android_workspace/screens

while true
do
  filename=screen.png
  adb shell screencap /sdcard/$filename
  adb pull /sdcard/$filename
  adb shell rm -f /sdcard/$filename
done
