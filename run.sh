#!/bin/sh

if [ -z $1 ]; then
  CMD="firefox"
else
  CMD=$1
fi

flatpak-builder --run -v build org.mozilla.firefox.json ${CMD}
