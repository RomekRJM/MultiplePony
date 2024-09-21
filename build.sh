#!/usr/bin/env bash

/home/rjm/workspace/pico-8/pico8 -run game/multiplePony.p8 &

sleep 5.5

PICO_FOLDER=~/.lexaloffle/pico-8/carts
PICO_WINDOW="MULTIPLEPONY.P8 (PICO-8)"

rm -rf "$PICO_FOLDER/game.*"

wmctrl -R "$PICO_WINDOW" &&
  xdotool key F2 &&
  xdotool key Escape && xdotool type "export game.html" && xdotool key Return &&
  xdotool sleep 0.5 && xdotool type "exit()" && xdotool key Return

mv "$PICO_FOLDER/game.js" server/
mv "$PICO_FOLDER/game.html" server/