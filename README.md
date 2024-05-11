# VsyncExtractor
Designed to detect and output a simple vsync signal out of various video signals

Currently a work in progress; actively developing for  DVI/HDMI video protocol at the moment

Synthesizes using `prjtrellis (yosys + nextpnr for EPC5)` for use on an `LFE5UM5G-85F-EVN`

Modify `Makefile` to contain the path to your trellis install

`make` to build

`make flash` for flashing the firmware onto the SPI flash for permanant memory

`make test` for flashing the bitstream in volatile memory

Requires `openFPGALoader` for flashing

Supports TAS playback using the same serial protocol as the [TAStm32](https://github.com/Ownasaurus/TAStm32)
Also supports controller passthrough
