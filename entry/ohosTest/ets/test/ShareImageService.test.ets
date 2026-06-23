import { describe, it, expect } from '@ohos/hypium';
import { ShareImageService } from '../../../src/main/ets/service/ShareImageService';
import { DivinationRecord } from '../../../src/main/ets/model/DivinationRecord';
import { SACRED_TRIANGLE_SPREAD } from '../../../src/main/ets/model/Spread';

export default function shareImageServiceTest(): void {
  describe('ShareImageService', () => {
    it('buildShareImageFileName_returns_png_name_with_record_id', 0, () => {
      const record: DivinationRecord = {
        id: 'record_123456',
        questionType: 'general',
        spread: SACRED_TRIANGLE_SPREAD,
        cards: [],
        createdAt: 123456
      };

      const fileName: string = ShareImageService.buildShareImageFileName(record);

      expect(fileName).assertEqual('xingkey_tarot_record_123456.png');
    });
  });
}
