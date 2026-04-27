#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y autoconf autopoint check gettext libtool pkg-config \
                        e2fslibs-dev libaspell-dev libglib2.0-dev libgpm-dev libncurses5-dev libslang2-dev libssh2-1-dev libx11-dev unzip

mkdir -p $HOME/.config/git
cat <<EOF > $HOME/.config/git/ignore
.vscode
.devcontainer
EOF
