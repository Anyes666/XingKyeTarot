import { describe, it, expect } from '@ohos/hypium';
import xinglanRegressionTest from './XinglanRegression.test';

export default function defaultTest() {
  describe('Sanity', () => {
    it('project is correctly set up', 0, () => {
      expect(1 + 1).assertEqual(2);
    });
  });

  // ═══ V2 验收收尾：星澜 42 条回归用例 Hypium 真实引擎测试（Task 1B-C）═══
  // 状态：HYPIUM_TEST_DRAFTED
  // 实际执行需通过 DevEco Studio IDE（右键 run）
  xinglanRegressionTest();
}
