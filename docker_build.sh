#!/usr/bin/env bash

docker build -t multiple-pony server/
#docker run -it --rm --name multiple-pony multiple-pony
#docker run --publish 5000:5000 multiple-pony