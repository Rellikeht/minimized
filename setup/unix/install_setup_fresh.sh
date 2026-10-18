#!/usr/bin/env sh

DEST="$1"
if ! [ -d "$1" ]; then
    echo "$1 isn't a directory"
    exit 1
fi
shift

clean() {
	cd -
	rm -fr "$TEMP"
}

TEMP=$(mktemp -d)
cd "$TEMP"
trap clean EXIT INT
git clone "https://github.com/Rellikeht/minimized.git"
SRC=minimized

for item in \
	".config/nvim/init.lua" \
	".config/vifm" \
	".bashrc" \
	".vimrc" \

do
    src="${SRC}/${item}"
    dest="${DEST}/${item%/*}"
    [ "$dirs" = "$item" ] && dest="$DEST"
    mkdir -p "$dest"
    if [ "$1" = "-f" ]; then
        cp --update=all "$src" "$dest"
    elif [ "$1" = "-u" ]; then
        cp --update=older "$src" "$dest"
    else
        cp --update=none "$src" "$dest"
    fi
done
