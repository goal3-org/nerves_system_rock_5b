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
