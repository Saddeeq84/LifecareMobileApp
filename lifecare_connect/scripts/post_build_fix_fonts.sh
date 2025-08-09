#!/bin/bash
# Post-build script to copy OpenSans fonts to the correct directory for Flutter web bug workaround
set -e

SRC="build/web/assets/assets/fonts"
DST="build/web/assets/fonts"

if [ -d "$SRC" ]; then
  mkdir -p "$DST"
  cp -v "$SRC"/* "$DST"/
else
  echo "Source font directory $SRC does not exist. Skipping font copy."
fi
