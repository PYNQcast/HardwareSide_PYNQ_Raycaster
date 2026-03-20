import numpy as np
from PIL import Image

raw = open("C:/Users/louja/Desktop/Imperial_2/IP/pynq_raycaster/ray_caster/raycaster_block_dev/raycaster_ip_development/raycaster_ip_development.sim/sim_1/behav/xsim/frame.csv").read().split()

def parse_pixel(p):
    try:
        val = int(p, 0)
        r = (val >> 16) & 0xFF
        g = (val >> 8)  & 0xFF
        b =  val        & 0xFF
        return (r, g, b)
    except ValueError:
        return None

pixels = []
for p in raw:
    parsed = parse_pixel(p)
    if parsed is not None:
        pixels.append(parsed)

frame_size = 640 * 480
print(f"Got {len(pixels)} total pixels ({len(pixels) // frame_size} full frames)")

for frame_num in range(25):
    frame_pixels = pixels[frame_num * frame_size : (frame_num + 1) * frame_size]
    if len(frame_pixels) < frame_size:
        print(f"Frame {frame_num + 1}: not enough pixels ({len(frame_pixels)}), skipping")
        continue

    img = np.array(frame_pixels, dtype=np.uint8).reshape(480, 640, 3)
    path = rf"C:/Users/louja/Desktop/Imperial_2/IP/pynq_raycaster/ray_caster/raycaster_block_dev/raycaster_ip_development/frame{frame_num + 1}.png"
    Image.fromarray(img).save(path)
    print(f"Saved frame{frame_num + 1}.png")