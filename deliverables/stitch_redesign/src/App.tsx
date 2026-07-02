import React, { useState, useEffect } from "react";
import { Hexagon, Moon, Sparkles, BookOpen, User, Diamond, Triangle, Disc, Star, List, ChevronRight } from "lucide-react";
import DailyDraw from "./components/DailyDraw";
import HolyTriangle from "./components/HolyTriangle";
import CardWheel from "./components/CardWheel";
import XinglanChat from "./components/XinglanChat";
import XinglanQuotes from "./components/XinglanQuotes";
import HistoryArchive from "./components/HistoryArchive";
import UserProfile from "./components/UserProfile";
import { TarotCard } from "./tarotData";
import { motion, AnimatePresence } from "motion/react";

interface SavedDraw {
  id: string;
  date: string;
  type: string;
  cards: { card: TarotCard; isUpright: boolean }[];
  reading: any;
  question: string;
}

export default function App() {
  const [currentTab, setCurrentTab] = useState<"tarot" | "chat" | "quotes" | "overview" | "me">("tarot");
  const [tarotSubView, setTarotSubView] = useState<"main" | "daily" | "triangle" | "wheel">("main");
  const [history, setHistory] = useState<SavedDraw[]>([]);

  // Load history from localStorage on startup
  useEffect(() => {
    const saved = localStorage.getItem("xinglan_tarot_history");
    if (saved) {
      try {
        setHistory(JSON.parse(saved));
      } catch (err) {
        console.error(err);
      }
    }
  }, []);

  const handleSaveDraw = (newDraw: SavedDraw) => {
    setHistory((prev) => {
      const updated = [newDraw, ...prev];
      localStorage.setItem("xinglan_tarot_history", JSON.stringify(updated));
      return updated;
    });
  };

  const handleClearHistory = () => {
    setHistory([]);
    localStorage.removeItem("xinglan_tarot_history");
  };

  const renderTarotMainList = () => {
    const menuItems = [
      {
        id: "daily",
        title: "每日一占",
        desc: "一句心事，一张星钥。",
        icon: <Diamond className="w-5 h-5 text-amber-300" />,
        action: () => setTarotSubView("daily")
      },
      {
        id: "triangle",
        title: "圣三角牌阵",
        desc: "过去、现在、可能的方向。",
        icon: <Triangle className="w-5 h-5 text-blue-300" />,
        action: () => setTarotSubView("triangle")
      },
      {
        id: "wheel",
        title: "旋转牌轮",
        desc: "亲手转动牌轮，选择此刻靠近你的牌。",
        icon: <Star className="w-5 h-5 text-purple-300" />,
        action: () => setTarotSubView("wheel")
      },
      {
        id: "history",
        title: "历史查看",
        desc: "回看曾经抽到的星钥和那时的自己。",
        icon: <List className="w-5 h-5 text-slate-300" />,
        action: () => setCurrentTab("overview")
      }
    ];

    return (
      <div className="space-y-6 px-4 pt-6 select-none text-white pb-10">
        {/* Divine Greeting Header */}
        <div className="text-center space-y-2 py-4">
          <motion.h1
            initial={{ opacity: 0, y: -5 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl font-serif font-semibold tracking-wider text-transparent bg-clip-text bg-gradient-to-b from-amber-100 via-amber-200 to-yellow-500"
          >
            占 卜
          </motion.h1>
          <p className="text-xs text-slate-400 font-light max-w-xs mx-auto">
            用一张牌、一组牌阵，轻轻照见此刻的心事。
          </p>
        </div>

        {/* Menu Items */}
        <div className="space-y-4">
          {menuItems.map((item, index) => (
            <motion.div
              key={item.id}
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
              onClick={item.action}
              className="bg-gradient-to-r from-slate-900/80 to-indigo-950/40 border border-indigo-950/80 hover:border-amber-500/20 rounded-2xl p-4 flex items-center justify-between cursor-pointer transition-all duration-300 group shadow-lg active:scale-98"
            >
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-slate-950/80 border border-indigo-900/40 flex items-center justify-center group-hover:scale-105 transition-transform shadow-inner">
                  {item.icon}
                </div>
                <div className="space-y-1">
                  <h3 className="text-sm font-semibold tracking-wide text-slate-100 group-hover:text-amber-200 transition-colors">
                    {item.title}
                  </h3>
                  <p className="text-[11px] text-slate-400 font-light">
                    {item.desc}
                  </p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-slate-500 group-hover:text-slate-300 group-hover:translate-x-0.5 transition-all" />
            </motion.div>
          ))}
        </div>

        {/* Warning text (Matches layout 10) */}
        <p className="text-[10px] text-slate-500 text-center pt-8 tracking-wide">
          结果仅供娱乐与自我探索参考，不构成任何专业建议。
        </p>
      </div>
    );
  };

  const renderActiveView = () => {
    switch (currentTab) {
      case "tarot":
        switch (tarotSubView) {
          case "daily":
            return <DailyDraw onBack={() => setTarotSubView("main")} onSaveDraw={handleSaveDraw} />;
          case "triangle":
            return <HolyTriangle onBack={() => setTarotSubView("main")} onSaveDraw={handleSaveDraw} />;
          case "wheel":
            return <CardWheel onBack={() => setTarotSubView("main")} onSaveDraw={handleSaveDraw} />;
          default:
            return renderTarotMainList();
        }
      case "chat":
        return <XinglanChat />;
      case "quotes":
        return <XinglanQuotes />;
      case "overview":
        return <HistoryArchive history={history} onClearHistory={handleClearHistory} />;
      case "me":
        return <UserProfile history={history} userEmail="anyes114514@gmail.com" />;
      default:
        return renderTarotMainList();
    }
  };

  return (
    <div className="min-h-screen bg-[#02050e] font-sans antialiased text-slate-200 flex items-center justify-center py-0 sm:py-6 relative overflow-hidden bg-[radial-gradient(ellipse_at_top,_var(--tw-gradient-stops))] from-indigo-950 via-[#030612] to-[#010206]">
      {/* Dynamic Starry Sky Background Layer (CSS Floating Stars) */}
      <div className="absolute inset-0 pointer-events-none z-0">
        <div className="stars-layer" />
        <div className="twinkling" />
      </div>

      {/* Main viewport Container (Simulating high fidelity premium frame or mobile bounds) */}
      <div className="w-full max-w-md h-screen sm:h-[820px] bg-[#030612]/95 border-0 sm:border border-indigo-950/60 rounded-none sm:rounded-[36px] shadow-2xl relative flex flex-col justify-between overflow-hidden z-10 backdrop-blur-md">
        
        {/* Content Box */}
        <div className="flex-1 overflow-hidden relative">
          {renderActiveView()}
        </div>

        {/* Navigation Tab Bar (Bottom) */}
        <div className="bg-slate-950/80 border-t border-indigo-950/40 py-2.5 px-4 backdrop-blur-md sticky bottom-0 z-30 flex justify-between items-center select-none shadow-xl">
          {[
            { id: "tarot", label: "塔罗", icon: <Hexagon className="w-5 h-5" /> },
            { id: "chat", label: "星澜聊天", icon: <Moon className="w-5 h-5" /> },
            { id: "quotes", label: "星澜语录", icon: <Sparkles className="w-5 h-5" /> },
            { id: "overview", label: "卡牌总览", icon: <BookOpen className="w-5 h-5" /> },
            { id: "me", label: "我的", icon: <User className="w-5 h-5" /> }
          ].map((tab) => {
            const isActive = currentTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => {
                  setCurrentTab(tab.id as any);
                  setTarotSubView("main");
                }}
                className={`flex flex-col items-center gap-1 cursor-pointer transition-all ${
                  isActive ? "text-amber-300 scale-105" : "text-slate-500 hover:text-slate-300"
                }`}
              >
                {tab.icon}
                <span className="text-[10px] tracking-wide font-medium">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
