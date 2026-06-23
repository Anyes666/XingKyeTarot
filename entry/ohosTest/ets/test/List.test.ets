import { describe, it, expect } from '@ohos/hypium';

export default function defaultTest() {
  describe('Sanity', () => {
    it('project is correctly set up', 0, () => {
      expect(1 + 1).assertEqual(2);
    });
  });
}
