# 星钥塔罗 · AI 生图提示词速查

> 配套文件：`星钥塔罗_陪伴者角色视觉设计稿_v1.0.md`
>
> 本文件只放可直接复制的提示词，不带解释。出图失败时查设计稿 §4.6 调试方法论。

---

## 一、星澜 · 品牌主视觉（XL-A 微低头持钥）

### 1.1 英文完整版（推荐 Flux / Midjourney v6）

```
A brand mascot character illustration for a mobile app, not a tarot card illustration. A young East Asian woman, age 24, with long straight black hair falling naturally to her waist, hair tied half-up with a small delicate golden crescent moon hairpin, no crown, no headdress. Her face is calm and gentle, eyes cast slightly downward, soft gaze, mouth relaxed without obvious smile, expression of quietly listening.

She wears a flowing neo-Chinese fantasy robe: deep blue-black outer robe (color #1F2A4D) with soft drape, moon-white inner garment (#F0ECD8) visible at collar and cuffs, subtle pale gold star-moon embroidery at cuffs and hem, thin gold line at robe edges. Soft fabric, not stiff, not armor.

She holds a small golden key gently with both hands at chest level, the key emits a faint warm glow, not a weapon, not a scepter, just a small delicate key. A tiny golden key pendant hangs at her waist.

Background: deep blue-black night sky, only a few scattered stars, a small crescent moon in the upper area, soft moonlight, faint mist, scattered stardust at the hem of her robe. No temple, no pillars, no magic circle, no crystal ball, no tarot card frame, no altar.

Lighting: soft diffused moonlight from upper left, gentle rim light on hair, warm glow from the key illuminating her hands and lower face, low contrast, dreamy but restrained.

Camera: half-body composition, eye-level slightly above, 85mm lens equivalent, shallow depth of field, subject centered slightly to the right.

Style: neo-Chinese fantasy illustration, app brand mascot, clean and restrained, premium feel, gentle companionship, self-exploration mood, dark blue black and moon white and pale gold palette. NOT a tarot card illustration, NOT a priestess, NOT a fortune teller, NOT a dating sim heroine.

Negative: priestess, fortune teller, tarot card frame, magic circle, crystal ball, temple, altar, crown, large headdress, gold armor, exposed skin, sexy, seductive, evil smile, laughing, sad, looking down on viewer, cyberpunk, modern clothing, suit, animal companion, owl, black cat, huge moon, full tarot illustration, AI artifact, busy background, ornate jewelry.
```

### 1.2 Midjourney 参数

```
--ar 9:16 --v 6 --style raw --stylize 200 --no priestess, crown, magic circle, crystal ball, temple, tarot card frame, armor, headdress, owl, cat
```

### 1.3 Flux 参数

```
guidance: 3.5
num_inference_steps: 28
aspect_ratio: 9:16
```

---

## 二、星衡 · 品牌主视觉（XH-A 持灯侧身）

### 2.1 英文完整版

```
A brand mascot character illustration for a mobile app, not a tarot card illustration. A young East Asian man, age 26, with deep black semi-long hair to shoulder blades, hair tied half-up with a small dark gold astrolabe hair clip, no crown, no headdress. His face is calm and composed, eyes level looking at viewer, clear and gentle gaze, mouth straight without smile, expression of quietly thinking.

He wears a neo-Chinese fantasy robe: deep blue-black outer robe (color #0A0E23) with clean tailored lines, grey-white inner garment (#D8D5C8) at collar, dark gold waist sash, subtle dark gold star-astrolabe embroidery at cuffs and hem, thin dark gold lines. Crisp fabric, more structured than flowing, not stiff armor.

He holds a small star lantern in one hand at waist level, the lantern is simple in shape, contains a point of starlight inside (not flame), emits soft warm white glow. A dark gold key pendant hangs at his waist, the key does not glow.

Background: deep blue-black night sky, only a few scattered stars, a faint star path in the distance, soft starlight, no temple, no pillars, no magic circle, no crystal ball, no tarot card frame, no altar, no desk.

Lighting: soft cool starlight from above, warm glow from the lantern illuminating his hand and lower robe, gentle rim light on hair, restrained contrast, calm and clear mood.

Camera: half-body composition, side profile 45 degrees, eye-level, 85mm lens equivalent, shallow depth of field, subject centered slightly to the left.

Style: neo-Chinese fantasy illustration, app brand mascot, clean and restrained, premium feel, calm rationality, self-exploration mood, dark blue black and grey white and dark gold palette. NOT a tarot card illustration, NOT a priest, NOT a fortune teller, NOT a domineering CEO, NOT a dating sim hero.

Negative: priest, fortune teller, tarot card frame, magic circle, crystal ball, temple, altar, crown, large headdress, gold armor, cape, exposed skin, sexy, seductive, evil smile, laughing, sad, arrogant, domineering, cyberpunk, modern suit, animal companion, owl, cat, huge moon, full tarot illustration, AI artifact, busy background, ornate jewelry.
```

### 2.2 Midjourney 参数

```
--ar 9:16 --v 6 --style raw --stylize 200 --no priest, crown, magic circle, crystal ball, temple, tarot card frame, armor, cape, headdress, owl, cat
```

### 2.3 Flux 参数

```
guidance: 3.5
num_inference_steps: 28
aspect_ratio: 9:16
```

---

## 三、双人分屏引导页（XL-B + XH-C 递钥）

```
Split composition illustration for a mobile app onboarding screen, vertical 9:16 split into left and right halves by a soft starlight divider.

Left half: a young East Asian woman with long black hair, small golden crescent moon hairpin, deep blue-black and moon-white neo-Chinese robe, gently offering a small glowing golden key toward the center divider with one hand, side profile 30 degrees, soft gentle expression. Deep blue night sky background with few stars.

Right half: a young East Asian man with deep black semi-long hair, small dark gold astrolabe hair clip, deep blue-black and grey-white neo-Chinese robe, gently offering a dark gold key (not glowing) toward the center divider with one hand, side profile 30 degrees, calm composed expression. Deep blue night sky background with few stars.

The two keys meet at the center divider but do not touch. Soft moonlight on left, soft starlight on right. The composition reads as two complementary companions, not a couple, not a romance.

Style: app brand mascot illustration, neo-Chinese fantasy, clean and restrained, dark blue black palette with gold accents.

Negative: couple, romance, holding hands, priestess, priest, fortune teller, tarot card, magic circle, crystal ball, temple, crown, armor, headdress, sexy, seductive, cyberpunk, modern clothing, AI artifact.
```

### Midjourney 参数

```
--ar 9:16 --v 6 --style raw --stylize 180 --no couple, romance, holding hands, priestess, priest, tarot card, magic circle, crystal ball, temple, crown, armor
```

---

## 四、App 图标特写（星澜月牙 + 钥匙）

```
App icon design, close-up detail of a small golden crescent moon hairpin with a tiny glowing golden key hanging below it, on a deep blue-black background with three small stars. Minimalist, premium, no text, no character face, no full body, just the hairpin and key as the icon symbol. Soft glow on the key. Rounded square icon format, clean negative space.

Negative: text, character face, full body, complex background, tarot card, magic circle, crystal ball, temple.
```

### Midjourney 参数

```
--ar 1:1 --v 6 --style raw --stylize 150 --no text, face, full body, complex background, tarot, magic circle, crystal ball, temple
```

---

## 五、星澜 · 桌面卡片剪影（XL-D 月下静立）

```
A small silhouette illustration of a young woman with long black hair and a small golden crescent moon hairpin, standing quietly under a deep blue night sky with a crescent moon and three stars. She wears a flowing deep blue-black and moon-white neo-Chinese robe, stardust at the hem. Full body, far view, lots of negative space, minimalist, dreamy, gentle companionship mood. App brand mascot illustration style, not a tarot card.

Negative: priestess, fortune teller, tarot card frame, magic circle, crystal ball, temple, crown, armor, headdress, sexy, cyberpunk, AI artifact.
```

### Midjourney 参数

```
--ar 1:1 --v 6 --style raw --stylize 150 --no priestess, tarot, magic circle, crystal ball, temple, crown, armor
```

---

## 六、星衡 · 桌面卡片剪影（XH-D 夜色静立）

```
A small silhouette illustration of a young man with deep black semi-long hair and a small dark gold astrolabe hair clip, standing quietly under a deep blue night sky with a faint star path and three stars. He wears a deep blue-black and grey-white neo-Chinese robe, holding a small star lantern at his side. Full body, far view, lots of negative space, minimalist, calm and clear mood. App brand mascot illustration style, not a tarot card.

Negative: priest, fortune teller, tarot card frame, magic circle, crystal ball, temple, crown, armor, cape, headdress, sexy, cyberpunk, AI artifact.
```

### Midjourney 参数

```
--ar 1:1 --v 6 --style raw --stylize 150 --no priest, tarot, magic circle, crystal ball, temple, crown, armor, cape
```

---

## 七、快速调试对照表

| 出图症状 | 在哪一层加什么 |
|----------|---------------|
| 整体像占卜师 | 风格层加 `app brand mascot`，负面加 `priestess, fortune teller, tarot` |
| 出现水晶球 | 环境层加 `no crystal ball`，负面加 `crystal ball` |
| 出现法阵 | 环境层加 `no magic circle`，负面加 `magic circle` |
| 两人长得像 | 主体层强化 `golden crescent moon hairpin` vs `dark gold astrolabe hair clip` |
| 服装太华丽 | 服装层加 `clean lines, restrained, minimal embroidery` |
| 表情太冷 | 主体层改为 `mouth relaxed without smile, soft gaze` |
| 表情太媚 | 主体层加 `not seductive, gentle`，负面加 `sexy, seductive` |
| 背景太满 | 环境层加 `minimalist, only 3-5 stars, lots of negative space` |
| 整体像塔罗牌 | 风格层删除所有 `tarot` 字样，改为 `app mascot illustration` |

---

## 八、使用建议

1. **第一次生图**：用 §1.1 / §2.1 英文完整版，不要修改任何词
2. **出图后**：对照设计稿 §6 检查表逐项核对
3. **不满意时**：查 §7 调试对照表，定位是哪一层的问题
4. **小幅调整**：只改出问题的那一层，不要重写整段提示词
5. **批量生成**：保持提示词主体不变，只调整姿态描述（§4.2 姿态库）
6. **平台选择**：Flux 适合写实细腻，Midjourney v6 适合插画感，SDXL 需要 LoRA 才能稳定

> **重要**：永远不要在提示词里出现"塔罗"这个词（包括"轻塔罗感"），它会激活 AI 训练集里的塔罗牌插画分布，导致出来的图永远是塔罗牌主角而非 App 品牌吉祥物。
