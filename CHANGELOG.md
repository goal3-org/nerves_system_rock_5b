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
