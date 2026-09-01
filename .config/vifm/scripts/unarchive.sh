#!/usr/bin/env sh

case "$1" in
    *.tar | \
    *.tgz | \
    *.tbz | \
    *.tbz2 | \
    *.tbz3 | \
    *.txz | \
    *.tzo | \
    *.tar.gz | \
    *.tar.xz | \
    *.tar.bz2 | \
    *.tar.bz3 | \
    *.tar.bz | \
    *.tar.lz4 | \
    *.tar.zst)
        tar xf "$@" ;;

    *.bz2 | *.bz)
        PROG=bunzip
        if command -v pbzip >/dev/null; then
            PROG=pbzip
        fi
        $PROG "$@"
        ;;

    *.gz)
        PROG=gunzip
        if command -v pigz >/dev/null; then
            PROG=pigz
        fi
        $PROG "$@"
        ;;

    *.rar)
        PROG="7z x"
        if command -v unrar >/dev/null; then
            PROG="unrar x"
        elif command -v unrar-free >/dev/null; then
            PROG="unrar-free x"
        fi
        $PROG "$@"
        ;;

    *.iso)
        PROG="bsdtar -xf"
        if command -v 7z >/dev/null; then
            PROG="7z x"
        fi
        $PROG "$@"
        ;;

    *.arj)
        PROG="7z x"
        if command -v arj >/dev/null; then
            PROG="arj x"
        fi
        $PROG "$@"
        ;;

    *.zip) unzip "$@" ;;
    *.xz) unxz -T0 "$@" ;;
    *.7z) 7z x "$@" ;;
    *.bz3) bunzip3 "$@" ;;
    *.zst) unzstd "$@" ;;
    *.lzma) unlzma "$@" ;;
    *.lzo) lzop -d "$@" ;;
    *.lz) lzip -d "$@" ;;
    *.lz4) unlz4 -d "$@" ;;
    *) exit 0 ;;
esac
