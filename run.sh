#!/bin/sh

if [ -z $1 ]; then
  CMD="firefox"
else
  CMD=$1
fi

flatpak run --user --command=${CMD} org.mozilla.firefox
