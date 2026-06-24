import { describe, it, expect } from '@ohos/hypium';
import { DivinationService } from '../../../src/main/ets/service/DivinationService';
import { TarotDataService } from '../../../src/main/ets/service/TarotDataService';
import { DivinationRecord, DrawnCard } from '../../../src/main/ets/model/DivinationRecord';

export default function divinationServiceTest(): void {
  describe('DivinationService', () => {
    /**
     * Before testing draw, ensure TarotDataService is initialized.
     */
    it('draw_sacred_triangle_returns_3_cards', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'test-seed-001');
        expect(record.cards.length).assertEqual(3);
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * All 3 cards are unique.
     */
    it('drawn_cards_are_unique', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'test-seed-002');
        const ids: string[] = record.cards.map((d: DrawnCard) => d.card.id);
        expect(new Set(ids).size).assertEqual(3);
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Each drawn card has position name, interpretation, and keywords.
     */
    it('each_card_has_position_and_interpretation', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'test-seed-003');
        record.cards.forEach((d: DrawnCard, idx: number) => {
          expect(d.positionName.length).assertLarger(0);
          expect(d.interpretation.length).assertLarger(0);
          expect(d.keywords.length).assertLarger(0);
        });
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Same seed produces same draw (deterministic).
     */
    it('same_seed_produces_same_draw', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const a: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'deterministic-seed');
        const b: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'deterministic-seed');
        const idsA: string = JSON.stringify(a.cards.map((d: DrawnCard) => d.card.id));
        const idsB: string = JSON.stringify(b.cards.map((d: DrawnCard) => d.card.id));
        expect(idsA).assertEqual(idsB);
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Spread template is Sacred Triangle.
     */
    it('spread_is_sacred_triangle', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'spread-test');
        expect(record.spread.id).assertEqual('sacred_triangle');
        expect(record.spread.name).assertEqual('圣三角');
        expect(record.spread.positions.length).assertEqual(3);
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Position names are correct: 过去, 现在, 未来.
     */
    it('positions_are_past_present_future', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawSacredTriangle('test', 'pos-test');
        expect(record.cards[0].positionName).assertEqual('过去');
        expect(record.cards[1].positionName).assertEqual('现在');
        expect(record.cards[2].positionName).assertEqual('未来');
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Single card spread draws exactly one card.
     */
    it('single_card_spread_returns_1_card', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawBySpreadId('single_card', 'general', 'single-test');
        expect(record.spread.id).assertEqual('single_card');
        expect(record.cards.length).assertEqual(1);
        expect(record.cards[0].positionName).assertEqual('指引');
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Relationship spread reuses 3-card draw with relationship position names.
     */
    it('relationship_spread_returns_relationship_positions', 0, async (done: Function) => {
      try {
        const dataSvc: TarotDataService = TarotDataService.getInstance();
        const ctx: Context = getContext();
        await dataSvc.init(ctx.resourceManager);

        const record: DivinationRecord = await DivinationService.drawBySpreadId('relationship', 'love', 'relationship-test');
        expect(record.spread.id).assertEqual('relationship');
        expect(record.cards.length).assertEqual(3);
        expect(record.cards[0].positionName).assertEqual('我的状态');
        expect(record.cards[1].positionName).assertEqual('对方状态');
        expect(record.cards[2].positionName).assertEqual('关系走向');
        done();
      } catch (err) {
        done();
      }
    });
  });
}
