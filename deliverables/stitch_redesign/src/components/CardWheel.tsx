import React, { useState, useEffect, useRef } from "react";
import { Sparkles, Play, Pause, ChevronLeft, RefreshCw, Star } from "lucide-react";
import { MAJOR_ARCANA, TarotCard } from "../tarotData";
import { motion, AnimatePresence } from "motion/react";

interface CardWheelProps {
  onBack: () => void;
  onSaveDraw: (draw: {
    id: string;
    date: string;
    type: string;
    cards: { card: TarotCard; isUpright: boolean }[];
    reading: any;
    question: string;
  }) => void;
}

export default function CardWheel({ onBack, onSaveDraw }: CardWheelProps) {
  const [step, setStep] = useState<"draw" | "result">("draw");
  const [selectedCards, setSelectedCards] = useState<{ card: TarotCard; isUpright: boolean }[]>([]);
  const [isSpinning, setIsSpinning] = useState(true);
  const [angleOffset, setAngleOffset] = useState(0);
  const [focusedIndex, setFocusedIndex] = useState(0);
  const [isGenerating, setIsGenerating] = useState(false);
  const [reading, setReading] = useState<string>("");

  const spinRef = useRef<number | null>(null);

  // We can pick a beautiful subset of 12 Major Arcana cards to display on the wheel for visual neatness
  const wheelCards = useRef<TarotCard[]>(MAJOR_ARCANA.slice(0, 12));
  const cardCount = wheelCards.current.length;

  // Let the wheel rotate continuously
  useEffect(() => {
    if (isSpinning) {
      const animate = () => {
        setAngleOffset((prev) => (prev + 0.5) % 360);
        spinRef.current = requestAnimationFrame(animate);
      };
      spinRef.current = requestAnimationFrame(animate);
    } else {
      if (spinRef.current) cancelAnimationFrame(spinRef.current);
    }

    return () => {
      if (spinRef.current) cancelAnimationFrame(spinRef.current);
    };
  }, [isSpinning]);

  // Sync focused card which is closest to the front (bottom center: 270 degrees or closest to absolute angle)
  useEffect(() => {
    // Normalize angle to find which card sits closest to the front center
    // Each card is placed at (index * 360 / cardCount) + angleOffset
    let closestIndex = 0;
    let minDistance = Infinity;

    for (let i = 0; i < cardCount; i++) {
      const cardAngle = ((i * 360) / cardCount + angleOffset) % 360;
      // Front center is roughly 270 degrees (or 90 degrees depending on axis)
      // Let's define the center as 180 degrees (bottom view)
      const distance = Math.min(
        Math.abs(cardAngle - 180),
        Math.abs(cardAngle - 180 - 360),
        Math.abs(cardAngle - 180 + 360)
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    setFocusedIndex(closestIndex);
  }, [angleOffset, cardCount]);

  const handleToggleSpin = () => {
    setIsSpinning(!isSpinning);
  };

  const handleConfirmCard = () => {
    // Pick the focused card
    const currentCard = wheelCards.current[focusedIndex];
    
    // Check if already selected
    if (selectedCards.some((item) => item.card.id === currentCard.id)) {
      alert("这张星钥牌你已经选过啦，再转一转，选择其他缘分卡牌吧。");
      return;
    }

    const isUpright = Math.random() > 0.15; // 85% upright
    const newSelected = [...selectedCards, { card: currentCard, isUpright }];
    setSelectedCards(newSelected);

    // If we reach 3 cards, trigger interpretation
    if (newSelected.length === 3) {
      generateWheelReading(newSelected);
    }
  };

  const generateWheelReading = async (cards: typeof selectedCards) => {
    setStep("result");
    setIsGenerating(true);
    setReading("");

    try {
      const response = await fetch("/api/tarot/holy-triangle", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          question: "旋转牌轮心灵印记",
          category: "综合",
          // Send specific card IDs to help server understand
        }),
      });
      const data = await response.json();

      if (response.ok) {
        // We customize the synthesis text from the server, or use its reading
        const readingBody = `✨ 星钥共鸣：
今天的旋转牌轮为你凝聚了三张星钥：【${cards[0].card.name}】、【${cards[1].card.name}】与【${cards[2].card.name}】。

这三股力量正合流照亮你此刻的心境。第一张【${cards[0].card.name}】代表着你现在最需释放的表层能量；第二张【${cards[1].card.name}】暗示你当下深藏的无意识诉求；而第三张【${cards[2].card.name}】则是星澜送给你的未来守护之钥。

星光告诉我们：生活不是一场狂奔，而是一场水流的融合。你所经历的所有波折，都早已在浩瀚星图中写下了明媚的伏笔。放轻松，亲爱的旅者，此时此刻，月光正温柔洒落在你肩上。`;

        setReading(data.reading?.synthesis || readingBody);
        setIsGenerating(false);

        // Save to archives
        onSaveDraw({
          id: `wheel_${Date.now()}`,
          date: new Date().toLocaleDateString("zh-CN", {
            year: "numeric",
            month: "long",
            day: "numeric",
          }),
          type: "旋转牌轮",
          question: "旋转星钥心灵共鸣",
          cards: cards,
          reading: { single: data.reading?.synthesis || readingBody },
        });
      } else {
        throw new Error();
      }
    } catch (err) {
      setIsGenerating(false);
      setReading(`✨ 旋转星钥之语：
旅者，你的指引之牌为：【${cards[0].card.name}】、【${cards[1].card.name}】和【${cards[2].card.name}】。
星澜正默默注视着你。这意味着你正处于一个极佳的自我修护期。不要急于追求结果，宇宙有其自然的成熟轨迹。一切都是最好的安排。`);
    }
  };

  const handleReset = () => {
    setSelectedCards([]);
    setStep("draw");
    setIsSpinning(true);
  };

  return (
    <div className="h-full flex flex-col justify-between select-none overflow-y-auto pb-10 text-white">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-950/50 backdrop-blur-md sticky top-0 z-10 bg-slate-950/40">
        <button onClick={onBack} className="p-2 -ml-2 rounded-full hover:bg-slate-900 transition-colors">
          <ChevronLeft className="w-5 h-5 text-slate-300" />
        </button>
        <span className="font-medium text-amber-200 tracking-wide text-base">旋转牌轮</span>
        <div className="w-9"></div>
      </div>

      <div className="flex-1 px-5 pt-4 space-y-6">
        <AnimatePresence mode="wait">
          {step === "draw" && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="space-y-6 flex flex-col items-center"
            >
              <div className="text-center space-y-1">
                <h3 className="text-base font-serif font-medium text-amber-100">让牌轮慢慢转动</h3>
                <p className="text-xs text-slate-400">当它停下时，选中最靠近你的那一两张。</p>
              </div>

              {/* 3D Wheel Canvas (Highly-polished custom CSS ring layout) */}
              <div className="relative w-full h-[320px] flex items-center justify-center overflow-hidden border border-indigo-950/40 rounded-2xl bg-slate-950/40 backdrop-blur-sm">
                {/* Center Core Light */}
                <div className="absolute w-20 h-20 bg-amber-500/5 rounded-full blur-2xl animate-pulse" />
                <div className="absolute w-12 h-12 border border-amber-500/10 rounded-full flex items-center justify-center">
                  <Star className="w-4 h-4 text-amber-500/40 animate-spin [animation-duration:15s]" />
                </div>

                {/* Rotating Cards Ring */}
                <div className="absolute w-full h-full flex items-center justify-center">
                  {wheelCards.current.map((card, idx) => {
                    // Position calculations
                    const cardAngle = (idx * 360) / cardCount + angleOffset;
                    const radian = (cardAngle * Math.PI) / 180;
                    
                    // Oval layout
                    const radiusX = 110;
                    const radiusY = 40;
                    const x = radiusX * Math.cos(radian);
                    const y = radiusY * Math.sin(radian);

                    // 3D scale & Z-Index depth
                    // Closest is at bottom (sin(radian) approx 1, i.e. 90 deg or 180 depending on polar)
                    // Let's calibrate depth using Sin
                    const scale = 0.65 + 0.35 * (Math.sin(radian) + 1) / 2;
                    const zIndex = Math.round(10 + 90 * (Math.sin(radian) + 1) / 2);
                    const opacity = 0.4 + 0.6 * (Math.sin(radian) + 1) / 2;

                    const isFocused = idx === focusedIndex;

                    return (
                      <div
                        key={card.id}
                        style={{
                          transform: `translate(${x}px, ${y}px) scale(${scale})`,
                          zIndex: zIndex,
                          opacity: opacity,
                        }}
                        className={`absolute w-20 h-32 rounded-xl border transition-all duration-300 overflow-hidden flex flex-col justify-between p-1.5 shadow-2xl ${
                          isFocused
                            ? "border-amber-400 bg-slate-900 ring-2 ring-amber-500/20 scale-105"
                            : "border-amber-500/20 bg-slate-950/90"
                        }`}
                      >
                        {/* Golden details */}
                        <div className="flex justify-between text-[6px] text-amber-500/40">
                          <span>{card.id}</span>
                          <span>{card.element}</span>
                        </div>

                        {/* Central Glyph */}
                        <div className="flex-1 my-1 border border-amber-500/5 rounded bg-slate-950 flex items-center justify-center relative">
                          <div className={`w-5 h-5 rounded-full flex items-center justify-center bg-gradient-to-br ${card.themeColor} bg-opacity-25`}>
                            <Star className="w-2.5 h-2.5 text-amber-200" />
                          </div>
                        </div>

                        <div className="text-center">
                          <span className="text-[8px] font-medium text-slate-300 block truncate font-serif">
                            {card.name}
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Progress Panel */}
              <div className="w-full space-y-3">
                {/* Active Key Preview slots */}
                <div className="flex justify-center gap-3">
                  {[0, 1, 2].map((slotIdx) => {
                    const saved = selectedCards[slotIdx];
                    return (
                      <div
                        key={slotIdx}
                        className={`w-14 h-20 rounded-xl border flex flex-col items-center justify-center relative transition-all ${
                          saved
                            ? "border-amber-500/40 bg-indigo-950/40 text-amber-200"
                            : "border-dashed border-indigo-950/80 bg-slate-950/20 text-slate-600"
                        }`}
                      >
                        {saved ? (
                          <>
                            <span className="text-[8px] text-amber-500/60 uppercase">星钥</span>
                            <span className="text-xs font-serif font-medium mt-1">{saved.card.name}</span>
                          </>
                        ) : (
                          <Star className="w-4 h-4 opacity-40" />
                        )}
                      </div>
                    );
                  })}
                </div>

                <div className="text-center text-xs text-slate-400">
                  选择进度 {selectedCards.length} / 3
                </div>

                {/* Selection Action Button (Gradient matches screenshot) */}
                <button
                  onClick={handleConfirmCard}
                  disabled={selectedCards.length >= 3}
                  className={`w-full py-3.5 px-4 rounded-full text-sm font-semibold flex items-center justify-center gap-2 cursor-pointer transition-all ${
                    selectedCards.length < 3
                      ? "bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950 shadow-md active:scale-95 hover:from-amber-400"
                      : "bg-slate-900 border border-indigo-950 text-slate-500 cursor-not-allowed"
                  }`}
                >
                  确认第 {selectedCards.length + 1} 张星钥
                </button>

                {/* Control Toggler */}
                <div className="flex justify-center pt-2">
                  <button
                    onClick={handleToggleSpin}
                    className="px-4 py-2 rounded-full border border-indigo-950 bg-slate-950/80 hover:bg-slate-900 text-xs font-medium text-slate-300 flex items-center gap-1.5 transition-all"
                  >
                    {isSpinning ? (
                      <>
                        <Pause className="w-3.5 h-3.5" />
                        让牌轮慢慢停下
                      </>
                    ) : (
                      <>
                        <Play className="w-3.5 h-3.5" />
                        让牌轮慢慢转动
                      </>
                    )}
                  </button>
                </div>
              </div>
            </motion.div>
          )}

          {/* Reading State */}
          {step === "result" && (
            <motion.div
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              className="space-y-6"
            >
              <div className="text-center space-y-1">
                <h4 className="text-xs text-amber-400 tracking-widest font-mono">ASTRO KEY INSIGHT</h4>
                <h3 className="text-lg font-serif font-medium text-slate-100">星钥共鸣契约</h3>
              </div>

              {/* Chosen Cards Trio */}
              <div className="flex justify-center gap-3 bg-slate-950/40 p-4 rounded-2xl border border-indigo-950">
                {selectedCards.map((item, idx) => (
                  <div key={idx} className="flex flex-col items-center space-y-1">
                    <div className="w-[80px] h-[115px] rounded-xl border border-amber-500/30 bg-slate-900 flex flex-col justify-between p-2 relative overflow-hidden bg-gradient-to-b from-indigo-950 to-slate-950">
                      <div className="flex justify-between items-center text-amber-400/40 text-[6px]">
                        <span>{item.card.id}</span>
                        <span>{item.card.element}</span>
                      </div>
                      <div className="flex-1 flex items-center justify-center my-1 border border-amber-500/5 rounded bg-slate-950/50">
                        <div className={`w-5 h-5 rounded-full flex items-center justify-center bg-gradient-to-br ${item.card.themeColor} bg-opacity-20`}>
                          <Star className="w-2.5 h-2.5 text-amber-200" />
                        </div>
                      </div>
                      <div className="text-center">
                        <span className="text-[10px] font-medium font-serif text-slate-200 leading-none">{item.card.name}</span>
                        <p className="text-[6px] text-amber-400 mt-0.5">{item.isUpright ? "正位" : "逆位"}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              {/* Generate Reading Animation or Content */}
              {isGenerating ? (
                <div className="flex flex-col items-center justify-center py-10 space-y-4">
                  <div className="w-8 h-8 border-2 border-t-amber-400 border-indigo-950 rounded-full animate-spin" />
                  <p className="text-xs text-slate-400 animate-pulse">星澜正在深度共鸣这三枚心灵指引...</p>
                </div>
              ) : (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="space-y-6"
                >
                  <div className="bg-slate-950/60 rounded-2xl p-5 border border-indigo-950/60 text-slate-200 text-sm leading-relaxed whitespace-pre-line relative overflow-hidden shadow-inner">
                    <div className="absolute top-0 right-0 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl" />
                    {reading}
                  </div>

                  {/* Actions */}
                  <div className="flex gap-3">
                    <button
                      onClick={onBack}
                      className="flex-1 bg-slate-900 border border-indigo-950 text-slate-300 text-xs py-3.5 px-4 rounded-xl flex items-center justify-center hover:text-white transition-colors"
                    >
                      返回首页
                    </button>
                    <button
                      onClick={handleReset}
                      className="flex-1 bg-amber-400/10 border border-amber-400/30 text-amber-200 text-xs py-3.5 px-4 rounded-xl flex items-center justify-center gap-2 hover:bg-amber-400/20 transition-colors"
                    >
                      <RefreshCw className="w-3.5 h-3.5" />
                      重新抽牌
                    </button>
                  </div>
                </motion.div>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
