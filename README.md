# pynqcast — FPGA Raycaster on PYNQ-Z1

A real-time Wolfenstein 3D-style DDA raycaster implemented in Verilog/SystemVerilog on the Xilinx Zynq XC7Z020 (PYNQ-Z1). The PL renders 640×480 over HDMI at ~60fps while the PS writes player state to shared BRAM.

![Vivado 2020.2](https://img.shields.io/badge/Vivado-2020.2-blue)
![Board](https://img.shields.io/badge/Board-PYNQ--Z1-green)
![FPGA](https://img.shields.io/badge/FPGA-XC7Z020-orange)

<!-- TODO: add a screenshot or GIF of the raycaster running -->

## Features

- **DDA ray casting** — 640 rays/frame,
- **Wall texturing** — 32×32 RGB textures from BRAM `.mem` files
- **Sprite rendering** — camera-space inverse transform, restoring divider for screen projection, z-buffer occlusion
- **HDMI output** — AXI4-Stream pixel pipeline through Digilent rgb2dvi at 640×480
- **PS ↔ PL interface** — AXI BRAM controller for player position, angle, map, and sprite coordinates

## Architecture

The repo contains **two Vivado projects** that work together:

```
┌──────────────────────────────────────────────────────────────────────┐
│  PROJECT 1: raycaster_ip_development                                │
│  Purpose:   Develop & package the raycaster as a reusable Vivado IP │
│                                                                      │
│  ray_caster.sv (top)                                                │
│   ├── dir_vec.v           angle → dir/plane LUT (12-bit)            │
│   ├── reciprocal_f.v      |1/rayDir| → Q6.12 deltaDist LUT         │
│   ├── dda_main_body.v     DDA stepping FSM + wallX calculation      │
│   ├── sprite_caster.v     sprite camera transform + divider         │
│   ├── dividor.sv          sequential restoring divider              │
│   ├── wall_texturer.v     32×32 RGB444 texture lookup               │
│   ├── sprite_texturing.sv sprite texture sampling                   │
│   └── hdmi_pixel_stream_gen.v  column→raster + AXI4-Stream out     │
│                                                                      │
│  Packaged as: component.xml (IP-XACT)                               │
│  Interfaces:  AXI4-Stream master (pixel data)                        │
│               BRAM port (map + player state)                         │
│               Clock, reset, tready                                   │
└──────────────────────┬───────────────────────────────────────────────┘
                       │ IP repo path
┌──────────────────────▼───────────────────────────────────────────────┐
│  PROJECT 2: ray_caster (system integration)                          │
│  Purpose:   Block design connecting PS, BRAM, raycaster IP, HDMI     │
│                                                                      │
│  Block Design (design_1)                                             │
│   ├── processing_system7_0   ARM Cortex-A9 (game logic, networking) │
│   ├── axi_bram_ctrl_0        AXI BRAM controller                    │
│   ├── blk_mem_gen_0          shared BRAM (map + pos/angle/sprite)   │
│   ├── ray_caster_0           ← the packaged IP from Project 1      │
│   ├── hdmi_480p_220hz_0      rgb2dvi + pixel clock generation       │
│   ├── axi_gpio_0             button inputs                          │
│   └── axi_smc + utilities    interconnect, reset, constants         │
└──────────────────────────────────────────────────────────────────────┘
```

### Fixed-Point Formats

| Signal | Format | Usage |
|--------|--------|-------|
| `pos_x/y` | Q6.10 | Player position (0–63 map range) |
| `dir_x/y`, `plane_x/y` | Q2.14 | Direction and camera plane vectors |
| `deltaDist` | Q6.12 | Ray step distances (reciprocal LUT) |
| `sideDist` | Q6.12 | Accumulated DDA distances |

## Prerequisites

- **Vivado 2020.2** (the block design was authored in 2020.2 — other versions may need IP upgrades)
- **PYNQ-Z1** board (or any Zynq-7020 board with HDMI out — update the `.xdc` constraints)
- HDMI display

## Quick Start

### 1. Clone with submodule

```bash
git clone --recursive https://github.com/louis574/HardwareSide_PYNQ_Raycaster.git
cd HardwareSide_PYNQ_Raycaster
```

If you already cloned without `--recursive`:
```bash
git submodule update --init
```

### 2. Create the Vivado project

1. Open **Vivado 2020.2**
2. In the **Tcl Console** at the bottom, run:

```tcl
cd <path-to-repo>
source scripts/create_project.tcl
```

> **Note:** Use forward slashes in the path, not backslashes (e.g. `cd C:/Users/you/HardwareSide_PYNQ_Raycaster`).

This builds into `build/` — the raycaster IP is already pre-packaged (`component.xml` is committed), so you only need to run the one script.

### 3. Generate bitstream

1. Open `build/ray_caster.xpr` in Vivado (or it will already be open after step 2)
2. **Generate Bitstream** (runs synthesis → implementation → bitstream)
3. **File → Export → Export Hardware** (include bitstream)

### 4. Deploy to PYNQ

Copy the `.bit` and `.hwh` files to the board. The raycaster starts rendering as soon as the overlay is loaded — the PS writes player position, angle, and map data to BRAM addresses `0x20`–`0x22`.

## Modifying the RTL

If you edit any of the Verilog/SystemVerilog sources, you need to re-package the IP before rebuilding the system project. In the Vivado Tcl Console:

```tcl
cd <path-to-repo>
source scripts/package_ip.tcl
source scripts/create_project.tcl
```

## Repository Structure

```
HardwareSide_PYNQ_Raycaster/
├── scripts/
│   ├── create_project.tcl          # Creates system integration project
│   └── package_ip.tcl              # Re-packages raycaster IP (after RTL edits)
│
├── ray_caster/                     # PROJECT 2: System integration
│   ├── ray_caster.srcs/
│   │   ├── sources_1/bd/design_1/  # Block design (.bd)
│   │   └── constrs_1/              # Pin constraints (PYNQ-Z1 HDMI + buttons)
│   └── raycaster_block_dev/
│       └── raycaster_ip_development/   # PROJECT 1: IP development
│           ├── component.xml           # Packaged IP descriptor
│           ├── raycaster_ip_development.srcs/
│           │   ├── sources_1/new/      # ← All RTL sources + textures (.mem)
│           │   └── sim_1/new/          # Testbenches
│           ├── bar_height_lookup_gen_script/   # 240/dist LUT generator
│           ├── reciprocal_lookup_gen_script/   # |1/x| LUT generator
│           ├── gen_fine_lut/                   # Fine reciprocal LUT
│           └── cos_lookup_gen_script/          # Cosine LUT generator
│
├── ip_repos/
│   └── hdmi_480p_220hz/            # Custom HDMI output IP
│
└── vivado-library-master/          # Digilent Vivado IP library (git submodule)
```

## LUT Generation

Python scripts generate the `.mem` lookup tables used by the hardware:

| Script | Output | Purpose |
|--------|--------|---------|
| `gen_abs_recip_lut.py` | `delta_lut.mem` | \|1/x\| reciprocal for deltaDist |
| `gen_fine_lut.py` | `recip_fine.mem` | Fine-grained reciprocal table |
| `bar_height_lookup_gen_script.py` | `bar_height_lut.mem` | 240/distance → wall half-height |
| `cos_gen.py` | `cos_lut.hex` | Cosine values for dir/plane vectors |

The generated `.mem` files are committed, so you only need to re-run these if you change the fixed-point formats.

## Simulation

Testbenches in `sim_1/new/`:

| Testbench | Tests |
|-----------|-------|
| `ray_caster_tb.v` | Full frame rendering |
| `sprite_caster_tb.sv` | Sprite projection |
| `divider_tb.sv` | Restoring divider |
| `dir_vec_tb.sv` | Direction vector LUT |
| `reciprocal_f_tb.sv` | Reciprocal LUT |

`img_gen_script.py` converts simulation CSV pixel dumps into PNG frames for visual debugging.

## License

MIT — see [LICENSE](LICENSE).
