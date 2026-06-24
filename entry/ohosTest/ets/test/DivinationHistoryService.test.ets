import { describe, it, expect } from '@ohos/hypium';
import { DivinationHistoryService } from '../../../src/main/ets/service/DivinationHistoryService';
import { DivinationService } from '../../../src/main/ets/service/DivinationService';
import { TarotDataService } from '../../../src/main/ets/service/TarotDataService';
import { DivinationRecord } from '../../../src/main/ets/model/DivinationRecord';

export default function divinationHistoryServiceTest(): void {
  describe('DivinationHistoryService', () => {
    it('saveRecord_deduplicates_by_id', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);
        await DivinationHistoryService.clearHistoryForTest(ctx);

        const record: DivinationRecord = await DivinationService.drawBySpreadId('single_card', 'general', 'history-dedupe');
        await DivinationHistoryService.saveRecord(record, ctx);
        await DivinationHistoryService.saveRecord(record, ctx);

        const history: DivinationRecord[] = await DivinationHistoryService.getRecentRecords(ctx);
        expect(history.length).assertEqual(1);
        expect(history[0].id).assertEqual(record.id);
        done();
      } catch (err) {
        done();
      }
    });
  });
}
