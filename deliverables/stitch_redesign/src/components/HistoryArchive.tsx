import React, { useState } from "react";
import { Search, Filter, Calendar, BookOpen, Clock, ChevronRight, X, Sparkles, Star } from "lucide-react";
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

interface HistoryArchiveProps {
  history: SavedDraw[];
  onClearHistory: () => void;
}

export default function HistoryArchive({ history, onClearHistory }: HistoryArchiveProps) {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedType, setSelectedType] = useState("全部");
  const [activeDetail, setActiveDetail] = useState<SavedDraw | null>(null);

  const filterTypes = ["全部", "每日一占", "圣三角牌阵", "旋转牌轮"];

  // Search & Filter algorithm
  const filteredHistory = history.filter((item) => {
    const matchesSearch =
      item.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.cards.some((c) => c.card.name.includes(searchTerm));
    
    const matchesType = selectedType === "全部" || item.type === selectedType;

    return matchesSearch && matchesType;
  });

  return (
    <div className="h-full flex flex-col justify-between overflow-y-auto pb-10 text-white select-none">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-950/50 backdrop-blur-md bg-slate-950/40 sticky top-0 z-10">
        <div className="w-8"></div>
        <span className="font-medium text-amber-200 tracking-wide text-base">历史档案</span>
        {history.length > 0 ? (
          <button
            onClick={() => {
              if (confirm("确定要清空你所有的塔罗星钥记录吗？")) {
                onClearHistory();
              }
            }}
            className="text-[10px] text-red-400 hover:text-red-300 transition-colors"
          >
            清空
          </button>
        ) : (
          <div className="w-8"></div>
        )}
      </div>

      <div className="flex-1 px-4 pt-4 space-y-4">
        {/* Search & Filter bar */}
        <div className="space-y-3">
          <div className="relative flex items-center">
            <Search className="w-3.5 h-3.5 text-slate-500 absolute left-3.5 pointer-events-none" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="搜索卡牌名字或当时心事..."
              className="w-full bg-slate-950/60 border border-indigo-950/60 rounded-xl pl-9 pr-4 py-2.5 text-xs text-slate-200 placeholder-slate-600 focus:outline-none focus:border-amber-500/30 transition-all"
            />
          </div>

          <div className="flex gap-2 overflow-x-auto pb-1">
            {filterTypes.map((t) => (
              <button
                key={t}
                onClick={() => setSelectedType(t)}
                className={`px-3 py-1 rounded-full text-[10px] font-medium border transition-all ${
                  selectedType === t
                    ? "bg-amber-400/10 border-amber-400/40 text-amber-300"
                    : "bg-slate-950/40 border-indigo-950/40 text-slate-500 hover:text-slate-300"
                }`}
              >
                {t}
              </button>
            ))}
          </div>
        </div>

        {/* Archives List */}
        <div className="space-y-3">
          {filteredHistory.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20 text-center space-y-3">
              <BookOpen className="w-8 h-8 text-slate-700 stroke-1" />
              <p className="text-xs text-slate-500 max-w-xs leading-relaxed font-serif">
                还未留下星钥的流光。快去抽一张每日牌，或者开启一次圣三角占卜吧。
              </p>
            </div>
          ) : (
            filteredHistory.map((item) => {
              const mainCard = item.cards[0];
              return (
                <motion.div
                  key={item.id}
                  onClick={() => setActiveDetail(item)}
                  layoutId={item.id}
                  className="bg-gradient-to-r from-slate-900/80 via-slate-950/90 to-slate-950 border border-indigo-950/80 hover:border-amber-500/20 rounded-xl p-3 flex items-center justify-between cursor-pointer transition-all shadow-lg active:scale-98"
                >
                  <div className="flex items-center gap-3">
                    {/* Miniature card art */}
                    <div className="w-10 h-14 rounded-lg bg-indigo-950/40 border border-amber-500/20 flex flex-col items-center justify-center p-1 bg-gradient-to-b from-indigo-950 to-slate-950 shadow-md">
                      <span className="text-[7px] text-amber-500/60 leading-none">{mainCard.card.id}</span>
                      <span className="text-[9px] font-serif font-semibold text-slate-100 mt-1 truncate max-w-full">
                        {mainCard.card.name}
                      </span>
                      <span className="text-[6px] text-amber-400 leading-none mt-0.5">
                        {mainCard.isUpright ? "正" : "逆"}
                      </span>
                    </div>

                    {/* Metadata */}
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="text-[9px] px-1.5 py-0.5 bg-indigo-950 border border-indigo-900/60 text-slate-300 rounded font-serif">
                          {item.type}
                        </span>
                        <span className="text-[10px] text-slate-500 font-mono">{item.date}</span>
                      </div>
                      <p className="text-xs text-slate-300 font-serif font-light max-w-[180px] truncate">
                        {item.question}
                      </p>
                    </div>
                  </div>

                  <ChevronRight className="w-4 h-4 text-slate-600" />
                </motion.div>
              );
            })
          )}
        </div>
      </div>

      {/* Expanded Detail Modal overlay */}
      <AnimatePresence>
        {activeDetail && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-slate-950/90 z-50 overflow-y-auto p-5 flex flex-col justify-between"
          >
            <div className="space-y-6">
              {/* Modal Top */}
              <div className="flex justify-between items-center pb-3 border-b border-indigo-950">
                <span className="text-xs text-amber-400 font-mono tracking-widest">{activeDetail.type}</span>
                <button
                  onClick={() => setActiveDetail(null)}
                  className="p-1.5 rounded-full hover:bg-slate-900 text-slate-400"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>

              {/* Inquiry Details */}
              <div className="space-y-2 bg-slate-950/60 p-4 rounded-xl border border-indigo-950/60">
                <span className="text-[10px] text-slate-500 tracking-wider block font-medium">当时心事</span>
                <p className="text-sm font-serif font-medium text-slate-200">“{activeDetail.question}”</p>
                <div className="flex items-center gap-1.5 text-[10px] text-slate-500 pt-1">
                  <Calendar className="w-3 h-3" />
                  <span>记录于 {activeDetail.date}</span>
                </div>
              </div>

              {/* Drawn Cards Layout */}
              <div className="space-y-2">
                <span className="text-[10px] text-slate-500 tracking-wider block font-medium">共鸣星钥</span>
                <div className="flex flex-wrap gap-3">
                  {activeDetail.cards.map((item, idx) => (
                    <div
                      key={idx}
                      className="flex-1 min-w-[80px] rounded-xl border border-amber-500/20 bg-slate-900 p-2 text-center flex flex-col justify-between h-28 bg-gradient-to-b from-indigo-950 to-slate-950"
                    >
                      <span className="text-[7px] text-slate-500 block uppercase font-mono">{idx === 0 ? "起" : idx === 1 ? "承" : "转"}</span>
                      <div className={`w-6 h-6 rounded-full mx-auto flex items-center justify-center bg-gradient-to-br ${item.card.themeColor} bg-opacity-20`}>
                        <Star className="w-3.5 h-3.5 text-amber-200" />
                      </div>
                      <div>
                        <span className="text-[11px] font-serif font-semibold text-slate-200 block truncate">{item.card.name}</span>
                        <span className="text-[7px] text-amber-400 block">{item.isUpright ? "正位" : "逆位"}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Saved Interpretations scrollbox */}
              <div className="space-y-2">
                <span className="text-[10px] text-slate-500 tracking-wider block font-medium">星澜之言</span>
                <div className="bg-slate-950/80 border border-indigo-950 rounded-xl p-4 text-xs text-slate-300 leading-relaxed whitespace-pre-line max-h-72 overflow-y-auto">
                  {activeDetail.reading.single ? (
                    activeDetail.reading.single
                  ) : (
                    <div className="space-y-4">
                      {activeDetail.reading.pastReading && (
                        <div>
                          <p className="text-amber-300 font-medium pb-0.5">【过去】</p>
                          <p>{activeDetail.reading.pastReading}</p>
                        </div>
                      )}
                      {activeDetail.reading.presentReading && (
                        <div className="pt-2 border-t border-indigo-950/40">
                          <p className="text-amber-300 font-medium pb-0.5">【现在】</p>
                          <p>{activeDetail.reading.presentReading}</p>
                        </div>
                      )}
                      {activeDetail.reading.futureReading && (
                        <div className="pt-2 border-t border-indigo-950/40">
                          <p className="text-amber-300 font-medium pb-0.5">【未来】</p>
                          <p>{activeDetail.reading.futureReading}</p>
                        </div>
                      )}
                      {activeDetail.reading.synthesis && (
                        <div className="pt-3 border-t border-indigo-950 bg-amber-950/10 p-3 rounded-lg text-center font-serif italic text-amber-200">
                          {activeDetail.reading.synthesis}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              </div>
            </div>

            <button
              onClick={() => setActiveDetail(null)}
              className="w-full bg-amber-500 text-slate-950 font-semibold py-3 rounded-xl text-xs mt-6"
            >
              关闭档案
            </button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
