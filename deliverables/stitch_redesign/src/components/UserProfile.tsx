import React, { useState, useEffect } from "react";
import { User, Shield, BookOpen, Compass, Sparkles, Award, Star, Zap } from "lucide-react";
import { TarotCard } from "../tarotData";
import { motion, AnimatePresence } from "motion/react";

interface SavedDraw {
  id: string;
  date: string;
  type: string;
  cards: { card: TarotCard; isUpright: boolean }[];
  reading: any;
  question: string;
}

interface UserProfileProps {
  history: SavedDraw[];
  userEmail?: string;
}

export default function UserProfile({ history, userEmail = "未命名旅者" }: UserProfileProps) {
  const [isCheckedIn, setIsCheckedIn] = useState(false);
  const [showCheckInAnim, setShowCheckInAnim] = useState(false);
  const [totalUnlocked, setTotalUnlocked] = useState(0);
  const [dominantElement, setDominantElement] = useState<string>("未知");
  const [elementIntro, setElementIntro] = useState<string>("需要占卜后解锁您的主星属性。");

  useEffect(() => {
    // Calculate unique unlocked cards count
    const uniqueIds = new Set<number>();
    const elementCounts: { [key: string]: number } = { 风: 0, 水: 0, 火: 0, 土: 0 };

    history.forEach((item) => {
      item.cards.forEach((c) => {
        uniqueIds.add(c.card.id);
        elementCounts[c.card.element] = (elementCounts[c.card.element] || 0) + 1;
      });
    });

    setTotalUnlocked(uniqueIds.size);

    // Find dominant element
    let maxCount = 0;
    let maxElement = "风";
    let hasDrawn = false;

    Object.entries(elementCounts).forEach(([element, count]) => {
      if (count > 0) hasDrawn = true;
      if (count > maxCount) {
        maxCount = count;
        maxElement = element;
      }
    });

    if (hasDrawn) {
      setDominantElement(maxElement);
      const elementIntros: { [key: string]: string } = {
        风: "【风元素 · 自由与心流】代表敏捷的智力、出色的沟通力与清新的洞察。你习惯抽离情绪、用客观理智去解构生活。",
        水: "【水元素 · 直觉与悲悯】代表深邃的情感、灵性的感知与强大的疗愈。你在情感中极为细腻，易与宇宙潜意识共鸣。",
        火: "【火元素 · 意志与光热】代表澎湃的生命力、坚定的行动力与追求。你有一颗热忱的心，面对逆境总能爆发出重生的勇气。",
        土: "【土元素 · 稳固与丰盈】代表踏实的耐心、可靠的契约与物质显化。你信任大地的力量，习惯在井然秩序中播种希望。"
      };
      setElementIntro(elementIntros[maxElement]);
    } else {
      setDominantElement("未感应");
      setElementIntro("你在星澜还未留下一占。进行至少一次牌轮或占卜后，星澜能精准感应你的本命星轨元素。");
    }
  }, [history]);

  const handleCheckIn = () => {
    setIsCheckedIn(true);
    setShowCheckInAnim(true);
    setTimeout(() => {
      setShowCheckInAnim(false);
    }, 2000);
  };

  return (
    <div className="h-full flex flex-col justify-between overflow-y-auto pb-10 text-white select-none relative">
      {/* Dynamic check-in starry overlay */}
      <AnimatePresence>
        {showCheckInAnim && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 bg-slate-950/90 z-40 flex flex-col items-center justify-center space-y-4"
          >
            <motion.div
              animate={{ rotate: 360, scale: [1, 1.2, 1] }}
              transition={{ duration: 1.5, ease: "easeInOut" }}
              className="w-16 h-16 rounded-full bg-gradient-to-tr from-amber-400 to-yellow-600 flex items-center justify-center shadow-lg shadow-amber-500/20 text-slate-950"
            >
              <Star className="w-8 h-8 fill-current" />
            </motion.div>
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="text-center space-y-1.5"
            >
              <h4 className="text-sm font-serif font-semibold text-amber-200">签到成功 · 获赠星钥匙</h4>
              <p className="text-xs text-slate-400 max-w-xs px-6">
                “今天的星能之门已为你开启。不问未来，只看此时，愿温和的流光常伴你左右。”
              </p>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Header */}
      <div className="px-4 py-3 border-b border-indigo-950/50 backdrop-blur-md bg-slate-950/40 text-center sticky top-0 z-10">
        <span className="font-medium text-amber-200 tracking-wide text-base">我的星能</span>
      </div>

      <div className="flex-1 px-5 pt-6 space-y-6">
        {/* User Card */}
        <div className="bg-gradient-to-r from-slate-900/80 to-indigo-950/40 border border-indigo-950/80 rounded-2xl p-5 flex items-center justify-between relative overflow-hidden shadow-xl">
          <div className="absolute top-0 right-0 w-24 h-24 bg-amber-500/5 rounded-full blur-2xl" />
          
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 rounded-full border border-amber-500/30 bg-slate-950/80 flex items-center justify-center text-slate-400">
              <User className="w-6 h-6 text-amber-300/80" />
            </div>
            
            <div className="space-y-1">
              <h3 className="text-sm font-semibold tracking-wide text-slate-100">{userEmail.split("@")[0]}</h3>
              <p className="text-[10px] text-slate-500 font-mono">{userEmail}</p>
            </div>
          </div>

          <button
            onClick={handleCheckIn}
            disabled={isCheckedIn}
            className={`px-3 py-1.5 rounded-full text-[10px] font-medium border cursor-pointer transition-all ${
              isCheckedIn
                ? "bg-slate-950 border-indigo-950/60 text-slate-500 cursor-not-allowed"
                : "bg-amber-400/10 border-amber-400/30 text-amber-200 hover:bg-amber-400/20 active:scale-95"
            }`}
          >
            {isCheckedIn ? "已签到" : "每日签到"}
          </button>
        </div>

        {/* Dashboard Stats (Bento style) */}
        <div className="grid grid-cols-2 gap-3">
          <div className="bg-slate-950/40 rounded-xl p-4 border border-indigo-950/60 space-y-1">
            <span className="text-[10px] text-slate-500 tracking-wider font-medium uppercase block">占卜天数</span>
            <div className="flex items-baseline gap-1">
              <span className="text-xl font-serif font-bold text-amber-200">{history.length}</span>
              <span className="text-[9px] text-slate-400">天</span>
            </div>
          </div>

          <div className="bg-slate-950/40 rounded-xl p-4 border border-indigo-950/60 space-y-1">
            <span className="text-[10px] text-slate-500 tracking-wider font-medium uppercase block">解锁星钥</span>
            <div className="flex items-baseline gap-1">
              <span className="text-xl font-serif font-bold text-amber-200">{totalUnlocked}</span>
              <span className="text-[9px] text-slate-400">/ 22</span>
            </div>
          </div>
        </div>

        {/* Dynamic Elemental Report */}
        <div className="bg-amber-950/10 border border-amber-500/15 rounded-2xl p-5 space-y-3 relative overflow-hidden bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-indigo-950/30 via-slate-950/80 to-slate-950 shadow-lg">
          <div className="absolute top-0 right-0 w-20 h-20 bg-amber-500/5 rounded-full blur-2xl" />
          <div className="flex items-center gap-2">
            <Zap className="w-4 h-4 text-amber-400" />
            <span className="text-xs text-amber-300 font-medium tracking-wider font-serif">主星属性：{dominantElement}</span>
          </div>
          <p className="text-[11px] text-slate-300 leading-relaxed font-serif pt-1">
            {elementIntro}
          </p>
        </div>

        {/* Level Accomplishments */}
        <div className="bg-slate-950/40 border border-indigo-950 rounded-2xl p-5 space-y-3">
          <span className="text-[10px] text-slate-500 tracking-wider font-medium uppercase block">旅人成就</span>
          
          <div className="space-y-3.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-indigo-950/30 border border-indigo-900/60 flex items-center justify-center text-slate-400">
                  <Award className="w-4 h-4 text-amber-400/80" />
                </div>
                <div className="space-y-0.5">
                  <h4 className="text-xs text-slate-200 font-medium font-serif">启程旅者</h4>
                  <p className="text-[9px] text-slate-500">第一次进行塔罗灵性解读</p>
                </div>
              </div>
              <span className="text-[10px] text-amber-400 font-serif font-medium">{history.length >= 1 ? "已达成" : "待解锁"}</span>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-lg bg-indigo-950/30 border border-indigo-900/60 flex items-center justify-center text-slate-400">
                  <Compass className="w-4 h-4 text-indigo-400/80" />
                </div>
                <div className="space-y-0.5">
                  <h4 className="text-xs text-slate-200 font-medium font-serif">星轨见证者</h4>
                  <p className="text-[9px] text-slate-500">解锁至少5张不同的主阿卡纳星钥</p>
                </div>
              </div>
              <span className="text-[10px] text-amber-400 font-serif font-medium">{totalUnlocked >= 5 ? "已达成" : "待解锁"}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
