#!/bin/sh

set -e

FWUP_CONFIG=$NERVES_DEFCONFIG_DIR/fwup.conf

# Install/recovery media boot from extlinux-media.conf: the same file with root=
# naming mbr-media's disk signature (0x52354201) instead of the internal disks'
# (0x52354200). Generated rather than kept as a second copy so the two cannot
# drift; see mbr-media in fwup_include/fwup-common.conf.
sed 's/root=PARTUUID=52354200-/root=PARTUUID=52354201-/' \
    "$BINARIES_DIR/extlinux.conf" > "$BINARIES_DIR/extlinux-media.conf"
grep -q 'root=PARTUUID=52354201-02 ' "$BINARIES_DIR/extlinux-media.conf" || {
    echo "post-createfs.sh: extlinux.conf no longer has root=PARTUUID=52354200-02;" >&2
    echo "  update the extlinux-media.conf substitution to match" >&2
    exit 1
}

# Run the common post-image processing for nerves
$BR2_EXTERNAL_NERVES_PATH/board/nerves-common/post-createfs.sh $TARGET_DIR $FWUP_CONFIG
