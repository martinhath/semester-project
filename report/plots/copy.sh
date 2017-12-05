#!/bin/bash

if [[ "$1" =~ ^$ ]]; then
  DIR="/home/martin/hath/master/comere/plots"
else
  DIR="$1"
fi

cp $DIR/*.pdf .
