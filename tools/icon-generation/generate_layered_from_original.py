from PIL import Image
import numpy as np
import os
import json

# Paths
SRC = 'd:/XingKeyTarot/backup/icon_old/AppScope/app_icon.png'
APP_OUT = 'd:/XingKeyTarot/AppScope/resources/base/media'
ENTRY_OUT = 'd:/XingKeyTarot/entry/src/main/resources/base/media'
PREVIEW_OUT = 'd:/XingKeyTarot'

os.makedirs(APP_OUT, exist_ok=True)
os.makedirs(ENTRY_OUT, exist_ok=True)

# Load original icon
img = Image.open(SRC)
arr = np.array(img)
assert arr.shape == (1024, 1024, 4), f"Expected 1024x1024 RGBA, got {arr.shape}"

# Extract channels
rgb = arr[:, :, :3].astype(np.float64)
alpha = arr[:, :, 3]

# Background color: sampled from edge non-transparent pixels
h, w = rgb.shape[:2]
edge_mask = np.zeros((h, w), dtype=bool)
edge_mask[:30, :] = True
edge_mask[-30:, :] = True
edge_mask[:, :30] = True
edge_mask[:, -30:] = True
edge_mask = edge_mask & (alpha > 0)
edge_rgb = rgb[edge_mask]
bg_color = edge_rgb.mean(axis=0).astype(np.uint8)
print(f"Background color sampled from edges: {bg_color}")

# ============================================
# 1. background.png (1024x1024, fully opaque, no alpha)
# ============================================
bg_arr = rgb.astype(np.uint8).copy()
# Fill transparent corners with bg_color
bg_arr[alpha == 0] = bg_color
# Ensure no alpha
bg_img = Image.fromarray(bg_arr, mode='RGB')
bg_img.save(os.path.join(APP_OUT, 'background.png'), 'PNG')
bg_img.save(os.path.join(ENTRY_OUT, 'background.png'), 'PNG')
print(f"Saved background.png ({bg_img.size})")

# ============================================
# 2. foreground.png (1024x1024, transparent bg, keep foreground subject)
# ============================================
# Distance from background color
dist = np.sqrt(np.sum((rgb - bg_color.astype(np.float64)) ** 2, axis=2))

# Threshold: distance > 15 for foreground, with some bright pixels always included
# Using a slightly adaptive threshold to preserve hair
THRESHOLD = 15

fg_mask = (alpha > 0) & (dist > THRESHOLD)
# Also include pixels with high brightness to catch stars/moon/hair highlights
luma = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
fg_mask = fg_mask | (luma > 45)

# Create foreground RGBA
fg_arr = np.zeros((1024, 1024, 4), dtype=np.uint8)
fg_arr[:, :, :3] = rgb.astype(np.uint8)
fg_arr[:, :, 3] = np.where(fg_mask, 255, 0).astype(np.uint8)

fg_img = Image.fromarray(fg_arr, mode='RGBA')
fg_img.save(os.path.join(APP_OUT, 'foreground.png'), 'PNG')
fg_img.save(os.path.join(ENTRY_OUT, 'foreground.png'), 'PNG')
print(f"Saved foreground.png ({fg_img.size}), foreground pixels: {np.sum(fg_mask)}")

# ============================================
# 3. layered_preview.png (composite)
# ============================================
preview = bg_img.copy().convert('RGBA')
preview_arr = np.array(preview)
# Overlay foreground
fg_rgb = fg_arr[:, :, :3]
fg_alpha = fg_arr[:, :, 3:4].astype(np.float64) / 255.0
preview_arr[:, :, :3] = (
    fg_rgb * fg_alpha + preview_arr[:, :, :3] * (1 - fg_alpha)
).astype(np.uint8)
preview_img = Image.fromarray(preview_arr, mode='RGBA')
preview_img.save(os.path.join(PREVIEW_OUT, 'layered_preview.png'), 'PNG')
print(f"Saved layered_preview.png ({preview_img.size})")

# ============================================
# 4. layered_image.json
# ============================================
config = {
    "layered": {
        "background": "$media:background",
        "foreground": "$media:foreground"
    }
}
json_path = os.path.join(APP_OUT, 'layered_image.json')
with open(json_path, 'w') as f:
    json.dump(config, f, indent=2)

json_path2 = os.path.join(ENTRY_OUT, 'layered_image.json')
with open(json_path2, 'w') as f:
    json.dump(config, f, indent=2)
print(f"Saved layered_image.json")

# ============================================
# Verification
# ============================================
for name, path in [
    ('background', os.path.join(APP_OUT, 'background.png')),
    ('foreground', os.path.join(APP_OUT, 'foreground.png')),
    ('preview', os.path.join(PREVIEW_OUT, 'layered_preview.png')),
]:
    img_check = Image.open(path)
    mode = 'RGB' if name == 'background' else 'RGBA'
    print(f"{name}: {img_check.size} {img_check.mode} -> expecting {mode}")

# Check transparency counts
fg_check = np.array(Image.open(os.path.join(APP_OUT, 'foreground.png')))
print(f"Foreground alpha=0: {np.sum(fg_check[:,:,3]==0)}")
print(f"Foreground alpha=255: {np.sum(fg_check[:,:,3]==255)}")
print(f"Foreground semi-transparent: {np.sum((fg_check[:,:,3]>0)&(fg_check[:,:,3]<255))}")

# Check background has no alpha
bg_check = np.array(Image.open(os.path.join(APP_OUT, 'background.png')))
print(f"Background shape: {bg_check.shape}")
print("Done!")
