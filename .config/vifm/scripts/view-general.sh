#!/usr/bin/env sh

if [ -d "$1" ]; then
    command -v file >/dev/null || exit 0
    tree -L1 "$1"
    exit 0
fi

command -v file >/dev/null || exit 0
if file --mime-encoding "$1" 2>/dev/null | grep -v binary >/dev/null; then
    PROG=cat
    if command -v bat >/dev/null; then
        PROG="bat --color=always -p"
    elif command -v highlight >/dev/null; then
        PROG="highlight -O truecolor -s easter"
    fi
    $PROG "$1"
else
    PROG=file
    if command -v mediainfo >/dev/null; then
        PROG="mediainfo"
    fi
    $PROG "$1"
fi
