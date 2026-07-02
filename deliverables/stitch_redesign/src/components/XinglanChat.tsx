import React, { useState, useRef, useEffect } from "react";
import { Send, HeartCrack, Heart, CloudMoon, RefreshCw, Battery, Smile, Compass, Moon } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";

interface Message {
  id: string;
  role: "user" | "assistant";
  content: string;
}

export default function XinglanChat() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "welcome",
      role: "assistant",
      content: "未命名旅者，你是不是有时候觉得话卡在喉咙里？没关系，星澜可以等。哪怕只说出一个词，也很勇敢。"
    }
  ]);
  const [inputValue, setInputValue] = useState("");
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const predefinedPrompts = [
    {
      text: "他/她忽冷忽热，我很内耗",
      icon: <HeartCrack className="w-4 h-4 text-red-400" />
    },
    {
      text: "我想知道这段关系值不值得",
      icon: <Heart className="w-4 h-4 text-pink-400" />
    },
    {
      text: "我最近工作很累，想逃离",
      icon: <CloudMoon className="w-4 h-4 text-slate-400" />
    },
    {
      text: "我正在纠结一个重大选择",
      icon: <Compass className="w-4 h-4 text-blue-400" />
    },
    {
      text: "我感觉自己最近能量很低",
      icon: <Battery className="w-4 h-4 text-emerald-400" />
    },
    {
      text: "我只是想安静被安慰一下",
      icon: <Smile className="w-4 h-4 text-amber-400" />
    }
  ];

  // Auto-scroll to bottom of conversation
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, isTyping]);

  const handleSendMessage = async (text: string) => {
    if (!text.trim()) return;

    const userMsg: Message = {
      id: `user_${Date.now()}`,
      role: "user",
      content: text
    };

    setMessages((prev) => [...prev, userMsg]);
    setInputValue("");
    setIsTyping(true);

    try {
      // Package conversation log
      const payload = [...messages, userMsg].map((m) => ({
        role: m.role,
        content: m.content
      }));

      const response = await fetch("/api/tarot/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ messages: payload })
      });
      const data = await response.json();

      setIsTyping(false);
      if (response.ok) {
        setMessages((prev) => [
          ...prev,
          {
            id: `bot_${Date.now()}`,
            role: "assistant",
            content: data.reply
          }
        ]);
      } else {
        throw new Error();
      }
    } catch (err) {
      setIsTyping(false);
      setMessages((prev) => [
        ...prev,
        {
          id: `bot_${Date.now()}`,
          role: "assistant",
          content: "星光有些飘忽，星澜刚才走神了。好孩子，深呼吸，你能再对我说一次吗？"
        }
      ]);
    }
  };

  const handleClearHistory = () => {
    if (confirm("确定要清空与星澜的心灵倾诉记录吗？")) {
      setMessages([
        {
          id: "welcome",
          role: "assistant",
          content: "亲爱的，我们又回到了寂静的夜空。说吧，星澜正枕着清风，静静听着。"
        }
      ]);
    }
  };

  return (
    <div className="h-full flex flex-col justify-between bg-slate-950/20 text-white select-none">
      {/* Top Bar */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-indigo-950/50 backdrop-blur-md bg-slate-950/40 sticky top-0 z-10">
        <div className="w-8"></div>
        <div className="flex items-center gap-1.5">
          <Moon className="w-4 h-4 text-amber-300 animate-pulse" />
          <span className="font-medium text-amber-200 tracking-wide text-base">星澜聊天</span>
        </div>
        <button
          onClick={handleClearHistory}
          className="p-1.5 rounded-full hover:bg-slate-900/60 text-slate-400 hover:text-slate-200 transition-colors"
          title="清空对话"
        >
          <RefreshCw className="w-3.5 h-3.5" />
        </button>
      </div>

      {/* Main Conversation Area */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        <AnimatePresence initial={false}>
          {messages.map((msg) => {
            const isBot = msg.role === "assistant";
            return (
              <motion.div
                key={msg.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className={`flex ${isBot ? "justify-start" : "justify-end"}`}
              >
                {isBot && (
                  <div className="w-8 h-8 rounded-full bg-slate-900 border border-amber-500/30 flex items-center justify-center mr-2 text-[10px] text-amber-300 shrink-0 shadow-lg font-serif">
                    澜
                  </div>
                )}
                
                <div
                  className={`max-w-[80%] rounded-2xl px-4 py-3 text-xs leading-relaxed shadow-lg ${
                    isBot
                      ? "bg-gradient-to-br from-indigo-950/60 to-slate-900/90 border border-indigo-950/80 text-slate-200"
                      : "bg-gradient-to-l from-blue-600 to-indigo-700 text-white border border-blue-500/30 rounded-tr-none"
                  }`}
                >
                  <p className="whitespace-pre-line font-light">{msg.content}</p>
                </div>
              </motion.div>
            );
          })}

          {isTyping && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              className="flex justify-start"
            >
              <div className="w-8 h-8 rounded-full bg-slate-900 border border-amber-500/30 flex items-center justify-center mr-2 text-[10px] text-amber-300 shrink-0 font-serif">
                澜
              </div>
              <div className="bg-indigo-950/40 border border-indigo-950 rounded-2xl px-4 py-3 flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400/80 animate-bounce" />
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400/80 animate-bounce [animation-delay:0.2s]" />
                <span className="w-1.5 h-1.5 rounded-full bg-amber-400/80 animate-bounce [animation-delay:0.4s]" />
              </div>
            </motion.div>
          )}
        </AnimatePresence>
        <div ref={messagesEndRef} />
      </div>

      {/* Helper Pre-prompts Carousel */}
      {messages.length === 1 && !isTyping && (
        <div className="px-4 py-2 border-t border-indigo-950/30 bg-slate-950/10">
          <span className="text-[10px] text-slate-400 block mb-2 font-medium">你现在，最想被哪件事接住？</span>
          <div className="flex overflow-x-auto gap-2 pb-1.5 scrollbar-thin scrollbar-thumb-indigo-950 scrollbar-track-transparent">
            {predefinedPrompts.map((p, idx) => (
              <button
                key={idx}
                onClick={() => handleSendMessage(p.text)}
                className="flex items-center gap-1.5 px-3 py-2 bg-indigo-950/30 border border-indigo-950/80 hover:border-amber-500/30 rounded-xl text-[11px] text-slate-300 hover:text-white transition-all cursor-pointer whitespace-nowrap active:scale-95 shadow-md shrink-0"
              >
                {p.icon}
                <span>{p.text}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Input box */}
      <div className="p-4 border-t border-indigo-950/50 bg-slate-950/40 sticky bottom-0 z-10 backdrop-blur-md">
        <form
          onSubmit={(e) => {
            e.preventDefault();
            handleSendMessage(inputValue);
          }}
          className="relative flex items-center"
        >
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="把此刻的心事告诉星澜……"
            className="w-full bg-slate-950/80 border border-indigo-950/80 rounded-full pl-5 pr-12 py-3.5 text-xs text-slate-200 placeholder-slate-600 focus:outline-none focus:border-amber-500/40 transition-all shadow-inner"
          />
          <button
            type="submit"
            disabled={!inputValue.trim()}
            className={`absolute right-1.5 p-2 rounded-full cursor-pointer transition-all ${
              inputValue.trim()
                ? "bg-gradient-to-r from-amber-500 to-amber-600 text-slate-950"
                : "bg-slate-900 text-slate-600 cursor-not-allowed"
            }`}
          >
            <Send className="w-3.5 h-3.5" />
          </button>
        </form>

        <p className="text-[10px] text-slate-500 text-center mt-3 tracking-wide">
          星澜的回应仅供陪伴与自我探索参考，不构成任何专业建议。
        </p>
      </div>
    </div>
  );
}
