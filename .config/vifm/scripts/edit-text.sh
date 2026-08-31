#!/usr/bin/env sh
set -e

command -v file >/dev/null
file --mime-encoding "$1" 2>/dev/null |
    grep -Ev binary >/dev/null || \
    exit 0
PROG="$EDITOR"
[ $# -eq 2 ] && PROG="$2"
$PROG "$1"
