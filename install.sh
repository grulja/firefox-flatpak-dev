#!/bin/sh

flatpak remote-add --user --no-gpg-verify --if-not-exists firefox-devel repo
flatpak install --user --assumeyes --or-update firefox-devel org.mozilla.firefox
