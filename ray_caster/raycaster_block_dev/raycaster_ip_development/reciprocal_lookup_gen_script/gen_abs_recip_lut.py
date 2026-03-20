#!/usr/bin/env python3
"""
Generate |1/dirX| LUT for DDA raycaster.

Input:  10-bit unsigned Q1.9  (mag[14:5] from a Q2.14 direction vector magnitude)
Output: 16-bit unsigned Q6.10 (deltaDistX = 1/input)

Entry 0: saturated to MAX_OUTPUT (input would be zero)

Verilog usage:
    wire [14:0] mag        = dirX[15] ? (-dirX[14:0]) : dirX[14:0];
    wire [9:0]  idx        = mag[14:5];
    wire [15:0] deltaDistX = delta_lut[idx];
"""

OUTPUT_FRAC_BITS = 12
OUTPUT_SCALE     = 1 << OUTPUT_FRAC_BITS   # 1024
MAX_OUTPUT       = (1 << 18) - 1           # 65535

LUT_SIZE = 1024
INPUT_FRAC_BITS = 10
INPUT_SCALE = 1 << INPUT_FRAC_BITS
lut = []
for i in range(LUT_SIZE):
    if i == 0:
        lut.append(MAX_OUTPUT)
    else:
        val = int(round((1.0 / (i / INPUT_SCALE)) * OUTPUT_SCALE))
        lut.append(min(val, MAX_OUTPUT))

# ── Output formats ────────────────────────────────────────────────────────────
def write_c_header(lut, path="delta_lut.h"):
    with open(path, "w") as f:
        f.write("/* |1/dirX| LUT  —  Q1.9 input (10-bit), Q6.10 output (16-bit) */\n\n")
        f.write(f"#define DELTA_LUT_SIZE {LUT_SIZE}\n\n")
        f.write("static const uint16_t delta_lut[DELTA_LUT_SIZE] = {\n")
        for j in range(0, LUT_SIZE, 8):
            row = lut[j:j+8]
            f.write("    " + ", ".join(f"{v:5d}" for v in row) + ",\n")
        f.write("};\n")
    print(f"Written: {path}")

def write_mem_hex(lut, path="delta_lut.mem"):
    with open(path, "w") as f:
        for v in lut:
            f.write(f"{v:04X}\n")
    print(f"Written: {path}")

def write_coe(lut, path="delta_lut.coe"):
    with open(path, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, v in enumerate(lut):
            sep = "," if i < len(lut) - 1 else ";"
            f.write(f"{v:04X}{sep}\n")
    print(f"Written: {path}")

write_c_header(lut, "delta_lut.h")
write_mem_hex(lut,  "delta_lut.mem")
write_coe(lut,      "delta_lut.coe")

# ── Sanity checks ─────────────────────────────────────────────────────────────
print(f"\n{'label':>20}  {'idx':>5}  {'lut_val':>7}  {'lut_real':>9}  {'expected':>9}  {'error':>8}")
print("-" * 70)
tests = [
    (1.0,   "horizontal ray"),
    (0.707, "45 deg diagonal"),
    (0.5,   "dirX=0.5"),
    (0.1,   "dirX=0.1"),
    (0.0,   "zero (clamped)"),
]
for dir_real, label in tests:
    idx     = min(int(dir_real * INPUT_SCALE), LUT_SIZE - 1)
    lut_val = lut[idx]
    expected = (1.0 / dir_real) * OUTPUT_SCALE if dir_real > 0 else MAX_OUTPUT
    error   = abs(lut_val - expected) / expected * 100 if dir_real > 0 else 0
    print(f"  {label:20s}  {idx:5d}  {lut_val:7d}  {lut_val/OUTPUT_SCALE:9.4f}  {expected/OUTPUT_SCALE:9.4f}  {error:7.3f}%")
