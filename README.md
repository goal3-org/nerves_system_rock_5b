# Radxa Rock 5B

[![Hex.pm](https://img.shields.io/hexpm/v/nerves_system_rock_5b.svg)](https://hex.pm/packages/nerves_system_rock_5b)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/nerves_system_rock_5b/)

This is the base Nerves system definition for the [Radxa Rock 5B](https://radxa.com/products/rock5/5b/).

![Radxa Rock 5B image](assets/images/rock5b.png)
<br><sup>[Radxa Website](https://radxa.com/rock5/rock_5b/banner_rock5b.webp)</sup>

| Feature              | Description                      |
| -------------------- | -------------------------------- |
| CPU                  | Quad-core Cortex-A76 up to 2.4GHz / Quad-small-core Cortex-A55 up to 1.8GHz     |
| Memory               | 4/8/16/32 64 GB LPDDR5           |
| Storage              | Onboard eMMC / MicroSD           |
| Linux kernel         | 6.1 w/ Radxa patches             |
| IEx terminal         | HDMI and USB keyboard (can be changed to UART) |
| GPIO, I2C, SPI       | Yes - [Elixir Circuits](https://github.com/elixir-circuits) |
| ADC                  | No                               |
| PWM                  | Yes, but no Elixir support       |
| UART                 | `ttyFIQ0`                        |
| Display              | HDMI or 7" RPi Touchscreen       |
| Camera               | Untested                         |
| Ethernet             | Yes - 2.5G Ethernet with PoE support (PoE requires hat)  |
| WiFi                 | Yes - VintageNet                 |
| Bluetooth            | Untested                         |
| Audio                | HDMI/Stereo out                  |
| Docker Compose V2   | Optional (off by default, ~59 MB) |

## Using

The most common way of using this Nerves System is create a project with `mix
nerves.new` and to export `MIX_TARGET=rock_5b`. See the [Getting started
guide](https://hexdocs.pm/nerves/getting-started.html#creating-a-new-nerves-app)
for more information.

If you need custom modifications to this system for your device, clone this
repository and update as described in [Making custom
systems](https://hexdocs.pm/nerves/customizing-systems.html).

### Optional: Docker Compose V2

Docker Compose is **not** included by default (adds ~59 MB). To include it, set the build-time env var when building the system:

```sh
export NERVES_SYSTEM_DOCKER_COMPOSE=1
# then build the system (e.g. mix nerves.system.shell, or mix firmware which builds the system)
mix nerves.system.shell
# or from your app: NERVES_SYSTEM_DOCKER_COMPOSE=1 mix firmware
```

The binary is installed at `/usr/bin/docker-compose`. `DOCKER_HOST` is set in `erlinit.config` to `unix:///run/podman/podman.sock` so Compose talks to Podman. Verify from IEx: `System.get_env("DOCKER_HOST")` and `System.cmd("/usr/bin/docker-compose", ["version"], stderr_to_stdout: true)`.

## Linux kernel configuration

The Linux kernel compiled for Nerves is a stripped down version of the default
Radxa Linux kernel. This is done to remove unnecessary features, select
some Nerves-specific features like F2FS and SquashFS support, and to save space.
