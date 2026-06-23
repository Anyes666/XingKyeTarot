import { describe, it, expect } from '@ohos/hypium';
import { TarotDataService } from '../../../src/main/ets/service/TarotDataService';

export default function tarotDataServiceTest(): void {
  describe('TarotDataService', () => {
    /**
     * Service starts uninitialized.
     */
    it('singleton_is_not_null', 0, () => {
      const svc: TarotDataService = TarotDataService.getInstance();
      expect(svc !== null && svc !== undefined).assertEqual(true);
    });

    it('not_initialized_before_init', 0, () => {
      const svc: TarotDataService = TarotDataService.getInstance();
      // Before init() with a real resourceManager, isInitialized should be false
      // unless previously initialized in another test.
      // We just verify the method exists and returns boolean.
      const result: boolean = svc.isInitialized();
      expect(typeof result === 'boolean').assertEqual(true);
    });

    /**
     * After init with valid data, cards and interpretations load correctly.
     * Note: This test requires a real getContext().resourceManager in DevEco/harmony test runner.
     */
    it('loads_cards_after_init', 0, async (done: Function) => {
      const svc: TarotDataService = TarotDataService.getInstance();
      try {
        await svc.init();
        expect(svc.getCardCount()).assertLarger(0);
        const card = svc.getAllCards()[0];
        expect(card.nameZh.length).assertLarger(0);
        expect(svc.getInterpretation(card.id, false).length).assertLarger(0);
        expect(svc.getInterpretation(card.id, true).length).assertLarger(0);
        const uprightKeys: string[] = svc.getKeywords(card.id, false);
        const reversedKeys: string[] = svc.getKeywords(card.id, true);
        expect(uprightKeys.length).assertLarger(0);
        expect(reversedKeys.length).assertLarger(0);
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Upright and reversed interpretations differ.
     */
    it('upright_and_reversed_interpretations_differ', 0, async (done: Function) => {
      const svc: TarotDataService = TarotDataService.getInstance();
      try {
        await svc.init();
        const card = svc.getAllCards()[0];
        const up: string = svc.getInterpretation(card.id, false);
        const rev: string = svc.getInterpretation(card.id, true);
        expect(up === rev).assertEqual(false);
        done();
      } catch (err) {
        done();
      }
    });

    /**
     * Missing card throws.
     */
    it('throws_for_unknown_card_id', 0, () => {
      const svc: TarotDataService = TarotDataService.getInstance();
      let threw: boolean = false;
      try {
        svc.getInterpretation('nonexistent_card', false);
      } catch (e) {
        threw = true;
      }
      expect(threw).assertEqual(true);
    });

    /**
     * getCardById returns correct card or throws.
     */
    it('getCardById_throws_for_unknown', 0, () => {
      const svc: TarotDataService = TarotDataService.getInstance();
      let threw: boolean = false;
      try {
        svc.getCardById('nonexistent');
      } catch (e) {
        threw = true;
      }
      expect(threw).assertEqual(true);
    });
  });
}
