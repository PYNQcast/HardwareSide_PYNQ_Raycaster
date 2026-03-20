#!/usr/bin/env python3
"""
Generate fine reciprocal LUT for near-parallel rays.

Input:  mag[8:0] — bottom 9 bits of |rayDir| in Q2.14 (values 0..511)
Output: 22-bit unsigned — stores round(4194304 / mag), i.e. (16384/mag) << 8

Usage in hardware:
    distance_q10 = (cell_offset * recip_fine[mag[8:0]]) >> 8
    
    This gives perpWallDist in Q6.10 format, same as normal DDA distance output.
    Saturate to 16'hFFFF if result exceeds 16 bits.

Only used when deltadist == 18'h3FFFF (saturated), meaning the normal
reciprocal LUT couldn't represent 1/raydir with enough precision.
"""

FINE_LUT_SIZE = 512
K = 8
MULTIPLIER = 16384 * (1 << K)  # 4194304
MAX_OUTPUT = (1 << 22) - 1     # 4194303

fine_lut = []
for i in range(FINE_LUT_SIZE):
    if i == 0:
        fine_lut.append(MAX_OUTPUT)
    else:
        val = int(round(MULTIPLIER / i))
        fine_lut.append(min(val, MAX_OUTPUT))

# Output formats
def write_mem_hex(lut, path="recip_fine.mem"):
    with open(path, "w") as f:
        for v in lut:
            f.write(f"{v:06X}\n")
    print(f"Written: {path}")

def write_coe(lut, path="recip_fine.coe"):
    with open(path, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        for i, v in enumerate(lut):
            sep = "," if i < len(lut) - 1 else ";"
            f.write(f"{v:06X}{sep}\n")
    print(f"Written: {path}")

write_mem_hex(fine_lut)
write_coe(fine_lut)

# Sanity checks
print(f"\n{'idx':>5} {'lut_val':>10} {'1/raydir':>12} {'err%':>8}")
print("-" * 40)
tests = [0, 1, 2, 5, 10, 20, 34, 68, 101, 135, 169, 270, 338, 511]
for i in tests:
    v = fine_lut[i]
    if i == 0:
        print(f"{i:5d} {v:10d}       {'SAT':>5}     {'N/A':>5}")
    else:
        real_recip = 16384.0 / i
        lut_recip = v / (1 << K)
        err = abs(lut_recip - real_recip) / real_recip * 100
        print(f"{i:5d} {v:10d} {lut_recip:12.4f} {err:8.4f}%")
