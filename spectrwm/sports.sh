#!/bin/sh

cat /tmp/mlb.txt /tmp/nba.txt /tmp/nfl.txt | dmenu "$@" | xclip
