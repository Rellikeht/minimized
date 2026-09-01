#!/usr/bin/env sh
set -e

command -v file >/dev/null
PROG="$EDITOR"
[ $# -eq 2 ] && PROG="$2"

if wc -c "$1" | grep -E "^0 " >/dev/null; then
    $PROG "$1"
elif file --mime-encoding "$1" 2>/dev/null |
    grep -Ev binary >/dev/null; then
    $PROG "$1"
fi
