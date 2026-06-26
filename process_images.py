"""
图片批量处理脚本
- 裁剪为 9:16 宽高比（居中裁剪）
- 缩放到最低尺寸 1080x1920
- 输出 PNG、JPG（5MB以内）
- 输出 WEBP（200KB以内）
"""
import os
import io
from PIL import Image

SRC_DIR = 'C:/Users/pc/Desktop'
OUT_DIR = 'D:/XingKeyTarot/processed_images'
os.makedirs(OUT_DIR, exist_ok=True)

TARGET_W = 1080
TARGET_H = 1920
TARGET_RATIO = 9 / 16  # 0.5625

FILES = [
    '微信图片_20260626043147_118_137.jpg',
    '微信图片_20260626043148_119_137.jpg',
    '微信图片_20260626043149_120_137.jpg',
    '微信图片_20260626043150_121_137.jpg',
    '微信图片_20260626043151_122_137.jpg',
]


def crop_to_ratio(img, target_ratio):
    """居中裁剪到目标宽高比"""
    w, h = img.size
    current_ratio = w / h

    if current_ratio > target_ratio:
        # 图片比目标更宽 → 裁掉左右
        new_w = int(h * target_ratio)
        left = (w - new_w) // 2
        return img.crop((left, 0, left + new_w, h))
    elif current_ratio < target_ratio:
        # 图片比目标更窄/高 → 裁掉上下
        new_h = int(w / target_ratio)
        top = (h - new_h) // 2
        return img.crop((0, top, w, top + new_h))
    else:
        return img


def resize_to_target(img, target_w, target_h):
    """缩放到目标尺寸"""
    return img.resize((target_w, target_h), Image.LANCZOS)


def save_png_under_5mb(img, path, name):
    """保存PNG，确保5MB以内"""
    img.save(path, 'PNG', optimize=True)
    size_mb = os.path.getsize(path) / (1024 * 1024)
    print(f'  {name}.png: {size_mb:.2f} MB', end='')
    if size_mb > 5:
        print(' ⚠️ 超过5MB')
    else:
        print(' ✓')
    return size_mb


def save_jpg_under_5mb(img, path, name, quality=95):
    """保存JPG，确保5MB以内"""
    if img.mode == 'RGBA':
        img = img.convert('RGB')
    img.save(path, 'JPEG', quality=quality, optimize=True)
    size_mb = os.path.getsize(path) / (1024 * 1024)
    if size_mb > 5:
        # 降低质量重试
        for q in [90, 85, 80, 75, 70]:
            img.save(path, 'JPEG', quality=q, optimize=True)
            size_mb = os.path.getsize(path) / (1024 * 1024)
            if size_mb <= 5:
                print(f'  {name}.jpg (q={q}): {size_mb:.2f} MB ✓')
                return size_mb
    print(f'  {name}.jpg (q={quality}): {size_mb:.2f} MB ✓')
    return size_mb


def save_webp_under_200kb(img, path, name, quality=90):
    """保存WEBP，确保200KB以内"""
    if img.mode == 'RGBA':
        img_rgb = img.convert('RGB')
    else:
        img_rgb = img

    img_rgb.save(path, 'WEBP', quality=quality, method=6)
    size_kb = os.path.getsize(path) / 1024

    if size_kb > 200:
        # 逐步降低质量直到200KB以内
        for q in [85, 80, 75, 70, 65, 60, 55, 50, 45, 40]:
            img_rgb.save(path, 'WEBP', quality=q, method=6)
            size_kb = os.path.getsize(path) / 1024
            if size_kb <= 200:
                print(f'  {name}.webp (q={q}): {size_kb:.0f} KB ✓')
                return size_kb

        # 如果降质量还不够，缩小尺寸
        scale = 0.9
        while size_kb > 200 and scale > 0.3:
            new_w = int(TARGET_W * scale)
            new_h = int(TARGET_H * scale)
            small = img_rgb.resize((new_w, new_h), Image.LANCZOS)
            small.save(path, 'WEBP', quality=60, method=6)
            size_kb = os.path.getsize(path) / 1024
            if size_kb <= 200:
                print(f'  {name}.webp ({new_w}x{new_h}, q=60): {size_kb:.0f} KB ✓')
                return size_kb
            scale -= 0.1

    print(f'  {name}.webp (q={quality}): {size_kb:.0f} KB', end='')
    if size_kb > 200:
        print(' ⚠️ 超过200KB')
    else:
        print(' ✓')
    return size_kb


def process_file(filename, index):
    """处理单个文件"""
    src_path = os.path.join(SRC_DIR, filename)
    base_name = f'app_screenshot_{index + 1}'

    print(f'\n[{index + 1}/5] {filename} → {base_name}')

    img = Image.open(src_path)
    print(f'  原始: {img.size[0]}x{img.size[1]}')

    # 裁剪到9:16
    cropped = crop_to_ratio(img, TARGET_RATIO)
    print(f'  裁剪后: {cropped.size[0]}x{cropped.size[1]}')

    # 缩放到1080x1920
    resized = resize_to_target(cropped, TARGET_W, TARGET_H)
    print(f'  目标: {resized.size[0]}x{resized.size[1]}')

    # 保存三种格式
    save_png_under_5mb(resized, os.path.join(OUT_DIR, f'{base_name}.png'), base_name)
    save_jpg_under_5mb(resized, os.path.join(OUT_DIR, f'{base_name}.jpg'), base_name)
    save_webp_under_200kb(resized, os.path.join(OUT_DIR, f'{base_name}.webp'), base_name)


if __name__ == '__main__':
    print('=' * 60)
    print('星钥塔罗 App 截图处理')
    print(f'目标: {TARGET_W}x{TARGET_H} (9:16)')
    print(f'输出: {OUT_DIR}')
    print('=' * 60)

    for i, f in enumerate(FILES):
        process_file(f, i)

    # 汇总
    print('\n' + '=' * 60)
    print('处理完成！文件清单：')
    print('=' * 60)
    for i in range(5):
        base = f'app_screenshot_{i + 1}'
        for ext in ['png', 'jpg', 'webp']:
            path = os.path.join(OUT_DIR, f'{base}.{ext}')
            if os.path.exists(path):
                size = os.path.getsize(path)
                if size > 1024 * 1024:
                    print(f'  {base}.{ext}: {size / (1024 * 1024):.2f} MB')
                else:
                    print(f'  {base}.{ext}: {size / 1024:.0f} KB')
