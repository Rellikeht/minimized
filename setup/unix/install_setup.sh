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
	minimized/.config/vifm/vifmrc
do
	FPATH="$HOME/${file#*/}"
	mkdir -p "${FPATH%/*}"
	cp "$file" "$FPATH"
done

clean
