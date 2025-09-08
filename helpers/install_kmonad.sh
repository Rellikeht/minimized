#!/usr/bin/env sh

if [ "$#" -lt 1 ]; then
    echo "Give block device name"
    exit 1
fi

SRC="$(readlink -f "${0%/*}/../kmonad/standard60.kbd")"
DEST="$HOME/.kmonad"
mkdir -p "$DEST"
if [ -n "$2" ]; then
    DEST="$DEST/$2"
else
    DEST="$DEST/${1##*/}.kbd"
fi

sed "s#\"BLOCK_DEVICE\"#\"$1\"#" "$SRC" > "$DEST"
