#!/usr/bin/env python3
"""星钥塔罗 HarmonyOS 分层图标资源生成脚本"""

from PIL import Image, ImageDraw, ImageFilter
import math
import random
import os

OUT_DIR = r"d:\XingKeyTarot\AppScope\resources\base\media"
SIZE = 1024

# ============ BACKGROUND: 深蓝星空渐变背景 ============

def create_background():
    """创建 1024x1024 完全不透明深蓝星空渐变背景"""
    img = Image.new("RGB", (SIZE, SIZE))
    draw = ImageDraw.Draw(img)

    # 深蓝星空渐变 —— 从深靛蓝到稍亮的深蓝
    for y in range(SIZE):
        t = y / SIZE  # 0(top) -> 1(bottom)
        # 基础深蓝渐变
        r = int(4 + 8 * t)           # 4 → 12
        g = int(8 + 14 * t)           # 8 → 22
        b = int(28 + 24 * t)          # 28 → 52

        # 中心微光效果——从中心向外衰减
        dy = (y - SIZE / 2) / (SIZE / 2)
        center_glow = 1.0 - dy * dy * 0.25
        r = min(255, int(r * center_glow + 5))
        g = min(255, int(g * center_glow + 3))
        b = min(255, int(b * center_glow + 15))

        for x in range(SIZE):
            dx = (x - SIZE / 2) / (SIZE / 2)
            dist_sq = dx * dx + dy * dy
            glow = (1.0 - dist_sq * 0.3)
            # 微妙的径向渐变——中心更亮
            pixel_r = min(255, max(0, int(r * glow + 8 * (1.0 - dist_sq))))
            pixel_g = min(255, max(0, int(g * glow + 6 * (1.0 - dist_sq))))
            pixel_b = min(255, max(0, int(b * glow + 20 * (1.0 - dist_sq))))
            draw.point((x, y), (pixel_r, pixel_g, pixel_b))

    # 添加星点
    random.seed(42)  # 可复现
    star_count = 180
    for _ in range(star_count):
        x = random.randint(80, SIZE - 80)
        y = random.randint(80, SIZE - 80)
        # 避免中心太亮（留给前景）
        dist_from_center = math.sqrt((x - SIZE / 2) ** 2 + (y - SIZE / 2) ** 2)
        if dist_from_center < 120:
            continue
        brightness = random.randint(160, 240)
        size = random.randint(1, 4)
        star_color = (brightness, brightness, int(brightness * 0.9))
        if size == 1:
            draw.point((x, y), star_color)
        elif size == 2:
            draw.point((x, y), star_color)
            draw.point((x + 1, y), star_color)
        else:
            # 小十字星
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    if abs(dx) + abs(dy) <= 2 and random.random() > 0.3:
                        px = x + dx
                        py = y + dy
                        if 0 <= px < SIZE and 0 <= py < SIZE:
                            c = min(255, int(brightness * (1.0 - 0.3 * (abs(dx) + abs(dy)))))
                            draw.point((px, py), (c, c, c))

    # 添加微弱的月光（中心偏上区域）
    for angle in range(0, 360, 2):
        rad = math.radians(angle)
        radius = 350
        cx = SIZE // 2
        cy = SIZE // 2 - 40
        for r_offset in range(-5, 6):
            r = radius + r_offset
            x = int(cx + r * math.cos(rad))
            y = int(cy + r * math.sin(rad))
            if 0 <= x < SIZE and 0 <= y < SIZE:
                current = img.getpixel((x, y))
                brightness = int(30 * (1.0 - abs(r_offset) / 6.0) * (1.0 - abs(angle - 180) / 180 * 0.3))
                new_r = min(255, current[0] + brightness)
                new_g = min(255, current[1] + brightness)
                new_b = min(255, current[2] + int(brightness * 1.2))
                draw.point((x, y), (new_r, new_g, new_b))

    return img


# ============ FOREGROUND: 金色星钥+月牙（透明底） ============

def draw_star(draw, cx, cy, outer_r, inner_r, points, color, angle_offset=0):
    """画星形"""
    vertices = []
    for i in range(points * 2):
        angle = math.radians(-90 + angle_offset + i * 360 / (points * 2))
        r = outer_r if i % 2 == 0 else inner_r
        x = cx + r * math.cos(angle)
        y = cy + r * math.sin(angle)
        vertices.append((x, y))
    draw.polygon(vertices, fill=color)

def create_foreground():
    """创建 1024x1024 金色星钥+月牙前景图（透明底）"""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx = SIZE // 2
    cy = SIZE // 2 - 20

    # 金色调色板
    gold_bright = (244, 208, 63)      # 明亮金
    gold_medium = (212, 175, 55)      # 中金
    gold_dark = (180, 140, 30)        # 暗金
    gold_light = (255, 230, 120)      # 浅金/高光
    white_gold = (255, 245, 210)      # 白金

    # ----- 月牙（在星钥后面） -----
    moon_cx = cx
    moon_cy = cy - 30
    moon_outer_r = 130
    moon_inner_r = 90
    moon_angle_start = 20
    moon_angle_range = 320

    # 用多个圆叠加绘制月牙
    for angle in range(moon_angle_start, moon_angle_start + moon_angle_range, 2):
        rad = math.radians(angle)
        # 外弧
        x1 = int(moon_cx + moon_outer_r * math.cos(rad))
        y1 = int(moon_cy + moon_outer_r * math.sin(rad))
        # 过渡区
        for i in range(6):
            t = i / 5.0
            r_interp = moon_outer_r - (moon_outer_r - moon_inner_r) * t
            x = int(moon_cx + r_interp * math.cos(rad))
            y = int(moon_cy + r_interp * math.sin(rad))
            alpha = int(255 * (1.0 - t * 0.85))
            color = (
                int(212 + 32 * t),
                int(175 + 40 * t),
                int(55 + 65 * t),
                alpha
            )
            if 60 < x < SIZE - 60 and 60 < y < SIZE - 60:
                draw.point((x, y), color)

    # 月牙完整覆盖
    moon_mask = Image.new("L", (SIZE, SIZE), 0)
    moon_draw = ImageDraw.Draw(moon_mask)
    moon_bbox = [
        (moon_cx - moon_outer_r - 5, moon_cy - moon_outer_r - 5),
        (moon_cx + moon_outer_r + 5, moon_cy + moon_outer_r + 5)
    ]
    moon_draw.ellipse(moon_bbox, fill=255)
    inner_bbox = [
        (moon_cx - moon_inner_r + 3, moon_cy - moon_inner_r - 10),
        (moon_cx + moon_inner_r - 3, moon_cy + moon_inner_r + 10)
    ]
    moon_draw.ellipse(inner_bbox, fill=0)

    # 应用月牙
    for y in range(max(0, moon_cy - moon_outer_r - 5), min(SIZE, moon_cy + moon_outer_r + 5)):
        for x in range(max(0, moon_cx - moon_outer_r - 5), min(SIZE, moon_cx + moon_outer_r + 5)):
            mask_val = moon_mask.getpixel((x, y))
            if mask_val > 10:
                alpha = mask_val
                color = (212, 175, 55, alpha)
                draw.point((x, y), color)

    # 月牙边缘高光
    for angle in range(moon_angle_start, moon_angle_start + moon_angle_range, 3):
        rad = math.radians(angle)
        for i in range(3):
            r = moon_outer_r - i * 2
            x = int(moon_cx + r * math.cos(rad))
            y = int(moon_cy + r * math.sin(rad))
            if 60 < x < SIZE - 60 and 60 < y < SIZE - 60:
                alpha = int(180 - i * 50)
                draw.point((x, y), (244, 208, 63, alpha))

    # ----- 星钥主体（星形钥匙） -----
    # 钥匙杆
    key_x = cx
    key_top = cy - 180
    key_bottom = cy + 160
    key_width = 14

    # 钥匙长杆
    draw.rectangle(
        [key_x - key_width // 2, key_top, key_x + key_width // 2, key_bottom],
        fill=gold_medium + (255,)
    )
    # 杆子高光
    draw.rectangle(
        [key_x - 3, key_top, key_x + 3, key_bottom],
        fill=gold_bright + (200,)
    )

    # 钥匙头（星形）
    star_outer_r = 95
    star_inner_r = 42
    star_cy = key_top + 30
    draw_star(draw, key_x, star_cy, star_outer_r, star_inner_r, 5, gold_medium + (255,))

    # 星形内部高光
    inner_outer_r = 80
    inner_inner_r = 35
    draw_star(draw, key_x, star_cy, inner_outer_r, inner_inner_r, 5, gold_bright + (220,))

    # 星形中心光芒
    center_glow_r = 18
    for r in range(center_glow_r, 0, -1):
        alpha = int(200 * (r / center_glow_r))
        draw.ellipse(
            [key_x - r, star_cy - r, key_x + r, star_cy + r],
            fill=white_gold + (alpha,)
        )

    # 钥匙柄（底部装饰）
    handle_top = key_bottom - 30
    handle_r = 35
    draw.ellipse(
        [key_x - handle_r, handle_top - handle_r, key_x + handle_r, handle_top + handle_r],
        fill=gold_medium + (255,)
    )
    inner_handle_r = handle_r - 8
    draw.ellipse(
        [key_x - inner_handle_r, handle_top - inner_handle_r, key_x + inner_handle_r, handle_top + inner_handle_r],
        fill=gold_dark + (255,)
    )
    # 环心亮点
    draw.ellipse(
        [key_x - 6, handle_top - 6, key_x + 6, handle_top + 6],
        fill=white_gold + (160,)
    )

    # ----- 散布小星光 -----
    random.seed(99)
    sparkle_positions = [
        (cx - 160, cy - 100),
        (cx + 180, cy - 80),
        (cx - 120, cy + 140),
        (cx + 140, cy + 120),
        (cx + 80, cy - 200),
        (cx - 90, cy + 200),
        (cx + 200, cy + 10),
        (cx - 200, cy + 30),
    ]
    for spx, spy in sparkle_positions:
        if not (60 < spx < SIZE - 60 and 60 < spy < SIZE - 60):
            continue
        size = random.randint(6, 14)
        alpha = random.randint(80, 180)
        for i in range(5):
            angle = math.radians(i * 72)
            for t in range(size):
                x = int(spx + t * math.cos(angle))
                y = int(spy + t * math.sin(angle))
                if 60 < x < SIZE - 60 and 60 < y < SIZE - 60:
                    a = max(0, int(alpha * (1.0 - t / size)))
                    draw.point((x, y), white_gold + (a,))

    # 中心星光点
    for spx, spy in [(cx, cy - 240), (cx, cy + 220), (cx - 220, cy), (cx + 220, cy)]:
        for r in range(4, 0, -1):
            a = int(150 * (r / 4))
            draw.ellipse([spx - r, spy - r, spx + r, spy + r], fill=white_gold + (a,))

    return img


# ============ 验证函数 ============

def verify_image(path, name, check_no_transparency=False, check_no_rounded=False):
    """验证图片合规性"""
    print(f"\n  === 验证 {name} ===")
    img = Image.open(path)
    w, h = img.size
    print(f"  尺寸: {w} × {h}")
    assert w == 1024 and h == 1024, f"  [FAIL] Size mismatch! Expected 1024x1024, got {w}x{h}"

    if img.mode == "RGBA":
        import numpy as np
        a = np.array(img)
        corners = [int(a[0, 0, 3]), int(a[0, 1023, 3]), int(a[1023, 0, 3]), int(a[1023, 1023, 3])]
        all_opaque = bool((a[:, :, 3] == 255).all())
        has_any_transparent = int((a[:, :, 3] != 255).sum())

        print(f"  模式: RGBA")
        print(f"  四角 alpha: {corners}")
        print(f"  全不透明: {all_opaque}")
        has_transparent = has_any_transparent > 0
        print(f"  透明像素数: {has_any_transparent}")

        if check_no_transparency:
            if not all_opaque:
                print(f"  [FAIL] Found {has_any_transparent} transparent/semi-transparent pixels!")
                return False
            else:
                print(f"  [PASS] Fully opaque")
        else:
            print(f"  [PASS] Foreground transparency allowed")
    else:
        print(f"  模式: {img.mode}")
        print(f"  [PASS] No alpha channel, fully opaque")

    if check_no_rounded:
        if img.mode == "RGBA":
            import numpy as np
            a = np.array(img)
            # 检查四角 50x50 区域
            for cx, cy in [(0, 0), (0, 1023), (1023, 0), (1023, 1023)]:
                x_start = max(0, cx - 25)
                x_end = min(1024, cx + 26)
                y_start = max(0, cy - 25)
                y_end = min(1024, cy + 26)
                corner_area = a[y_start:y_end, x_start:x_end, 3]
                transparent_in_corner = int((corner_area != 255).sum())
                if transparent_in_corner > 0 and check_no_transparency:
                    print(f"  [FAIL] Corner ({cx},{cy}) has {transparent_in_corner} non-opaque pixels")
                    return False
        print(f"  [PASS] No rounded corners detected")

    return True


# ============ 主流程 ============

if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)

    print("=" * 60)
    print("星钥塔罗 HarmonyOS 分层图标资源生成")
    print("=" * 60)

    # 生成 background
    print("\n[1/4] 生成 background.png...")
    bg = create_background()
    bg_path = os.path.join(OUT_DIR, "background.png")
    bg.save(bg_path, "PNG")
    bg.save(bg_path, "PNG")
    print(f"  [OK] Saved: {bg_path}")

    # 生成 foreground
    print("\n[2/4] 生成 foreground.png...")
    fg = create_foreground()
    fg_path = os.path.join(OUT_DIR, "foreground.png")
    fg.save(fg_path, "PNG")
    print(f"  [OK] Saved: {fg_path}")

    # 验证
    print("\n[3/4] 验证图片...")
    bg_ok = verify_image(bg_path, "background.png", check_no_transparency=True)
    fg_ok = verify_image(fg_path, "foreground.png", check_no_transparency=False)

    # 创建 layered_image.json
    print("\n[4/4] 创建 layered_image.json...")
    layered_config = {
        "layered-image": {
            "background": "$media:background",
            "foreground": "$media:foreground"
        }
    }
    layered_path = os.path.join(OUT_DIR, "layered_image.json")
    import json
    with open(layered_path, "w", encoding="utf-8") as f:
        json.dump(layered_config, f, indent=2, ensure_ascii=False)
    print(f"  [OK] Saved: {layered_path}")

    print("\n" + "=" * 60)
    if bg_ok and fg_ok:
        print("[SUCCESS] All resources generated and verified!")
    else:
        print("[WARNING] Some verification items failed!")
    print(f"  Background: {'PASS' if bg_ok else 'FAIL'}")
    print(f"  Foreground: {'PASS' if fg_ok else 'FAIL'}")
    print("=" * 60)
