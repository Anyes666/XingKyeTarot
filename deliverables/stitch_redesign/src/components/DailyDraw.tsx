import React, { useState } from "react";
import { Sparkles, Calendar, RefreshCw, Bookmark, ChevronLeft } from "lucide-react";
import { MAJOR_ARCANA, TarotCard } from "../tarotData";
import { motion, AnimatePresence } from "motion/react";

interface DailyDrawProps {
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

export default function DailyDraw({ onBack, onSaveDraw }: DailyDrawProps) {
  const [question, setQuestion] = useState("");
  const [category, setCategory] = useState("综合");
  const [isDrawing, setIsDrawing] = useState(false);
  const [drawnCard, setDrawnCard] = useState<TarotCard | null>(null);
  const [isUpright, setIsUpright] = useState(true);
  const [readingText, setReadingText] = useState("");
  const [isRevealed, setIsRevealed] = useState(false);
  const [showTips, setShowTips] = useState(true);

  const categories = ["感情", "工作", "学业", "财富", "综合"];

  const handleStartDraw = async () => {
    setIsDrawing(true);
    setDrawnCard(null);
    setIsRevealed(false);
    setReadingText("");

    try {
      const response = await fetch("/api/tarot/daily-draw", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ question, category }),
      });
      const data = await response.json();

      if (response.ok) {
        // Slow down for suspenseful starry animation
        setTimeout(() => {
          setDrawnCard(data.card);
          setIsUpright(data.isUpright);
          setReadingText(data.reading);
          setIsDrawing(false);
          // Auto reveal after animation
          setTimeout(() => setIsRevealed(true), 1200);

          // Save to local archives automatically
          onSaveDraw({
            id: `daily_${Date.now()}`,
            date: new Date().toLocaleDateString("zh-CN", {
              year: "numeric",
              month: "long",
              day: "numeric",
            }),
            type: "每日一占",
            question: question || "今日宇宙指引",
            cards: [{ card: data.card, isUpright: data.isUpright }],
            reading: { single: data.reading },
          });
        }, 1800);
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      console.error(err);
      setIsDrawing(false);
      // Fallback
      const fallbackCard = MAJOR_ARCANA[Math.floor(Math.random() * MAJOR_ARCANA.length)];
      const fallbackUpright = Math.random() > 0.2;
      setDrawnCard(fallbackCard);
      setIsUpright(fallbackUpright);
      setReadingText(`✨ 星钥之语：\n「信任」是你今天的生命基调。\n\n星光闪烁，温柔包容你的一切。你抽到了「${fallbackCard.name}」${fallbackUpright ? "正位" : "逆位"}。请回到你的内在，顺应宇宙的流淌。不问未来，只看当下的你，已经足够好。`);
      setTimeout(() => setIsRevealed(true), 1200);
    }
  };

  // Extract sections from text if structured with custom titles
  const renderReadingSections = (text: string) => {
    if (!text) return null;
    
    // Check if Gemini returned standard brackets
    const voiceMatch = text.match(/【星钥之声】([^【]+)/);
    const guideMatch = text.match(/【星光指引】([^【]+)/);
    const whisperMatch = text.match(/【星澜絮语】([^【]+)/);

    if (voiceMatch || guideMatch || whisperMatch) {
      return (
        <div className="space-y-6 text-slate-200">
          {voiceMatch && (
            <div className="bg-slate-900/60 border border-amber-500/20 rounded-xl p-5 text-center shadow-lg backdrop-blur-md">
              <span className="text-xs text-amber-400 font-medium tracking-wider block mb-1">✦ 星钥之声 ✦</span>
              <p className="text-lg font-medium text-amber-200 leading-relaxed italic">
                “{voiceMatch[1].trim().replace(/^[:：\s]+|[:：\s]+$/g, "")}”
              </p>
            </div>
          )}
          {guideMatch && (
            <div className="bg-indigo-950/20 border border-indigo-500/10 rounded-xl p-5 space-y-2">
              <span className="text-xs text-indigo-300 font-medium tracking-wider block">✦ 星光指引 ✦</span>
              <p className="text-sm text-slate-300 leading-relaxed whitespace-pre-line">
                {guideMatch[1].trim().replace(/^[:：\s]+/, "")}
              </p>
            </div>
          )}
          {whisperMatch && (
            <div className="bg-rose-950/10 border border-rose-500/10 rounded-xl p-5 text-center">
              <span className="text-xs text-rose-300 font-medium tracking-wider block mb-1">✦ 星澜之祝 ✦</span>
              <p className="text-sm text-rose-200/90 leading-relaxed italic">
                {whisperMatch[1].trim().replace(/^[:：\s]+/, "")}
              </p>
            </div>
          )}
        </div>
      );
    }

    // Direct rendering with format helpers
    return (
      <div className="bg-slate-950/40 border border-indigo-500/10 rounded-xl p-6 text-slate-300 text-sm leading-relaxed whitespace-pre-line shadow-inner">
        {text}
      </div>
    );
  };

  return (
    <div className="h-full flex flex-col justify-between select-none relative overflow-y-auto pb-8 text-white">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-950/50 backdrop-blur-md sticky top-0 z-10 bg-slate-950/40">
        <button onClick={onBack} className="p-2 -ml-2 rounded-full hover:bg-slate-900 transition-colors">
          <ChevronLeft className="w-5 h-5 text-slate-300" />
        </button>
        <span className="font-medium text-amber-200 tracking-wide text-base">每日一占</span>
        <div className="w-9"></div> {/* spacing balancer */}
      </div>

      <div className="flex-1 px-5 pt-4 space-y-6">
        {/* Intro Parchment */}
        <AnimatePresence mode="wait">
          {!drawnCard && !isDrawing && (
            <motion.div
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -15 }}
              className="bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-amber-950/20 via-slate-900/60 to-slate-950/80 border border-amber-500/10 rounded-2xl p-5 space-y-4 shadow-xl relative overflow-hidden"
            >
              <div className="absolute top-0 right-0 w-32 h-32 bg-amber-500/5 rounded-full blur-3xl pointer-events-none" />
              <div className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-amber-400" />
                <h3 className="font-semibold text-amber-200 text-sm tracking-wider">每日灵性指引</h3>
              </div>
              <p className="text-xs text-slate-400 leading-relaxed">
                每日一占是深度的潜意识连接。闭上双眼，轻缓呼吸三次。在心里默念你的境遇，抽出一张属于你的今日星钥之牌。星澜会在这里，温柔译读属于你此刻的星空语言。
              </p>

              {/* Form Controls */}
              <div className="space-y-3 pt-2">
                <div>
                  <label className="block text-[11px] text-slate-400 mb-1.5 font-medium">选择当前的关注焦点：</label>
                  <div className="flex flex-wrap gap-2">
                    {categories.map((cat) => (
                      <button
                        key={cat}
                        onClick={() => setCategory(cat)}
                        className={`px-3 py-1.5 rounded-full text-xs font-medium border transition-all ${
                          category === cat
                            ? "bg-amber-400/10 border-amber-400/50 text-amber-300 shadow-md shadow-amber-900/20"
                            : "bg-slate-900/40 border-slate-800 text-slate-400 hover:text-slate-200"
                        }`}
                      >
                        {cat}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-[11px] text-slate-400 mb-1.5 font-medium">写下此时最想诉说的事或困惑（选填）：</label>
                  <input
                    type="text"
                    value={question}
                    onChange={(e) => setQuestion(e.target.value)}
                    placeholder="例如：我感觉最近能量很低，需要一些指引……"
                    className="w-full bg-slate-950/60 border border-indigo-950/80 rounded-xl px-4 py-3 text-xs text-slate-200 placeholder-slate-500 focus:outline-none focus:border-amber-500/40 focus:ring-1 focus:ring-amber-500/20 transition-all"
                  />
                </div>
              </div>

              {/* Draw Button */}
              <button
                onClick={handleStartDraw}
                className="w-full mt-4 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 text-sm font-semibold py-3 px-4 rounded-xl shadow-lg hover:shadow-amber-500/10 transition-all duration-300 flex items-center justify-center gap-2 cursor-pointer active:scale-95"
              >
                <Sparkles className="w-4 h-4" />
                闭眼抽牌 · 留取今日星钥
              </button>
            </motion.div>
          )}

          {/* Animating Star Draw */}
          {isDrawing && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="flex flex-col items-center justify-center py-16 space-y-8"
            >
              {/* Starry Rotating Circle */}
              <div className="relative w-40 h-56 flex items-center justify-center">
                <div className="absolute inset-0 border border-amber-500/10 rounded-2xl animate-pulse" />
                <div className="absolute inset-2 border border-indigo-500/20 rounded-xl animate-spin [animation-duration:8s]" />
                <div className="absolute inset-4 border border-dashed border-amber-500/20 rounded-lg animate-spin [animation-duration:12s] [animation-direction:reverse]" />
                
                {/* Simulated Floating Key */}
                <motion.div
                  animate={{ y: [0, -10, 0] }}
                  transition={{ repeat: Infinity, duration: 2, ease: "easeInOut" }}
                  className="z-10 text-amber-300/80"
                >
                  <svg className="w-12 h-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M15 7a2 2 0 012 2m-2 4a5 5 0 110-10 5 5 0 010 10zM19 9h2m-2 2h-2m-3 1v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4a2 2 0 012-2h8m-3 1v1m-2-1v1" />
                  </svg>
                </motion.div>
              </div>

              <div className="text-center space-y-2">
                <h4 className="text-base font-medium text-amber-200 animate-pulse">星澜正在解读...</h4>
                <p className="text-xs text-slate-400 leading-relaxed max-w-xs mx-auto">
                  “深呼吸，将你的意识与今日的主星交汇。尘世的喧嚣正缓缓退去，卡牌正静静浮现。”
                </p>
              </div>
            </motion.div>
          )}

          {/* Dressed card reveal */}
          {drawnCard && !isDrawing && (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="space-y-6"
            >
              {/* Card Container */}
              <div className="flex flex-col items-center">
                <div className="perspective-1000 w-44 h-64 relative cursor-pointer group">
                  <motion.div
                    initial={{ rotateY: 180 }}
                    animate={{ rotateY: isRevealed ? 0 : 180 }}
                    transition={{ duration: 1, ease: "easeOut" }}
                    className="w-full h-full duration-1000 transform-style-3d relative"
                    onClick={() => setIsRevealed(!isRevealed)}
                  >
                    {/* Back of the Card */}
                    <div className="absolute inset-0 backface-hidden bg-slate-900 border-2 border-amber-500/40 rounded-2xl p-4 flex flex-col items-center justify-between overflow-hidden shadow-2xl bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-indigo-950 via-slate-900 to-slate-950">
                      {/* Celestial Circles */}
                      <div className="absolute inset-0 flex items-center justify-center opacity-30">
                        <div className="w-36 h-36 border border-amber-500/20 rounded-full" />
                        <div className="w-24 h-24 border border-indigo-400/20 rounded-full absolute" />
                        <div className="w-16 h-16 border border-dashed border-amber-500/20 rounded-full absolute" />
                      </div>
                      
                      <div className="w-full flex justify-between text-amber-400/30 text-[8px] font-mono">
                        <span>IX</span>
                        <span>XINGLAN</span>
                      </div>
                      
                      <div className="z-10 text-amber-300">
                        {/* Golden Key Icon */}
                        <svg className="w-10 h-10 mx-auto opacity-80" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M15 7a2 2 0 012 2m-2 4a5 5 0 110-10 5 5 0 010 10zM19 9h2m-2 2h-2m-3 1v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4a2 2 0 012-2h8m-3 1v1m-2-1v1" />
                        </svg>
                      </div>

                      <div className="w-full flex justify-between text-amber-400/30 text-[8px] font-mono">
                        <span>XINGLAN</span>
                        <span>IX</span>
                      </div>
                    </div>

                    {/* Front of the Card */}
                    <div className="absolute inset-0 backface-hidden transform rotate-y-180 bg-gradient-to-b from-indigo-950 via-slate-900 to-slate-950 border-2 border-amber-500/40 rounded-2xl p-3 flex flex-col justify-between overflow-hidden shadow-2xl">
                      {/* Glowing Element Back */}
                      <div className={`absolute -inset-10 bg-gradient-to-tr ${drawnCard.themeColor} opacity-10 blur-2xl pointer-events-none`} />

                      {/* Top border decor */}
                      <div className="flex justify-between items-center text-amber-300/60 text-[9px] tracking-widest font-serif">
                        <span>{drawnCard.id}</span>
                        <span>{drawnCard.element}</span>
                      </div>

                      {/* Card Illustration placeholder (High design SVG layout) */}
                      <div className="flex-1 my-2 border border-amber-500/10 rounded-lg flex flex-col items-center justify-center p-2 relative bg-slate-950/60 overflow-hidden">
                        {/* Dynamic Sun/Moon/Star pattern based on element */}
                        <div className="absolute text-amber-300/5 select-none text-[80px] font-serif pointer-events-none">
                          {drawnCard.element}
                        </div>
                        
                        <div className="z-10 text-center space-y-1.5">
                          {/* Beautiful central glyph representing card */}
                          <div className={`mx-auto w-10 h-10 rounded-full flex items-center justify-center bg-gradient-to-br ${drawnCard.themeColor} bg-opacity-20 shadow-lg`}>
                            <Sparkles className="w-5 h-5 text-amber-200" />
                          </div>
                          <span className="text-[10px] text-slate-400 block font-mono uppercase tracking-widest">{drawnCard.englishName}</span>
                        </div>
                      </div>

                      {/* Bottom border decor */}
                      <div className="text-center">
                        <h4 className="text-sm font-semibold text-amber-100 tracking-wider font-serif">{drawnCard.name}</h4>
                        <p className="text-[9px] text-amber-400/80 font-medium tracking-wide mt-0.5">
                          {isUpright ? "正位" : "逆位"}
                        </p>
                      </div>
                    </div>
                  </motion.div>
                </div>

                {/* Sub title details */}
                <AnimatePresence>
                  {isRevealed && (
                    <motion.div
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="text-center mt-4 space-y-1"
                    >
                      <h3 className="text-base font-serif font-medium text-amber-200">
                        {drawnCard.name} · {isUpright ? "正位" : "逆位"}
                      </h3>
                      <p className="text-xs text-slate-400 max-w-xs px-4">
                        关键词：{isUpright ? drawnCard.upright : drawnCard.reversed}
                      </p>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>

              {/* Interpretation Parchment */}
              {isRevealed && readingText && (
                <motion.div
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.2 }}
                  className="space-y-5"
                >
                  {renderReadingSections(readingText)}

                  {/* Actions */}
                  <div className="flex gap-3 pt-2">
                    <button
                      onClick={onBack}
                      className="flex-1 bg-slate-900 border border-indigo-950 text-slate-300 text-xs py-3 px-4 rounded-xl flex items-center justify-center gap-2 hover:text-white transition-colors"
                    >
                      返回首页
                    </button>
                    <button
                      onClick={handleStartDraw}
                      className="flex-1 bg-amber-400/10 border border-amber-400/30 text-amber-200 text-xs py-3 px-4 rounded-xl flex items-center justify-center gap-2 hover:bg-amber-400/20 transition-colors"
                    >
                      <RefreshCw className="w-3.5 h-3.5" />
                      再次占卜
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
