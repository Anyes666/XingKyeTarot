#!/usr/bin/env node
/**
 * 今日星页文案库结构检查（Task 3A）
 *
 * 检查 DailyLightCopyLibrary.ets 的 64 条内容：
 * 1. id 全部唯一
 * 2. 每方向恰好 8 条
 * 3. 四字段 trim 后非空
 * 4. 每方向 warmth 含 1/3/5
 * 5. 每方向 suggestionStrength 含 1/2/3
 * 6. 红线词扫描
 * 7. pocketLight 长度 20-40 字（超出列 WARN 不失败）
 *
 * 注意：ArkTS 无法被 Node 直接 import，此脚本通过正则解析 .ets 源码。
 * 这不等价于真实 ArkTS 引擎执行（SHADOW 级别）。
 */

const fs = require('fs');
const path = require('path');

const LIB_PATH = path.join(__dirname, '..', 'entry', 'src', 'main', 'ets', 'daily', 'data', 'DailyLightCopyLibrary.ets');

const RED_LINE_WORDS = [
  '一定会', '必然', '命中注定', '复合', '复合概率', '正缘', '烂桃花',
  '对方爱你', '他爱你', '她爱你', '转运', '财运', '中奖', '神准',
  '灵验', '改命', '保证', '你必须', '马上断联', '赶紧离开',
  '你应该继续', '你应该离开', '亲爱的', '宝贝', '我一直在等你', '我只属于你'
];

const DIRECTIONS = [
  'GENTLE', 'ATTENTION', 'LESS_RESULT', 'BLANK',
  'SLOW', 'HEAR_SELF', 'BOUNDARY', 'ALLOW_IMPERFECT'
];

function parseLibrary(source) {
  const items = [];
  const blockRe = /\{\s*id:\s*'([^']+)',\s*direction:\s*DailyDirection\.([A-Z_]+),\s*mainLine:\s*'([^']*)',\s*observation:\s*'([^']*)',\s*microAction:\s*'([^']*)',\s*pocketLight:\s*'([^']*)',\s*warmth:\s*(\d),\s*suggestionStrength:\s*(\d),\s*sensitive:\s*(true|false)\s*\}/g;
  let m;
  while ((m = blockRe.exec(source)) !== null) {
    items.push({
      id: m[1],
      direction: m[2],
      mainLine: m[3],
      observation: m[4],
      microAction: m[5],
      pocketLight: m[6],
      warmth: parseInt(m[7]),
      suggestionStrength: parseInt(m[8]),
      sensitive: m[9] === 'true'
    });
  }
  return items;
}

function main() {
  const source = fs.readFileSync(LIB_PATH, 'utf-8');
  const items = parseLibrary(source);

  let errors = 0;
  let warns = 0;

  // 1. 总数
  if (items.length !== 64) {
    console.error(`FAIL: expected 64 items, got ${items.length}`);
    errors++;
  } else {
    console.log(`OK: total ${items.length} items`);
  }

  // 2. id 唯一
  const ids = new Set();
  const dupIds = [];
  for (const it of items) {
    if (ids.has(it.id)) dupIds.push(it.id);
    ids.add(it.id);
  }
  if (dupIds.length > 0) {
    console.error(`FAIL: duplicate ids: ${dupIds.join(', ')}`);
    errors++;
  } else {
    console.log(`OK: all ${ids.size} ids unique`);
  }

  // 3. 每方向 8 条
  const dirCounts = {};
  for (const d of DIRECTIONS) dirCounts[d] = 0;
  for (const it of items) {
    if (dirCounts[it.direction] !== undefined) dirCounts[it.direction]++;
  }
  for (const d of DIRECTIONS) {
    if (dirCounts[d] !== 8) {
      console.error(`FAIL: direction ${d} has ${dirCounts[d]} items, expected 8`);
      errors++;
    } else {
      console.log(`OK: ${d} = 8 items`);
    }
  }

  // 4. 四字段非空
  for (const it of items) {
    if (!it.mainLine.trim() || !it.observation.trim() || !it.microAction.trim() || !it.pocketLight.trim()) {
      console.error(`FAIL: ${it.id} has empty field`);
      errors++;
    }
  }

  // 5. 每方向 warmth 含 1/3/5
  for (const d of DIRECTIONS) {
    const warmthSet = new Set(items.filter(i => i.direction === d).map(i => i.warmth));
    if (!warmthSet.has(1) || !warmthSet.has(3) || !warmthSet.has(5)) {
      console.error(`FAIL: ${d} warmth missing 1/3/5, has: ${[...warmthSet].sort().join(',')}`);
      errors++;
    } else {
      console.log(`OK: ${d} warmth covers 1/3/5`);
    }
  }

  // 6. 每方向 suggestionStrength 含 1/2/3
  for (const d of DIRECTIONS) {
    const sSet = new Set(items.filter(i => i.direction === d).map(i => i.suggestionStrength));
    if (!sSet.has(1) || !sSet.has(2) || !sSet.has(3)) {
      console.error(`FAIL: ${d} suggestionStrength missing 1/2/3, has: ${[...sSet].sort().join(',')}`);
      errors++;
    } else {
      console.log(`OK: ${d} suggestionStrength covers 1/2/3`);
    }
  }

  // 7. 红线词扫描
  let redLineHits = 0;
  for (const it of items) {
    const allText = it.mainLine + it.observation + it.microAction + it.pocketLight;
    for (const w of RED_LINE_WORDS) {
      if (allText.includes(w)) {
        console.error(`FAIL: ${it.id} contains red line word "${w}"`);
        redLineHits++;
        errors++;
      }
    }
  }
  if (redLineHits === 0) console.log(`OK: no red line words in any content`);

  // 8. pocketLight 长度 20-40（WARN 不失败）
  for (const it of items) {
    const len = it.pocketLight.length;
    if (len < 20 || len > 40) {
      console.warn(`WARN: ${it.id} pocketLight length=${len} (suggested 20-40): "${it.pocketLight}"`);
      warns++;
    }
  }

  console.log(`\n=== SUMMARY ===`);
  console.log(`Total items: ${items.length}`);
  console.log(`Errors: ${errors}`);
  console.log(`Warnings: ${warns}`);
  console.log(`Status: ${errors === 0 ? 'PASS' : 'FAIL'}`);

  process.exit(errors === 0 ? 0 : 1);
}

main();
