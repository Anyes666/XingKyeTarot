import React, { useState } from "react";
import { Sparkles, HelpCircle, ChevronLeft, RefreshCw } from "lucide-react";
import { MAJOR_ARCANA, TarotCard } from "../tarotData";
import { motion, AnimatePresence } from "motion/react";

interface HolyTriangleProps {
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

export default function HolyTriangle({ onBack, onSaveDraw }: HolyTriangleProps) {
  const [question, setQuestion] = useState("");
  const [category, setCategory] = useState("感情");
  const [isDrawing, setIsDrawing] = useState(false);
  const [reading, setReading] = useState<{
    introduction?: string;
    pastReading?: string;
    presentReading?: string;
    futureReading?: string;
    synthesis?: string;
  } | null>(null);

  const [past, setPast] = useState<{ card: TarotCard; isUpright: boolean } | null>(null);
  const [present, setPresent] = useState<{ card: TarotCard; isUpright: boolean } | null>(null);
  const [future, setFuture] = useState<{ card: TarotCard; isUpright: boolean } | null>(null);

  const [revealedCards, setRevealedCards] = useState<{ past: boolean; present: boolean; future: boolean }>({
    past: false,
    present: false,
    future: false,
  });

  const categories = ["感情", "工作", "学业", "财富", "综合"];

  const handleStartDraw = async () => {
    if (!question.trim()) {
      alert("请先输入你想看清的事物，让星澜能聚焦能量。");
      return;
    }

    setIsDrawing(true);
    setReading(null);
    setPast(null);
    setPresent(null);
    setFuture(null);
    setRevealedCards({ past: false, present: false, future: false });

    try {
      const response = await fetch("/api/tarot/holy-triangle", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ question, category }),
      });
      const data = await response.json();

      if (response.ok) {
        // Slow pacing for majestic starry reveal
        setTimeout(() => {
          setPast(data.past);
          setPresent(data.present);
          setFuture(data.future);
          setReading(data.reading);
          setIsDrawing(false);

          // Staggered manual/auto card reveal for high interactive fidelity
          setTimeout(() => setRevealedCards(prev => ({ ...prev, past: true })), 600);
          setTimeout(() => setRevealedCards(prev => ({ ...prev, present: true })), 1400);
          setTimeout(() => setRevealedCards(prev => ({ ...prev, future: true })), 2200);

          // Save to local archives
          onSaveDraw({
            id: `triangle_${Date.now()}`,
            date: new Date().toLocaleDateString("zh-CN", {
              year: "numeric",
              month: "long",
              day: "numeric",
            }),
            type: "圣三角牌阵",
            question,
            cards: [data.past, data.present, data.future],
            reading: data.reading,
          });
        }, 2200);
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      console.error(err);
      setIsDrawing(false);
      // Fallback fallback simulated data
      const shuffled = [...MAJOR_ARCANA].sort(() => 0.5 - Math.random());
      setPast({ card: shuffled[0], isUpright: true });
      setPresent({ card: shuffled[1], isUpright: false });
      setFuture({ card: shuffled[2], isUpright: true });
      setReading({
        introduction: "星空浩渺，即使在无网的状态下，星澜依然守护着你。圣三角牌阵已经浮现。",
        pastReading: `过去（${shuffled[0].name} 正位）：在过去，你的心流处于 ${shuffled[0].upright} 的基调下。这是一段不可磨灭的经历。`,
        presentReading: `现在（${shuffled[1].name} 逆位）：当前你面临着 ${shuffled[1].reversed} 的纠结。请放慢脚步，允许暂时的不完美。`,
        futureReading: `未来（${shuffled[2].name} 正位）：未来的转折在引导你流向 ${shuffled[2].upright}。相信你的直觉，放平心态。`,
        synthesis: "✨ 星澜絮语：一段健康的关系或顺利的追求，都不需要你反复通过内耗来确信。回到爱与呼吸中，星空在为你闪烁。"
      });
      setTimeout(() => setRevealedCards({ past: true, present: true, future: true }), 1000);
    }
  };

  const renderSingleCard = (
    label: string,
    item: { card: TarotCard; isUpright: boolean } | null,
    isRevealed: boolean,
    onRevealToggle: () => void
  ) => {
    return (
      <div className="flex flex-col items-center space-y-2 flex-1">
        <span className="text-[10px] text-slate-400 tracking-wider font-medium uppercase">{label}</span>
        
        <div className="perspective-1000 w-[95px] h-[140px] relative cursor-pointer" onClick={onRevealToggle}>
          <motion.div
            animate={{ rotateY: isRevealed ? 0 : 180 }}
            transition={{ duration: 0.8, ease: "easeOut" }}
            className="w-full h-full duration-1000 transform-style-3d relative"
          >
            {/* Back */}
            <div className="absolute inset-0 backface-hidden bg-slate-900 border border-amber-500/30 rounded-xl flex flex-col justify-between p-2 overflow-hidden bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-indigo-950 via-slate-900 to-slate-950">
              <div className="absolute inset-0 flex items-center justify-center opacity-20">
                <div className="w-16 h-16 border border-amber-500/10 rounded-full" />
                <div className="w-10 h-10 border border-dashed border-amber-500/10 rounded-full absolute" />
              </div>
              <span className="text-[6px] text-amber-500/30 text-center uppercase tracking-widest block">XINGLAN</span>
              <div className="text-amber-400/50 flex justify-center">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M15 7a2 2 0 012 2m-2 4a5 5 0 110-10 5 5 0 010 10z" />
                </svg>
              </div>
              <span className="text-[6px] text-amber-500/30 text-center uppercase tracking-widest block">KEY</span>
            </div>

            {/* Front */}
            {item && (
              <div className="absolute inset-0 backface-hidden transform rotate-y-180 bg-gradient-to-b from-indigo-950 to-slate-950 border border-amber-500/30 rounded-xl p-2 flex flex-col justify-between overflow-hidden shadow-xl">
                <div className="absolute -inset-6 bg-gradient-to-tr from-amber-500/10 to-transparent blur-xl pointer-events-none" />
                
                <div className="flex justify-between items-center text-amber-400/40 text-[7px]">
                  <span>{item.card.id}</span>
                  <span>{item.card.element}</span>
                </div>

                <div className="flex-1 my-1 border border-amber-500/5 rounded-md flex flex-col items-center justify-center p-1 bg-slate-950/60 overflow-hidden relative">
                  <div className="absolute text-amber-400/5 text-4xl font-serif">{item.card.element}</div>
                  <div className={`w-6 h-6 rounded-full flex items-center justify-center bg-gradient-to-br ${item.card.themeColor} bg-opacity-20`}>
                    <Sparkles className="w-3 h-3 text-amber-200/90" />
                  </div>
                </div>

                <div className="text-center">
                  <h5 className="text-[10px] font-medium font-serif text-slate-200 tracking-tight leading-tight truncate">
                    {item.card.name}
                  </h5>
                  <p className="text-[7px] text-amber-400 mt-0.5 leading-none">
                    {item.isUpright ? "正位" : "逆位"}
                  </p>
                </div>
              </div>
            )}
          </motion.div>
        </div>
      </div>
    );
  };

  return (
    <div className="h-full flex flex-col justify-between select-none overflow-y-auto pb-10 text-white">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-950/50 backdrop-blur-md sticky top-0 z-10 bg-slate-950/40">
        <button onClick={onBack} className="p-2 -ml-2 rounded-full hover:bg-slate-900 transition-colors">
          <ChevronLeft className="w-5 h-5 text-slate-300" />
        </button>
        <span className="font-medium text-amber-200 tracking-wide text-base">圣三角牌阵</span>
        <div className="w-9"></div>
      </div>

      <div className="flex-1 px-5 pt-4 space-y-6">
        <AnimatePresence mode="wait">
          {!reading && !isDrawing && (
            <motion.div
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -15 }}
              className="space-y-6"
            >
              {/* Parchment Box */}
              <div className="bg-amber-950/10 border border-amber-500/15 rounded-2xl p-5 space-y-4 relative overflow-hidden bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-indigo-950/30 via-slate-950/80 to-slate-950">
                <div className="absolute top-0 right-0 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl" />
                <div className="flex items-center gap-2">
                  <div className="w-1.5 h-1.5 rounded-full bg-amber-400" />
                  <span className="text-xs text-amber-300 font-medium tracking-wider font-serif">看见一件事的过去、现在与未来</span>
                </div>
                <p className="text-xs text-slate-300 leading-relaxed font-serif pt-1">
                  圣三角是最经典的塔罗牌阵之一，由三张牌组成，分别代表：
                </p>
                <ul className="space-y-2 pl-2">
                  <li className="text-[11px] text-slate-400 flex items-start gap-1.5">
                    <span className="text-amber-500 font-bold">•</span>
                    <span><strong className="text-amber-200">第一张 · 过去</strong> —— 事件的基础，已经发生的影响因素。</span>
                  </li>
                  <li className="text-[11px] text-slate-400 flex items-start gap-1.5">
                    <span className="text-amber-500 font-bold">•</span>
                    <span><strong className="text-amber-200">第二张 · 现在</strong> —— 当前的状态，正在发生的核心阻碍。</span>
                  </li>
                  <li className="text-[11px] text-slate-400 flex items-start gap-1.5">
                    <span className="text-amber-500 font-bold">•</span>
                    <span><strong className="text-amber-200">第三张 · 未来</strong> —— 极可能的发展方向与星空对你的启示。</span>
                  </li>
                </ul>
                <p className="text-[11px] text-slate-400 leading-relaxed italic border-t border-indigo-950/60 pt-3">
                  星澜会帮你展开这三段线索，看到事情的完整脉络，抚平心中的褶皱。
                </p>
              </div>

              {/* Form Input */}
              <div className="space-y-4 bg-slate-950/40 p-4 rounded-xl border border-indigo-950/60">
                <div className="space-y-1.5">
                  <label className="block text-[11px] text-slate-400 font-medium">你想看清哪件事？</label>
                  <input
                    type="text"
                    value={question}
                    onChange={(e) => setQuestion(e.target.value)}
                    placeholder="例如：我想看清最近在感情上卡住的一件事..."
                    className="w-full bg-slate-950/80 border border-indigo-950 rounded-xl px-4 py-3 text-xs text-slate-200 placeholder-slate-600 focus:outline-none focus:border-amber-500/40 focus:ring-1 focus:ring-amber-500/10 transition-all"
                  />
                </div>

                <div className="space-y-1.5">
                  <label className="block text-[11px] text-slate-400 font-medium">选择一个心理场景：</label>
                  <div className="flex flex-wrap gap-2">
                    {categories.map((cat) => (
                      <button
                        key={cat}
                        onClick={() => setCategory(cat)}
                        className={`px-3 py-1.5 rounded-full text-xs font-medium border transition-all ${
                          category === cat
                            ? "bg-amber-400/10 border-amber-400/40 text-amber-300"
                            : "bg-slate-950/60 border-indigo-950/60 text-slate-400 hover:text-slate-300"
                        }`}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Submit Button */}
              <button
                onClick={handleStartDraw}
                disabled={!question.trim()}
                className={`w-full py-3.5 px-4 rounded-xl text-sm font-semibold flex items-center justify-center gap-2 cursor-pointer transition-all duration-300 ${
                  question.trim()
                    ? "bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950 shadow-lg hover:from-amber-400 active:scale-95 shadow-amber-950/20"
                    : "bg-slate-900 border border-indigo-950/60 text-slate-500 cursor-not-allowed"
                }`}
              >
                <Sparkles className="w-4 h-4" />
                开始展开圣三角
              </button>
            </motion.div>
          )}

          {/* Loading Starry State */}
          {isDrawing && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex flex-col items-center justify-center py-20 space-y-8"
            >
              <div className="relative w-44 h-44 flex items-center justify-center">
                {/* Concentric rotating glowing rings */}
                <div className="absolute inset-0 border border-amber-500/10 rounded-full animate-pulse" />
                <div className="absolute inset-3 border border-indigo-500/20 rounded-full animate-spin [animation-duration:6s]" />
                <div className="absolute inset-6 border border-dashed border-amber-500/20 rounded-full animate-spin [animation-duration:10s] [animation-direction:reverse]" />
                
                {/* Holy symbol */}
                <div className="w-0 h-0 border-l-[15px] border-l-transparent border-r-[15px] border-r-transparent border-b-[26px] border-b-amber-300/80 absolute z-10" />
              </div>

              <div className="text-center space-y-2">
                <h4 className="text-base font-serif font-medium text-amber-200 animate-pulse">正在展开圣三角...</h4>
                <p className="text-xs text-slate-400 leading-relaxed max-w-xs mx-auto">
                  “过去奠定土壤，现在映照卡点，未来流淌方向。星澜正为你汇聚宇宙能量之钥。”
                </p>
              </div>
            </motion.div>
          )}

          {/* Result Presentation */}
          {reading && past && present && future && !isDrawing && (
            <motion.div
              initial={{ opacity: 0, scale: 0.98 }}
              animate={{ opacity: 1, scale: 1 }}
              className="space-y-6 pb-6"
            >
              {/* Title Header */}
              <div className="text-center space-y-1">
                <h4 className="text-xs text-amber-400 font-mono tracking-widest font-semibold">HOLY TRIANGLE SPREAD</h4>
                <h3 className="text-lg font-serif font-medium text-slate-200">正在解读圣三角</h3>
              </div>

              {/* Cards Row */}
              <div className="flex justify-between gap-2 bg-slate-950/30 p-3 rounded-2xl border border-indigo-950/40 backdrop-blur-sm">
                {renderSingleCard("过去 (Past)", past, revealedCards.past, () =>
                  setRevealedCards((prev) => ({ ...prev, past: !prev.past }))
                )}
                {renderSingleCard("现在 (Present)", present, revealedCards.present, () =>
                  setRevealedCards((prev) => ({ ...prev, present: !prev.present }))
                )}
                {renderSingleCard("未来 (Future)", future, revealedCards.future, () =>
                  setRevealedCards((prev) => ({ ...prev, future: !prev.future }))
                )}
              </div>

              {/* Introduction Text */}
              <AnimatePresence>
                {reading.introduction && (
                  <motion.p
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    className="text-xs text-slate-400 leading-relaxed italic px-2 text-center"
                  >
                    {reading.introduction}
                  </motion.p>
                )}
              </AnimatePresence>

              {/* Staggered text readouts */}
              <div className="space-y-4">
                {/* Past Interpretation */}
                <div className="bg-slate-950/50 rounded-xl p-4 border border-indigo-950/60 space-y-1.5">
                  <div className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-slate-400" />
                    <span className="text-xs text-amber-300 font-medium">过去 · {past.card.name}</span>
                  </div>
                  <p className="text-xs text-slate-300 leading-relaxed font-light">
                    {reading.pastReading || "正在汇聚记忆溪流..."}
                  </p>
                </div>

                {/* Present Interpretation */}
                <div className="bg-slate-950/50 rounded-xl p-4 border border-indigo-950/60 space-y-1.5">
                  <div className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-amber-400 animate-ping" />
                    <span className="text-xs text-amber-300 font-medium">现在 · {present.card.name}</span>
                  </div>
                  <p className="text-xs text-slate-300 leading-relaxed font-light">
                    {reading.presentReading || "正在译解当前重阻..."}
                  </p>
                </div>

                {/* Future Interpretation */}
                <div className="bg-slate-950/50 rounded-xl p-4 border border-indigo-950/60 space-y-1.5">
                  <div className="flex items-center gap-1.5">
                    <span className="w-1.5 h-1.5 rounded-full bg-blue-400" />
                    <span className="text-xs text-amber-300 font-medium">未来 · {future.card.name}</span>
                  </div>
                  <p className="text-xs text-slate-300 leading-relaxed font-light">
                    {reading.futureReading || "正在望向明天旅程..."}
                  </p>
                </div>

                {/* Unified Synthesis Golden Box */}
                {reading.synthesis && (
                  <div className="bg-[radial-gradient(ellipse_at_bottom,_var(--tw-gradient-stops))] from-amber-950/20 via-slate-900/60 to-slate-950/80 border border-amber-500/20 rounded-xl p-5 shadow-lg relative overflow-hidden text-center space-y-3">
                    <span className="text-xs text-amber-400 font-medium font-mono uppercase tracking-wider block">✦ 星澜絮语 ✦</span>
                    <p className="text-sm font-medium text-amber-200 leading-relaxed italic font-serif">
                      “{reading.synthesis.replace(/✨\s*星澜絮语[:：]*/, "").trim()}”
                    </p>
                  </div>
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 pt-2">
                <button
                  onClick={onBack}
                  className="flex-1 bg-slate-900 border border-indigo-950 text-slate-300 text-xs py-3 px-4 rounded-xl flex items-center justify-center hover:text-white transition-colors"
                >
                  返回首页
                </button>
                <button
                  onClick={handleStartDraw}
                  className="flex-1 bg-amber-400/10 border border-amber-400/30 text-amber-200 text-xs py-3 px-4 rounded-xl flex items-center justify-center gap-2 hover:bg-amber-400/20 transition-colors"
                >
                  <RefreshCw className="w-3.5 h-3.5" />
                  重新占卜
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
