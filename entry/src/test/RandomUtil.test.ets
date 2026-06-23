import { describe, it, expect } from '@ohos/hypium';
import { RandomUtil } from '../main/ets/utils/RandomUtil';

export default function randomUtilTest(): void {
  describe('RandomUtil', () => {
    it('returns_same_sequence_for_same_seed', 0, () => {
      const seed: string = '2026-06-22-device-abc';
      const a: number[] = RandomUtil.seededNumbers(seed, 5);
      const b: number[] = RandomUtil.seededNumbers(seed, 5);
      expect(JSON.stringify(a)).assertEqual(JSON.stringify(b));
    });

    it('draws_unique_indexes_correct_count', 0, () => {
      const result: number[] = RandomUtil.drawUniqueIndexes(10, 3, 'test-seed');
      expect(result.length).assertEqual(3);
    });

    it('drawn_indexes_are_unique', 0, () => {
      const result: number[] = RandomUtil.drawUniqueIndexes(10, 3, 'test-seed');
      expect(new Set(result).size).assertEqual(3);
    });

    it('throws_when_count_exceeds_total', 0, () => {
      let threw: boolean = false;
      try {
        RandomUtil.drawUniqueIndexes(3, 5, 'error-test');
      } catch (e) {
        threw = true;
      }
      expect(threw).assertEqual(true);
    });

    it('booleanFromSeed_is_deterministic', 0, () => {
      const a: boolean = RandomUtil.booleanFromSeed('bool-seed', 'salt');
      const b: boolean = RandomUtil.booleanFromSeed('bool-seed', 'salt');
      expect(a).assertEqual(b);
    });
  });
}
