#!/usr/bin/env sh

if [ "$#" -lt 2 ]; then
  echo Give mount point and remote source
fi

DEST="$HOME/.config/systemd/user"
FILENAME="$(systemd-escape -p --suffix=mount "$2")"
TEMP=$(mktemp -d)
clean() {
  rm -fr "$TEMP"
}
trap clean EXIT

cd "$TEMP"
{
  echo "[Unit]"
  echo "Description=Mount sshfs from $1 on $2"
  echo "After=network-online.target sockets.target"
  echo "Wants=network-online.target sockets.target"
  echo
  echo "[Mount]"
  echo "What=$1"
  echo "Where=$2"
  echo "Type=sshfs"
  echo "Options=auto_cache,reconnect"
  echo
  echo "[Install]"
  echo "WantedBy=default.target"
} > "$FILENAME"
cd - >/dev/null

if [ -n "$NO_INSTALL" ]; then
  cp "$TEMP/$FILENAME" .
  exit 0
fi
mkdir -p "$DEST"
cp "$TEMP/$FILENAME" "$DEST"
echo "Installed $FILENAME"
