# Changelog

This project does NOT follow semantic versioning. The version increases as
follows:

1. Major version updates are breaking updates to the build infrastructure.
   These should be very rare.
2. Minor version updates are made for every major Buildroot release. This
   may also include Erlang/OTP and Linux kernel updates. These are made four
   times a year shortly after the Buildroot releases.
3. Patch version updates are made for Buildroot minor releases, Erlang/OTP
   releases, and Linux kernel updates. They're also made to fix bugs and add
   features to the build infrastructure.

## v0.1.6

Boots from the disk it was installed on, and supports small delta updates.

* Boot
  * Boots from whichever disk the image was installed on, rather than the
    hard-coded microSD. An image built before this carries
    `root=/dev/mmcblk1p2` and no MBR disk signature, so on any other disk it
    hangs in `rootwait`: powered, and silent.
  * Reads the U-Boot environment from that same disk instead of the microSD.
  * `CONFIG_IP_NF_TARGET_ECN` disabled in `linux-6.1.defconfig`.

* Delta updates
  * `nerves_system_br` 1.32.3 -> 1.34.4, bringing fwup 1.16.0 to the target
    (`0011-fwup-bump-to-v1.16.0.patch`).
  * OTP pinned to 28 (`BR2_PACKAGE_ERLANG_28=y`) rather than inheriting
    Buildroot 2026.05's default of 29, which would have been an unintended
    runtime change riding along with a build-infrastructure bump.
  * `fwup.conf` sets `block-cache-size-mb = 256`. This is about *applying* a
    delta: fwup reads the source partition through its block cache, and the
    8 MB default against a ~240 MB rootfs means segments are evicted and
    re-read. It is declared by the firmware because the device is what has to
    hold it; this unit has 16 GB of RAM.

    NervesHub also reads the key — from the *target* firmware's `meta.conf`,
    re-parsed at generation time — and passes it to xdelta3 as the source
    window (`-B`), where xdelta3 would otherwise use its own 64 MB default.
    Measured on both real release pairs with the hub's exact argument list,
    that makes almost no difference to delta size: 4,103 bytes without `-B`
    versus 3,842 with on one pair, 7,426,219 versus 7,439,987 on the other —
    marginally worse with the larger window. An earlier measurement suggested
    a ~140x reduction; that pair could not be reproduced and the claim is
    withdrawn. Delta size is not the reason to set this key.
  * `fwup.conf` declares FAT delta sources for `Image` and the board dtb, so
    they stop shipping whole in every delta package. Measured on two real
    builds from the same source firmware, the delta went from **9.6 MB** to
    **12.4 KB** against a 96.6 MB full image — almost all of that 9.6 MB was
    unchanged kernel bytes, since only `rootfs.img` had a delta source. Needs
    fwup >= 1.10.0 on the device. The source is the *currently active* boot
    partition, which is always valid: `complete` formats BOOT_A and each
    upgrade writes the other slot, so `upgrade.a` only runs while B is active
    and vice versa. Verified applying on hardware.
  * `upgrade.b`'s rootfs delta source was `ROOTFS_B` — the slot being
    overwritten — instead of `ROOTFS_A`, the running slot that holds the
    firmware the delta was generated against. Every rootfs delta applied by
    that task decoded against the wrong bytes and failed with
    `xdelta3 error: target window checksum mismatch`, so an update landing on
    slot B could only ever be applied in full. `upgrade.a` always had it
    right, which is why this survived: updates alternate slots, so roughly
    half of them worked. Predates this fork's first commit. Reproduced on
    hardware, and the fix verified by applying the same delta afterwards.
  * `require-fwup-version` deliberately left at 0.15.0. Older fwup ignores an
    unknown key in `meta.conf`, so this firmware still applies on a device
    running 1.13.2 — slowly, but without error. Raising it would refuse those
    devices instead.

* Watchdog
  * `linux/0002-Enable-the-hardware-watchdog.patch` sets `status = "okay"` on
    `watchdog@feaf0000`. `CONFIG_WATCHDOG` and `CONFIG_DW_WATCHDOG` were
    already set and the node's compatible matches, but the node is disabled in
    `rk3588s.dtsi`, so no `/dev/watchdog0` was created and `nerves_heart` ran
    without one — logging a single line at boot and leaving a wedged BEAM with
    nothing to reset it. Confirmed on hardware afterwards:
    `wdt_identity: "Synopsys DesignWare Watchdog"`.

Note on the artifact cache: it is keyed on name and version only, so source
changes without a version bump are silently absent from every image built
against this checkout. That is what hid the boot fixes above before this
release.

## v0.1.0

This is an initial release to make it easier for more people to test Nerves on
the Radxa Rock 5B. Not all the features of the board are supported yet and fully tested, 
but this release should be a good starting point.
