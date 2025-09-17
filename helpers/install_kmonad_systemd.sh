#!/usr/bin/env sh

if [ "$#" -lt 1 ]; then
    echo "Give block device name"
    exit 1
fi

DNAME="${1##*/}"
DEST="$HOME/.config/systemd/user"
KBD="$HOME/.kmonad/$DNAME.kbd"
FILENAME="$(systemd-escape -p --suffix=service "$DNAME" 2>/dev/null)"
TEMP=$(mktemp -d)
clean() {
    rm -fr "$TEMP"
}
trap clean EXIT

cd "$TEMP"
{
    echo "[Unit]"
    echo "Description=Kmonad instance for $1"
    echo "After=network-online.target sockets.target"
    echo "Wants=network-online.target sockets.target"
    echo
    echo "[Service]"
    echo "ExecStart=bash -c 'PATH=\"\$PATH:%h/.nix-profile/bin:\" kmonad $KBD'"
    echo "Type=simple"
    echo "Restart=always"
    echo "RestartSec=2"
    echo
    echo "[Install]"
    echo "WantedBy=default.target"
} > "$FILENAME"
cd - >/dev/null

if [ -n "$NO_INSTALL" ]; then
    cat "$TEMP/$FILENAME"
    exit 0
fi
mkdir -p "$DEST"
cp "$TEMP/$FILENAME" "$DEST"
echo "Installed $FILENAME"
