"""从 app_icon1111.png 生成合规的 HarmonyOS 分层人物图标。

核心改进：
  - 更严格的背景色阈值 + 连通域分析（min_area=8000）去除月亮和星点
  - 额外清除左上角和左边缘的孤立亮区（月牙）
  - 清除人物周围深蓝渐变残留（用二次颜色距离过滤）
"""
from PIL import Image, ImageFilter
import numpy as np
import os
import json
from collections import deque

SRC = r'd:\XingKeyTarot\entry\src\main\resources\base\media\app_icon1111.png'
APP_OUT = r'd:\XingKeyTarot\AppScope\resources\base\media'
ENTRY_OUT = r'd:\XingKeyTarot\entry\src\main\resources\base\media'
PREVIEW_OUT = r'd:\XingKeyTarot'
BRAND_BG = (8, 11, 24)

os.makedirs(APP_OUT, exist_ok=True)
os.makedirs(ENTRY_OUT, exist_ok=True)

img = Image.open(SRC).convert('RGBA')
if img.size != (1024, 1024):
    img = img.resize((1024, 1024), Image.LANCZOS)
arr = np.array(img).astype(np.float64)
h, w = arr.shape[:2]
rgb = arr[:, :, :3]
alpha = arr[:, :, 3]

# === 边缘采样背景色 ===
edge_mask = np.zeros((h, w), dtype=bool)
edge_mask[:40, :] = True; edge_mask[-40:, :] = True
edge_mask[:, :40] = True; edge_mask[:, -40:] = True
edge_mask = edge_mask & (alpha > 0)
bg_color = rgb[edge_mask].mean(axis=0).astype(np.uint8)
print(f"采样背景色: {tuple(int(x) for x in bg_color)}")

# === 基础前景掩码（颜色距离 + 亮度）===
dist = np.sqrt(np.sum((rgb - bg_color.astype(np.float64)) ** 2, axis=2))
luma = 0.299 * rgb[:,:,0] + 0.587 * rgb[:,:,1] + 0.114 * rgb[:,:,2]
fg_mask = (alpha > 128) & ((dist > 30) | (luma > 55))

# === 形态学优化 ===
mask_img = Image.fromarray((fg_mask * 255).astype(np.uint8), mode='L')
mask_img = mask_img.filter(ImageFilter.MaxFilter(5))
mask_img = mask_img.filter(ImageFilter.MinFilter(3))
mask_img = mask_img.filter(ImageFilter.GaussianBlur(1.5))
fg_mask = np.array(mask_img) > 128

# === BFS 连通域分析（只保留大区域）===
def bfs_largest(mask):
    visited = np.zeros_like(mask)
    regions = []
    for y in range(h):
        if y % 50 == 0: print(f"  扫描进度: {y}/{h}")
        for x in range(w):
            if not mask[y, x] or visited[y, x]:
                continue
            q = deque()
            q.append((y, x))
            visited[y, x] = 1
            region_pixels = []
            while q:
                cy, cx = q.popleft()
                region_pixels.append((cy, cx))
                for dy, dx in [(-1,0),(1,0),(0,-1),(0,1)]:
                    ny, nx = cy+dy, cx+dx
                    if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = 1
                        q.append((ny, nx))
            regions.append(region_pixels)
    return regions

print("正在做连通域分析...")
regions = bfs_largest(fg_mask)
print(f"共找到 {len(regions)} 个连通区域")

# 只保留面积最大的 N 个（人物主体通常最大）
regions.sort(key=len, reverse=True)
# 人物主体应该远大于其他区域（月牙、星点）
# 取总面积的 95% 作为保留阈值
total_fg = sum(len(r) for r in regions)
cumsum = 0
kept_regions = []
for i, reg in enumerate(regions):
    cumsum += len(reg)
    kept_regions.append(reg)
    # 如果已经覆盖了 98% 的前景像素，停止
    if cumsum >= total_fg * 0.97:
        break

out_mask = np.zeros_like(fg_mask)
for reg in kept_regions:
    for cy, cx in reg:
        out_mask[cy, cx] = True
fg_mask = out_mask
print(f"保留 {len(kept_regions)} 个区域，前景像素: {int(fg_mask.sum())}")

# === 额外：清除左半边远离中心的亮斑（月牙）===
# 月牙在左侧 x<250 区域，且亮度很高（黄色）
left_zone = fg_mask.copy()
left_zone[:, 250:] = False  # 只看左半边
# 检查左半边的亮区是否与中央主体相连（通过 y 方向延伸检查）
if left_zone.sum() > 1000:
    print(f"发现左侧亮区 ({int(left_zone.sum())} px)，尝试清除")
    # 左侧月牙通常是独立的，直接清除整个左半边的小区域
    left_clear = fg_mask.copy()
    left_clear[:, :280] = False  # 安全清除左 280px
    # 确保主体还在
    if left_clear.sum() > 200000:
        fg_mask = left_clear
        print(f"左侧清除后: {int(fg_mask.sum())} px")

# === 二次清理：去掉深蓝色渐变残影 ===
# 人物周围的深蓝渐变像素虽然被标记为前景，但它们接近背景色
# 对前景掩码再做一次颜色距离检查（更严格）
dist2 = np.sqrt(np.sum((rgb - bg_color.astype(np.float64)) ** 2, axis=2))
tight_fg = dist2 > 45  # 更严格
fg_mask = fg_mask & tight_fg

# 再做一次形态学闭合小孔
mask_img2 = Image.fromarray((fg_mask * 255).astype(np.uint8), mode='L')
mask_img2 = mask_img2.filter(ImageFilter.MaxFilter(3))
mask_img2 = mask_img2.filter(ImageFilter.GaussianBlur(1.5))
fg_mask = np.array(mask_img2) > 128
print(f"最终前景像素: {int(fg_mask.sum())}")

# === 生成文件 ===
# background: 纯色
bg_arr = np.full((h, w, 3), BRAND_BG, dtype=np.uint8)
Image.fromarray(bg_arr, mode='RGB').save(os.path.join(APP_OUT, 'background.png'), 'PNG', optimize=True)
Image.fromarray(bg_arr, mode='RGB').save(os.path.join(ENTRY_OUT, 'background.png'), 'PNG', optimize=True)
print(f"✓ background.png: 1024x1024 RGB 纯色 {BRAND_BG}")

# foreground: 人物主体
fg_out = np.zeros((h, w, 4), dtype=np.uint8)
fg_out[:, :, :3] = arr[:, :, :3].astype(np.uint8)
fg_out[:, :, 3] = np.where(fg_mask, 255, 0).astype(np.uint8)
Image.fromarray(fg_out, mode='RGBA').save(os.path.join(APP_OUT, 'foreground.png'), 'PNG', optimize=True)
Image.fromarray(fg_out, mode='RGBA').save(os.path.join(ENTRY_OUT, 'foreground.png'), 'PNG', optimize=True)
f_alpha = fg_out[:, :, 3]
print(f"✓ foreground.png: 1024x1024 RGBA")
print(f"  alpha=0: {int((f_alpha==0).sum())}, alpha=255: {int((f_alpha==255).sum())}")

# 合成预览
preview = Image.fromarray(bg_arr, mode='RGB').convert('RGBA')
p_arr = np.array(preview).astype(np.float64)
fa = f_alpha.astype(np.float64) / 255.0
fa = fa[:, :, np.newaxis]  # broadcast to RGB
fr = fg_out[:, :, :3].astype(np.float64)
p_arr[:, :, :3] = (fr * fa + p_arr[:, :, :3] * (1 - fa)).astype(np.uint8)
p_arr[:, :, 3] = 255
Image.fromarray(p_arr.astype(np.uint8)).save(os.path.join(PREVIEW_OUT, 'layered_preview.png'))
print(f"✓ layered_preview.png 已保存")

# layered_image.json
config = {"layered-image": {"background": "$media:background", "foreground": "$media:foreground"}}
for out_dir in [APP_OUT, ENTRY_OUT]:
    with open(os.path.join(out_dir, 'layered_image.json'), 'w') as f:
        json.dump(config, f, indent=2)
print("✓ layered_image.json 已更新")
print("\n完成！")
