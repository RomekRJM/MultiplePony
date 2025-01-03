#!/usr/bin/env bash

/home/rjm/workspace/pico-8/pico8 -run game/multiplePony.p8 &

sleep 4.5

PICO_FOLDER=~/.lexaloffle/pico-8/carts
PICO_WINDOW="MULTIPLEPONY.P8 (PICO-8)"

rm -rf "$PICO_FOLDER/game.*"

wmctrl -R "$PICO_WINDOW" &&
  xdotool key F2 &&
  xdotool key Escape && xdotool type "export game.html" && xdotool key Return &&
  xdotool sleep 0.5 && xdotool type "exit()" && xdotool key Return

mv "$PICO_FOLDER/game.js" server/public/
mv "$PICO_FOLDER/game.html" server/public/

sed -i 's/game.js/public\/game.js/g' server/public/game.html
