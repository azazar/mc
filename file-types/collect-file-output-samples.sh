#!/bin/bash

set -e

cd "$(dirname \"$0\")"

DOCKER=${DOCKER:-"docker"}

collect() {
    local image="$1"; shift
    local install_cmd="$1"; shift

    while [ -n "$1" ]; do
        local image_version="$1"; shift

        build_dir=$(mktemp -d)
        trap "rm -rf $build_dir" EXIT

        echo "Building image $image..."
        echo "FROM $image:$image_version" > "$build_dir/Dockerfile"
        echo "RUN $install_cmd" >> "$build_dir/Dockerfile"
        temp_image_tag="temp-image-$image:$image_version"
        $DOCKER build -t "$temp_image_tag" "$build_dir"
        echo "Running container from image $temp_image_tag..."
        $DOCKER run --rm -v $(cd .. && pwd):/mc "$temp_image_tag" perl /mc/file-types/collect-file-output.pl "$image-$image_version"
    done
}

DEB_INSTALL_CMD='apt-get -y update && apt-get -y install file gzip xz-utils zstd plzip'

collect debian "$DEB_INSTALL_CMD" experimental 13 12 11
collect ubuntu "$DEB_INSTALL_CMD" 26.04 24.04 22.04 20.04

RPM_INSTALL_CMD='yum -y install file gzip xz zstd lzip perl'

collect fedora "$RPM_INSTALL_CMD" 45 44 43 42

ARCH_INSTALL_CMD='pacman -Sy --noconfirm file gzip xz zstd lzip perl'

collect archlinux "$ARCH_INSTALL_CMD" latest

OPENSUSE_INSTALL_CMD='zypper -n install file gzip xz zstd lzip perl'

collect opensuse/leap "$OPENSUSE_INSTALL_CMD" 15
collect opensuse/tumbleweed "$OPENSUSE_INSTALL_CMD" latest

GENTOO_INSTALL_CMD='emerge --sync && emerge --quiet --noreplace file plzip'

collect gentoo/stage3 "$GENTOO_INSTALL_CMD" latest
