#! /usr/bin/env bash

sound=/usr/share/sounds/ubuntu/notifications/Rhodes.ogg

if [ -f $sound ]; then
  paplay $sound; paplay $sound
else
  exit 1
fi

