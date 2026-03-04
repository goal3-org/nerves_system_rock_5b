#!/usr/bin/env bash

set -e

# Create the fwup ops script to handling MicroSD/eMMC operations at runtime
# NOTE: revert.fw is the previous, more limited version of this. ops.fw is
#       backwards compatible.
mkdir -p $TARGET_DIR/usr/share/fwup
$HOST_DIR/usr/bin/fwup -c -f $NERVES_DEFCONFIG_DIR/fwup-ops.conf -o $TARGET_DIR/usr/share/fwup/ops.fw
ln -sf ops.fw $TARGET_DIR/usr/share/fwup/revert.fw

# Copy the fwup includes to the images dir
cp -rf $NERVES_DEFCONFIG_DIR/fwup_include $BINARIES_DIR

# Helper: download a file using whichever tool is available
download() {
  if command -v wget >/dev/null 2>&1; then
    wget -q -O "$2" "$1"
  else
    curl -sSL -o "$2" "$1"
  fi
}

# --- Container runtime (podman-static: full podman + conmon + crun + netavark + aardvark-dns + catatonit) ---
PODMAN_VERSION="v5.8.0"
PODMAN_TAR="podman-linux-arm64.tar.gz"
PODMAN_EXTRACT="/tmp/podman-linux-arm64"

mkdir -p "$TARGET_DIR/usr/bin" "$TARGET_DIR/usr/lib/podman"

download "https://github.com/mgoltzsche/podman-static/releases/download/${PODMAN_VERSION}/${PODMAN_TAR}" "/tmp/${PODMAN_TAR}"
tar xzf "/tmp/${PODMAN_TAR}" -C /tmp

cp "${PODMAN_EXTRACT}/usr/local/bin/podman"  "$TARGET_DIR/usr/bin/podman"
cp "${PODMAN_EXTRACT}/usr/local/bin/crun"    "$TARGET_DIR/usr/bin/crun"
cp "${PODMAN_EXTRACT}/usr/local/lib/podman/conmon"       "$TARGET_DIR/usr/bin/conmon"
cp "${PODMAN_EXTRACT}/usr/local/lib/podman/netavark"     "$TARGET_DIR/usr/lib/podman/netavark"
cp "${PODMAN_EXTRACT}/usr/local/lib/podman/aardvark-dns" "$TARGET_DIR/usr/lib/podman/aardvark-dns"
cp "${PODMAN_EXTRACT}/usr/local/lib/podman/catatonit"    "$TARGET_DIR/usr/lib/podman/catatonit"

chmod 755 "$TARGET_DIR/usr/bin/podman" \
          "$TARGET_DIR/usr/bin/crun" \
          "$TARGET_DIR/usr/bin/conmon" \
          "$TARGET_DIR/usr/lib/podman/netavark" \
          "$TARGET_DIR/usr/lib/podman/aardvark-dns" \
          "$TARGET_DIR/usr/lib/podman/catatonit"

rm -rf "/tmp/${PODMAN_TAR}" "${PODMAN_EXTRACT}"

# Optional: Docker Compose V2 (~59 MB static binary). Off by default; set NERVES_SYSTEM_DOCKER_COMPOSE=1
# when building the system to include it. DOCKER_HOST is set in erlinit.config for Podman.
if [ -n "${NERVES_SYSTEM_DOCKER_COMPOSE:-}" ]; then
  COMPOSE_VERSION="v2.24.5"
  COMPOSE_BINARY="docker-compose-linux-aarch64"
  COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/${COMPOSE_BINARY}"
  mkdir -p $TARGET_DIR/usr/bin
  if command -v wget >/dev/null 2>&1; then
    wget -q -O "$TARGET_DIR/usr/bin/docker-compose" "$COMPOSE_URL"
  else
    curl -sSL -o "$TARGET_DIR/usr/bin/docker-compose" "$COMPOSE_URL"
  fi
  chmod 755 "$TARGET_DIR/usr/bin/docker-compose"
fi
