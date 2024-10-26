#!/usr/bin/env bash

killall -s 3 firefox

NO_PICO_WINDOWS=6
MAX_ROW_SIZE=3
MAX_ROWS=$((NO_PICO_WINDOWS / MAX_ROW_SIZE))

for ((i=1; i<=$NO_PICO_WINDOWS; i++)); do
  firefox --new-window "localhost:5000/" &
  sleep 1

  if [ "$i" -eq 1 ]; then
    sleep 1
    FF_COUNT=`xdotool search --onlyvisible --name firefox | wc -l`
    if [ "$FF_COUNT" -gt 4 ]; then
      break
    fi
  fi

done

ALL_FF_WINDOWS=`xdotool search --onlyvisible --name firefox`

echo "$ALL_FF_WINDOWS"

WIDTH=1920
HEIGHT=1080

X_PAD=$((WIDTH/MAX_ROW_SIZE))
Y_PAD=$((HEIGHT/MAX_ROWS))
X=0
Y=80

echo "$WIDTH,     $HEIGHT"
echo "$X_PAD,     $Y_PAD"

while IFS= read -r window ; do
  xdotool set_desktop_for_window "$window" 0
  xdotool windowmove "$window" $X $Y
  xdotool windowsize "$window" $X_PAD $Y_PAD
  X=$((X+X_PAD))

  if [ "$X" -gt "$((WIDTH-X_PAD))" ]; then
    X=0
    Y=$((Y+Y_PAD))
  fi
done <<< "$ALL_FF_WINDOWS"