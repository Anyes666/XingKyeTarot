// Execute the actual pure ArkTS modules after TypeScript transpilation.
// Device APIs and ArkUI still require DevEco / Hypium verification.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const ts = require('typescript');
require.extensions['.ets'] = (module, filename) => {
  const source = fs.readFileSync(filename, 'utf8');
  const result = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 },
    fileName: filename.replace(/\.ets$/, '.ts')
  });
  module._compile(result.outputText, filename);
};
const { TAROT_CARDS } = require('../entry/src/main/ets/data/TarotCardData.ets');
const { CARD_INTERPRETATIONS } = require('../entry/src/main/ets/data/InterpretationData.ets');
const { DIRECT_REPLIES } = require('../entry/src/main/ets/xinglan/data/XinglanDirectReplies.ets');
const { Constants } = require('../entry/src/main/ets/common/Constants.ets');
const { resolveSpecialIntent } = require('../entry/src/main/ets/xinglan/engine/XinglanSpecialIntentResolver.ets');
assert.equal(TAROT_CARDS.length, 78);
assert.equal(new Set(TAROT_CARDS.map(card => card.id)).size, 78);
assert.equal(CARD_INTERPRETATIONS.length, 78);
assert.deepEqual(new Set(CARD_INTERPRETATIONS.map(item => item.cardId)), new Set(TAROT_CARDS.map(card => card.id)));
assert.ok(CARD_INTERPRETATIONS.every(item => item.upright.length > 0 && item.reversed.length > 0));
assert.equal(DIRECT_REPLIES.length, 22);
assert.equal(DIRECT_REPLIES.reduce((n, item) => n + item.variants.length, 0), 40);
assert.equal(Constants.HISTORY_MAX_RECORDS, 50);
for (const [input, expected] of [
  ['', 'SILENCE'], ['我先睡了，晚安', 'GOODBYE'], ['晚安', 'GOODBYE'],
  ['你好', 'GREETING'], ['谢谢你', 'THANKS'], ['累', 'NONE'],
  ['我听到一首晚安的歌', 'GREETING']
]) {
  assert.equal(resolveSpecialIntent(input).intent, expected, input);
}
console.log('PASS: 78 cards / 156 interpretations / 22 direct reply types / 40 variants / 50 history cap');
console.log('PASS: actual special-intent module (7 cases), including goodbye precedence');
