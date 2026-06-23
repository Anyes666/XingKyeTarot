import { describe, it, expect } from '@ohos/hypium';
import { RandomUtil } from '../../../src/main/ets/utils/RandomUtil';

export default function randomUtilTest(): void {
  describe('RandomUtil', () => {
    /**
     * Deterministic: same seed + same count => identical sequence.
     */
    it('returns_same_sequence_for_same_seed', 0, () => {
      const seed: string = '2026-06-22-device-abc';
      const a: number[] = RandomUtil.seededNumbers(seed, 5);
      const b: number[] = RandomUtil.seededNumbers(seed, 5);
      expect(JSON.stringify(a)).assertEqual(JSON.stringify(b));
    });

    /**
     * Different seeds produce different sequences.
     */
    it('different_seeds_produce_different_sequences', 0, () => {
      const a: number[] = RandomUtil.seededNumbers('seed-alpha', 5);
      const b: number[] = RandomUtil.seededNumbers('seed-beta', 5);
      expect(JSON.stringify(a) === JSON.stringify(b)).assertEqual(false);
    });

    /**
     * Draw unique indexes: count matches, all distinct.
     */
    it('draws_unique_indexes_correct_count', 0, () => {
      const result: number[] = RandomUtil.drawUniqueIndexes(10, 3, 'test-seed');
      expect(result.length).assertEqual(3);
    });

    it('drawn_indexes_are_unique', 0, () => {
      const result: number[] = RandomUtil.drawUniqueIndexes(10, 3, 'test-seed');
      expect(new Set(result).size).assertEqual(3);
    });

    /**
     * Draw unique: same seed produces same draw.
     */
    it('same_seed_produces_same_draw', 0, () => {
      const a: number[] = RandomUtil.drawUniqueIndexes(78, 3, 'daily-2026-06-22');
      const b: number[] = RandomUtil.drawUniqueIndexes(78, 3, 'daily-2026-06-22');
      expect(JSON.stringify(a)).assertEqual(JSON.stringify(b));
    });

    /**
     * All drawn indexes are within range [0, total).
     */
    it('drawn_indexes_within_range', 0, () => {
      const result: number[] = RandomUtil.drawUniqueIndexes(78, 3, 'range-test');
      result.forEach((idx: number) => {
        expect(idx >= 0 && idx < 78).assertEqual(true);
      });
    });

    /**
     * Error when count > total.
     */
    it('throws_when_count_exceeds_total', 0, () => {
      let threw: boolean = false;
      try {
        RandomUtil.drawUniqueIndexes(3, 5, 'error-test');
      } catch (e) {
        threw = true;
      }
      expect(threw).assertEqual(true);
    });

    /**
     * booleanFromSeed is deterministic.
     */
    it('booleanFromSeed_is_deterministic', 0, () => {
      const a: boolean = RandomUtil.booleanFromSeed('bool-seed', 'salt');
      const b: boolean = RandomUtil.booleanFromSeed('bool-seed', 'salt');
      expect(a).assertEqual(b);
    });
  });
}
