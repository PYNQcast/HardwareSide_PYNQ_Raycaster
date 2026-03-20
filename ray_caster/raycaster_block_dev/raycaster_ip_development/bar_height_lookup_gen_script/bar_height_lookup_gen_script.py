#!/usr/bin/env python3
"""
Generate 240/perpDist LUT for DDA raycaster wall strip half-heights.

Input:  12-bit unsigned index (perp_dist[15:4] from a Q6.10 distance)
Output: 10-bit unsigned integer (half-strip pixel height, clamped to 1023)

Entry 0: saturated to MAX_OUTPUT (distance would be zero)

Verilog usage:
    wire [15:0] perp_dist  = ...;              // Q6.10 distance
    wire [11:0] idx        = perp_dist[15:4];  // top 12 bits as LUT index
    wire [9:0]  half_strip = bar_height_lut[idx];
    wire [9:0]  draw_start = (half_strip > 10'd240) ? 10'd0   : 10'd240 - half_strip;
    wire [9:0]  draw_end   = (half_strip > 10'd240) ? 10'd479 : 10'd240 + half_strip;
"""

INPUT_SCALE = 64    # step = 2^4 / 2^10 = 1/64 real units
MAX_OUTPUT  = 1023  # 10-bit max
LUT_SIZE    = 4096  # 2^12

lut = []
for i in range(LUT_SIZE):
    if i == 0:
        lut.append(MAX_OUTPUT)
    else:
        real_dist = i / INPUT_SCALE
        val = int(round(240.0 / real_dist))
        lut.append(min(val, MAX_OUTPUT))

assert all(0 <= v <= MAX_OUTPUT for v in lut), "LUT value out of 10-bit range"
assert max(lut) == MAX_OUTPUT, f"Unexpected max: {max(lut)}"

# ── Output formats ────────────────────────────────────────────────────────────
def write_c_header(lut, path="bar_height_lut.h"):
    with open(path, "w") as f:
        f.write("/* 240/perpDist LUT  —  Q6.10 input (12-bit index), 10-bit integer output */\n\n")
        f.write(f"#define BAR_HEIGHT_LUT_SIZE {LUT_SIZE}\n\n")
        f.write("static const uint16_t bar_height_lut[BAR_HEIGHT_LUT_SIZE] = {\n")
        for j in range(0, LUT_SIZE, 8):
            row = lut[j:j+8]
            f.write("    " + ", ".join(f"{v:5d}" for v in row) + ",\n")
        f.write("};\n")
    print(f"Written: {path}")

def write_mem_hex(lut, path="bar_height_lut.mem"):
    with open(path, "w") as f:
        for v in lut:
            f.write(f"{v:04X}\n")
    print(f"Written: {path}")

def write_coe(lut, path="bar_height_lut.coe"):
    with open(path, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, v in enumerate(lut):
            sep = "," if i < len(lut) - 1 else ";"
            f.write(f"{v:04X}{sep}\n")
    print(f"Written: {path}")

write_c_header(lut, "bar_height_lut.h")
write_mem_hex(lut,  "bar_height_lut.mem")
write_coe(lut,      "bar_height_lut.coe")

# ── Sanity checks ─────────────────────────────────────────────────────────────
first_unclamped = next(i for i in range(1, LUT_SIZE) if lut[i] < MAX_OUTPUT)
print(f"\nFirst unclamped index: {first_unclamped}  (real_dist = {first_unclamped/INPUT_SCALE:.4f})")

print(f"\n{'label':>25}  {'idx':>5}  {'lut_val':>7}  {'expected':>9}  {'error':>8}")
print("-" * 70)
tests = [
    (0.016, "min dist (idx 1)"),
    (0.25,  "close (0.25)"),
    (0.5,   "close (0.5)"),
    (1.0,   "unit distance (1.0)"),
    (2.0,   "mid distance (2.0)"),
    (5.0,   "far distance (5.0)"),
    (10.0,  "very far (10.0)"),
    (63.0,  "max Q6.10 dist (63.0)"),
    (0.0,   "zero (clamped)"),
]
for dist_real, label in tests:
    idx      = min(int(dist_real * INPUT_SCALE), LUT_SIZE - 1)
    lut_val  = lut[idx]
    expected = min(240.0 / dist_real, MAX_OUTPUT) if dist_real > 0 else MAX_OUTPUT
    error    = abs(lut_val - expected) / expected * 100 if dist_real > 0 else 0
    print(f"  {label:25s}  {idx:5d}  {lut_val:7d}  {expected:9.3f}  {error:7.3f}%")