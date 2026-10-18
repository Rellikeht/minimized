#!/usr/bin/env sh

SDIR="$(readlink -f "$0")"
SDIR="${SDIR%/*}"
SRC="$(readlink -f "$SDIR/../..")"
DEST="$1"

if ! [ -d "$1" ]; then
    echo "$1 isn't a directory"
    exit 1
fi

for item in \
	".config/nvim/init.lua" \
	".config/vifm" \
	".bashrc" \
	".vimrc" \

do
    dirs="${item%/*}"
    [ "$dirs" = "$item" ] && dirs=""
    mkdir -p "${DEST}/${dirs}"
    cp -rs --update=older "${SRC}/${item}" "${DEST}/${dirs}"
done
