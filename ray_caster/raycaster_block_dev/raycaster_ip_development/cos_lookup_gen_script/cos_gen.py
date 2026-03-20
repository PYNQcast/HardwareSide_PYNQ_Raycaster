import math

TABLE_SIZE = 4096
FRAC_BITS = 14
SCALE = 2**FRAC_BITS  # 16384

with open("cos_lut.hex", "w") as f:
    for i in range(TABLE_SIZE):
        angle_rad = 2 * math.pi * i / TABLE_SIZE
        val = math.cos(angle_rad)
        fixed = int(round(val * SCALE))
        # Clamp to Q2.14 range
        fixed = max(-32768, min(32767, fixed))
        # Two's complement 16-bit
        if fixed < 0:
            fixed += 65536
        f.write(f"{fixed:04X}\n")

print("Generated cos_lut.hex with 4096 entries (Q2.14, 16-bit)")