#!/usr/bin/env sh

clean() {
	cd -
	rm -fr "$TEMP"
}

TEMP=$(mktemp -d)
cd "$TEMP"
git clone "https://github.com/Rellikeht/minimized.git"

for file in \
	minimized/.config/nvim/init.lua \
	minimized/.config/nvim/lua/code.lua \
	minimized/.config/vifm/vifmrc \
	minimized/bashrc
do
	FPATH="$HOME/${file#*/}"
	mkdir -p "${FPATH%/*}"
    if [ "$1" = "-f" ]; then
        cp --update=all "$file" "$FPATH"
    elif [ "$1" = "-u" ]; then
        cp --update=older "$file" "$FPATH"
    else
        cp --update=none "$file" "$FPATH"
    fi
done

clean
