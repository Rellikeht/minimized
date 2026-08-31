#!/usr/bin/env sh
set -e

command -v file >/dev/null
file --mime-encoding "$1" 2>/dev/null |
    grep -Ev binary >/dev/null || \
    exit 0

PROG=cat
if command -v bat >/dev/null; then
    PROG="bat --color=always -p"
elif command -v highlight >/dev/null; then
    PROG="highlight -O truecolor -s easter"
fi

$PROG "$1"
