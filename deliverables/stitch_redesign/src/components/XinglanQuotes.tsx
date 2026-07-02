import React, { useState, useEffect } from "react";
import { Sparkles, HelpCircle, Moon, RefreshCw, Star } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";

interface Particle {
  id: number;
  x: number;
  y: number;
  size: number;
}

export default function XinglanQuotes() {
  const [quote, setQuote] = useState("今天，也给自己留一张星钥吧。不问未来，只看看此时的你。");
  const [isLoading, setIsLoading] = useState(false);
  const [particles, setParticles] = useState<Particle[]>([]);

  const fetchNewQuote = async () => {
    setIsLoading(true);
    try {
      const response = await fetch("/api/tarot/quote");
      const data = await response.json();
      if (response.ok) {
        setQuote(data.quote);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleScreenClick = (e: React.MouseEvent<HTMLDivElement>) => {
    // Generate sparkle particles at cursor coordinates
    const rect = e.currentTarget.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const clickY = e.clientY - rect.top;

    const newParticles = Array.from({ length: 8 }).map((_, idx) => ({
      id: Date.now() + idx,
      x: clickX + (Math.random() - 0.5) * 60,
      y: clickY + (Math.random() - 0.5) * 60,
      size: Math.random() * 8 + 4,
    }));

    setParticles((prev) => [...prev, ...newParticles].slice(-40)); // keep limit
    fetchNewQuote();
  };

  // Auto clean particles
  useEffect(() => {
    if (particles.length > 0) {
      const timer = setTimeout(() => {
        setParticles([]);
      }, 1500);
      return () => clearTimeout(timer);
    }
  }, [particles]);

  return (
    <div
      onClick={handleScreenClick}
      className="h-full relative overflow-hidden flex flex-col justify-between select-none cursor-pointer text-white bg-slate-950"
    >
      {/* Background portrait of Xinglan goddess */}
      <div className="absolute inset-0">
        <img
          src="/src/assets/images/xinglan_goddess_1782918266274.jpg"
          alt="Goddess Xinglan"
          referrerPolicy="no-referrer"
          className="w-full h-full object-cover opacity-80"
          onError={(e) => {
            // Fallback to high quality CSS dark celestial background if image fails to load
            const target = e.currentTarget;
            target.style.display = 'none';
          }}
        />
        {/* Soft atmospheric gradient masks */}
        <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/40 to-slate-950/60" />
      </div>

      {/* Float sparkles / particles */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden z-20">
        <AnimatePresence>
          {particles.map((p) => (
            <motion.div
              key={p.id}
              initial={{ opacity: 1, scale: 0.5, y: p.y }}
              animate={{ opacity: 0, scale: 1.5, y: p.y - 40, x: p.x + (Math.random() - 0.5) * 30 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 1.2, ease: "easeOut" }}
              style={{
                position: "absolute",
                left: p.x,
                width: p.size,
                height: p.size,
              }}
              className="text-amber-300"
            >
              <Star className="w-full h-full fill-current" />
            </motion.div>
          ))}
        </AnimatePresence>
      </div>

      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-950/20 backdrop-blur-sm sticky top-0 z-10 bg-slate-950/10">
        <div className="w-8" />
        <span className="font-serif font-medium text-amber-200 tracking-wider text-base">星澜语录</span>
        <div className="w-8" />
      </div>

      {/* Quote bubble (Golden box in center) */}
      <div className="flex-1 flex items-center justify-center px-6 z-10">
        <AnimatePresence mode="wait">
          <motion.div
            key={quote}
            initial={{ opacity: 0, scale: 0.96, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.96, y: -10 }}
            transition={{ duration: 0.6 }}
            className="w-full bg-slate-950/60 border border-amber-500/20 rounded-2xl p-6 shadow-2xl backdrop-blur-md relative overflow-hidden"
          >
            {/* Corner Decor */}
            <div className="absolute top-2 left-2 w-2.5 h-2.5 border-t border-l border-amber-500/40" />
            <div className="absolute top-2 right-2 w-2.5 h-2.5 border-t border-r border-amber-500/40" />
            <div className="absolute bottom-2 left-2 w-2.5 h-2.5 border-b border-l border-amber-500/40" />
            <div className="absolute bottom-2 right-2 w-2.5 h-2.5 border-b border-r border-amber-500/40" />

            {/* Inner Glow */}
            <div className="absolute -top-12 -right-12 w-24 h-24 bg-amber-400/5 rounded-full blur-2xl" />

            <div className="space-y-4">
              <div className="flex justify-center">
                <Star className="w-4 h-4 text-amber-300/60 animate-pulse" />
              </div>
              
              <p className="text-sm font-serif font-medium text-slate-100 text-center leading-relaxed whitespace-pre-line tracking-wide">
                {isLoading ? "正在倾听星轨的私语..." : quote}
              </p>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Bottom hint */}
      <div className="p-6 text-center space-y-2 z-10">
        <div className="flex items-center justify-center gap-1 text-xs text-slate-400 font-serif">
          <Sparkles className="w-3.5 h-3.5 text-amber-400 animate-pulse" />
          <span>轻轻触摸屏幕，星澜会回应你</span>
        </div>
        <p className="text-[10px] text-slate-500 tracking-wider">
          结果仅供娱乐与自我探索参考，不构成任何专业建议。
        </p>
      </div>
    </div>
  );
}
