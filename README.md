![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Balanced%20Ternary-orange.svg)
![CPU](https://img.shields.io/badge/CPU-5500FP-green.svg)
![Language](https://img.shields.io/badge/Language-Assembly-red.svg)
![FPGA](https://img.shields.io/badge/FPGA-Efinix%20Trion%20T20F256-purple.svg)
![Status](https://img.shields.io/badge/Status-Stable%20Base-lightgrey.svg)

# GRam_OS

GRam_OS is a minimal operating system for the **5500FP**, a 24-trit balanced ternary RISC processor implemented on FPGA, and its open hardware development board **GargantuRAM**. It is written entirely in 5500FP Assembly and runs on real hardware.

This repository serves as a foundation for anyone who wants to develop software for the 5500FP architecture, and as a concrete proof that the system works correctly end-to-end — not just in its ternary computational core, but in all its foundational subsystems.

## The Hardware Platform

The **5500FP** is a 24-trit balanced ternary RISC processor featuring a 120-instruction ISA, up to 81 general-purpose registers, native atomic instructions (CAS, FAA), and dual user/kernel stack pointers. It is implemented on an **Efinix Trion T20F256** FPGA running at 20 MHz and presents a fully balanced ternary external interface (±3.3 V physical signals).

The **GargantuRAM** development board provides: 16M Word (64 MTryte) of static RAM, SD card slot, SPI ROM, and two USB serial interfaces.

More information on the architecture: [ternary-computing.com](https://www.ternary-computing.com)

## What GRam_OS Does

GRam_OS initializes the hardware and presents an interactive shell with the following built-in commands: `cls` (clears the screen), `version` (displays the OS version), `ls` (lists the contents of the SD Card via a simple dedicated filesystem), `run` (launches a program stored on the SD Card).

## Who is it for

This repository is intended for anyone who wants to:

- have a working starting point for developing an OS or software on the 5500FP
- study how a balanced ternary CPU is programmed through real, running code
- contribute improvements: new shell commands, a richer filesystem, interrupt handling, and more

## Author's note

This branch is released under the Apache 2.0 permissive license and will not be further developed by the author. Anyone is free to fork it and take it in whatever direction they prefer, including commercial and closed-source projects.

## License

Distributed under the **Apache 2.0** permissive license.
See [LICENSE](LICENSE) and [NOTICE](NOTICE) for details.

Copyright (c) 2024-2026 Claudio La Rosa
