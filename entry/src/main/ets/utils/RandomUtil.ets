export class RandomUtil {
  /**
   * FNV-1a hash: converts a string seed into a 32-bit unsigned integer.
   */
  static hashSeed(seed: string): number {
    let hash: number = 2166136261;
    for (let i = 0; i < seed.length; i++) {
      hash ^= seed.charCodeAt(i);
      hash = Math.imul(hash, 16777619);
    }
    return hash >>> 0;
  }

  /**
   * Xorshift32 PRNG: produces the next 32-bit unsigned integer from a seed value.
   */
  static next(seedValue: number): number {
    let x: number = seedValue >>> 0;
    x ^= x << 13;
    x ^= x >>> 17;
    x ^= x << 5;
    return x >>> 0;
  }

  /**
   * Generates `count` deterministic pseudo-random floats in [0, 1) from a string seed.
   * Same seed + same count always produces the same sequence.
   */
  static seededNumbers(seed: string, count: number): number[] {
    const values: number[] = [];
    let current: number = RandomUtil.hashSeed(seed);
    for (let i = 0; i < count; i++) {
      current = RandomUtil.next(current);
      values.push(current / 0xffffffff);
    }
    return values;
  }

  /**
   * Draws `count` unique indexes from [0, total) using Fisher-Yates shuffle
   * seeded by the given string. Guarantees no duplicates.
   */
  static drawUniqueIndexes(total: number, count: number, seed: string): number[] {
    if (count > total) {
      throw new Error(`Cannot draw ${count} unique indexes from ${total} items`);
    }
    const indexes: number[] = [];
    for (let i = 0; i < total; i++) {
      indexes.push(i);
    }
    let current: number = RandomUtil.hashSeed(seed);
    for (let i = indexes.length - 1; i > 0; i--) {
      current = RandomUtil.next(current);
      const j: number = current % (i + 1);
      const temp: number = indexes[i];
      indexes[i] = indexes[j];
      indexes[j] = temp;
    }
    return indexes.slice(0, count);
  }

  /**
   * Returns a deterministic boolean from a seed + salt combination.
   */
  static booleanFromSeed(seed: string, salt: string): boolean {
    return RandomUtil.seededNumbers(`${seed}-${salt}`, 1)[0] >= 0.5;
  }
}
