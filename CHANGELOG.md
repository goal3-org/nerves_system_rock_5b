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

## v0.1.7

Delta firmware updates: declare a block cache so they come out small.

`fwup.conf` now sets `block-cache-size-mb = 256`. NervesHub reads that key from
the firmware's `meta.conf` and uses it as the source window it hands xdelta3
when generating a delta. Without it xdelta3 falls back to 64 MB against a
~240 MB rootfs, and the delta is roughly 140x larger — measured on two real
builds differing only by a version bump: 4.40 MB at the default window versus
0.03 MB at 256 MB, out of a 96 MB full image.

The same value sizes the cache fwup uses when *applying* a delta, which is why
it is declared by the firmware rather than chosen by the server. Both targets
have 16 GB of RAM, so 256 MB costs nothing during an update.

* Changes
  * `nerves_system_br` 1.32.3 -> 1.34.4, which brings fwup 1.16.0 to the target
    (`0011-fwup-bump-to-v1.16.0.patch`). `block-cache-size-mb` needs fwup
    1.16.0 to build, and a device needs it to honour the value rather than
    apply with fwup's fixed 8 MB cache.
  * `require-fwup-version` deliberately left at 0.15.0. Older fwup ignores an
    unknown key in `meta.conf`, so this firmware still applies on a device
    running 1.13.2 — slowly, but without error. Raising the requirement would
    refuse those devices instead.

## v0.1.6

Version bump so the Nerves artifact cache stops serving a pre-0.1.5 build.

The cache is keyed on name and version only, so the three commits after the
v0.1.5 release — booting from whichever disk the image was installed on,
reading the U-Boot environment from that disk, and the ECN defconfig fix — were
silently absent from every firmware built against this source. An image built
this way still carries `root=/dev/mmcblk1p2` and no MBR disk signature, so it
boots from a microSD and hangs in `rootwait` on any other disk: powered, and
silent.

No source changes; the fixes were already here. Only the version needed to move
so they reach an image.

## v0.1.0

This is an initial release to make it easier for more people to test Nerves on
the Radxa Rock 5B. Not all the features of the board are supported yet and fully tested, 
but this release should be a good starting point.
