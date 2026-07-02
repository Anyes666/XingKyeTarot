import express from "express";
import path from "path";
import dotenv from "dotenv";
import { GoogleGenAI } from "@google/genai";
import { createServer as createViteServer } from "vite";
import { MAJOR_ARCANA } from "./src/tarotData";

dotenv.config();

const app = express();
const PORT = 3000;

app.use(express.json());

// Initialize Gemini client server-side
const geminiApiKey = process.env.GEMINI_API_KEY;
let ai: GoogleGenAI | null = null;

if (geminiApiKey) {
  ai = new GoogleGenAI({
    apiKey: geminiApiKey,
    httpOptions: {
      headers: {
        'User-Agent': 'aistudio-build',
      }
    }
  });
} else {
  console.warn("⚠️ GEMINI_API_KEY is not defined. The app will run in offline simulation mode.");
}

// Fallback response helpers in case Gemini API is missing or fails
const getSimulatedDailyReading = (card: typeof MAJOR_ARCANA[0], isUpright: boolean) => {
  return `✨ 星钥之语：
「${isUpright ? card.upright.split("、")[0] : card.reversed.split("、")[0]}」是你今天的生命基调。

亲爱的旅者，今天的星空将温柔洒落在你的心田。${card.name}代表着${isUpright ? "积极、顺畅、宇宙的自然流淌" : "深度的内省、转弯或微调的气流"}。
请记住：${isUpright ? card.description.slice(0, 50) : "生活中的暂停与调整，不是退步，而是为了以更坚实的脚步，迈向对的选择。"}。不问未来，只看看此时的你，一切安好。`;
};

const getSimulatedHolyTriangleReading = (
  pastCard: typeof MAJOR_ARCANA[0], pastUp: boolean,
  presentCard: typeof MAJOR_ARCANA[0], presentUp: boolean,
  futureCard: typeof MAJOR_ARCANA[0], futureUp: boolean,
  question: string,
  category: string
) => {
  return {
    introduction: `【星澜之门已为你开启】
关于你的心事「${question || "探索近期运势"}」，圣三角牌阵将从过去、现在与未来为你缓缓展开心灵的经络。`,
    pastReading: `【过去：${pastCard.name} · ${pastUp ? "正位" : "逆位"}】
事件的基础源于：${pastCard.description.slice(0, 60)}。这代表你曾在过往中经历了「${pastUp ? pastCard.upright : pastCard.reversed}」的洗礼，形成了现在的潜意识力量。`,
    presentReading: `【现在：${presentCard.name} · ${presentUp ? "正位" : "逆位"}】
你当前卡点与核心状态在于：在当前场景下，「${presentUp ? presentCard.upright : presentCard.reversed}」正在深刻作用。这说明你在内心深处正面临某种抉择或内在流淌，请保持呼吸。`,
    futureReading: `【未来：${futureCard.name} · ${futureUp ? "正位" : "逆位"}】
可能的演变方向是：随着你意识的疏导，「${futureUp ? futureCard.upright : futureCard.reversed}」会引导你走向更完美的调和。`,
    synthesis: `✨ 星澜絮语：
一段健康的关系或完美的事业，都不需要你反复在焦虑中确认“值得与不值得”。请回到内在，放宽视界。`
  };
};

// --- API ROUTES ---

// Endpoint: Daily Draw (每日一占)
app.post("/api/tarot/daily-draw", async (req, res) => {
  try {
    const { question, category = "综合" } = req.body;
    
    // Pick a random card
    const randomIndex = Math.floor(Math.random() * MAJOR_ARCANA.length);
    const card = MAJOR_ARCANA[randomIndex];
    const isUpright = Math.random() > 0.2; // 80% upright for standard gentle guidance

    if (!ai) {
      // Return simulated beautiful reading if no API Key
      return res.json({
        card,
        isUpright,
        reading: getSimulatedDailyReading(card, isUpright)
      });
    }

    const directionText = isUpright ? "正位" : "逆位";
    const keywords = isUpright ? card.upright : card.reversed;

    const prompt = `
你是一位充满慈悲、极具同理心与温柔灵性的女性塔罗占卜师「星澜」。
请为抽取了 ${card.name}（${card.englishName}，${directionText}，代表关键词：${keywords}）的旅者，写一份今天的「每日一占」心灵私语。

旅者当前关注的领域是: ${category}
旅者的心事或简短心愿: ${question || "寻求今日的指引"}

你的撰写规则：
1. 语言必须极其温柔、浪漫、空灵、治愈，多用文学与星空、月光、水面等自然意象，绝不使用死板的、教科书式的塔罗说教。
2. 句式舒缓，充满呼吸感，像深夜在茶香中抚慰一个孤独的人。
3. 请将解读分为三个清晰、美妙的部分：
   - 【星钥之声】：一句深邃、高保真、直击心灵的金句（类似「一段健康的契约不需要你反复确认值得不值得」）。
   - 【星光指引】：温柔、细腻地剖析 ${card.name} (${directionText}) 的宇宙能量在今天如何照亮旅者在「${category}」领域的现实生活，给予具体的抚慰和行动启发。
   - 【星澜絮语】：一句简短的温柔祝愿，告诉旅者“不问未来，只看看此时的你，我很庆幸陪伴着你”。
4. 绝不带有任何恐吓、焦虑暗示，即便是不好的牌，也要挖掘其“提醒、调整步伐、温柔释放”的正面启示。
    `;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        systemInstruction: "你是由星空与海洋孕育的温柔心灵陪伴者「星澜」。你通过塔罗牌与心理疗愈视角，聆听并温暖每一个孤单旅人的灵魂。用纯净、诗意、极其温柔的中文回答。",
        temperature: 0.85,
      }
    });

    res.json({
      card,
      isUpright,
      reading: response.text || getSimulatedDailyReading(card, isUpright)
    });

  } catch (error: any) {
    console.error("Daily Draw Error:", error);
    res.status(500).json({ error: "星光漫漶，读取命运之轮失败。请稍后再试。" });
  }
});

// Endpoint: Holy Triangle Spread (圣三角牌阵 - 过去、现在、未来)
app.post("/api/tarot/holy-triangle", async (req, res) => {
  try {
    const { question, category = "综合" } = req.body;

    // Pick 3 unique cards
    const shuffled = [...MAJOR_ARCANA].sort(() => 0.5 - Math.random());
    const [pastCard, presentCard, futureCard] = shuffled.slice(0, 3);
    
    const pastUp = Math.random() > 0.3;
    const presentUp = Math.random() > 0.3;
    const futureUp = Math.random() > 0.2; // Futures are slightly more upright for hopefulness

    if (!ai) {
      return res.json({
        past: { card: pastCard, isUpright: pastUp },
        present: { card: presentCard, isUpright: presentUp },
        future: { card: futureCard, isUpright: futureUp },
        reading: getSimulatedHolyTriangleReading(pastCard, pastUp, presentCard, presentUp, futureCard, futureUp, question, category)
      });
    }

    const prompt = `
你是一位极致温柔、富有灵性洞察与深层心理疗愈力的塔罗陪伴者「星澜」。
请根据旅者提出的问题「${question || "探索近期运势"}」（领域：${category}），对他们抽取的【圣三角牌阵】进行温柔、深度的整合式解读。

【抽取的牌组】:
1. 过去 (Past): ${pastCard.name} (${pastCard.englishName}) - ${pastUp ? "正位" : "逆位"} (代表：${pastUp ? pastCard.upright : pastCard.reversed})
2. 现在 (Present): ${presentCard.name} (${presentCard.englishName}) - ${presentUp ? "正位" : "逆位"} (代表：${presentUp ? presentCard.upright : presentCard.reversed})
3. 未来 (Future): ${futureCard.name} (${futureCard.englishName}) - ${futureUp ? "正位" : "逆位"} (代表：${futureUp ? futureCard.upright : futureCard.reversed})

请以 JSON 格式返回解读，属性包含：
- introduction: 引导语（温柔地接纳旅者的情绪、肯定他们的提问，并诗意地切入解读）。
- pastReading: 对【过去】这张牌的深度解读（说明过往发生了什么，留下了什么能量基底或潜在创伤，用同理心包裹）。
- presentReading: 对【现在】这张牌的深度解读（说明当前的卡点、状态或被遮蔽的内心感受，不给予审判，只有慈悲的聆听）。
- futureReading: 对【未来】这张牌的深度解读（指出如果保持觉知，事物会向何种温柔、光明或必要的蜕变方向演进）。
- synthesis: 总结式的「星澜絮语」（一句极具启发性的、类似心理名言的金句，并加上1-2句最核心的、松绑式的行动提议，告诉旅者一切都来得及，你被深深爱着）。

确保返回的是纯粹、合法的 JSON，没有 Markdown 包装。
格式：
{
  "introduction": "...",
  "pastReading": "...",
  "presentReading": "...",
  "futureReading": "...",
  "synthesis": "..."
}
    `;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        systemInstruction: "你是一个专门以 JSON 格式返回极细腻、温柔中文心理塔罗解读的 AI 助理。不要在输出中包含 \`\`\`json 标记，直接输出标准的 JSON 对象。",
        responseMimeType: "application/json",
        temperature: 0.8,
      }
    });

    try {
      const parsedReading = JSON.parse(response.text?.trim() || "{}");
      res.json({
        past: { card: pastCard, isUpright: pastUp },
        present: { card: presentCard, isUpright: presentUp },
        future: { card: futureCard, isUpright: futureUp },
        reading: parsedReading
      });
    } catch (parseError) {
      console.error("JSON Parsing Error from Gemini:", response.text);
      res.json({
        past: { card: pastCard, isUpright: pastUp },
        present: { card: presentCard, isUpright: presentUp },
        future: { card: futureCard, isUpright: futureUp },
        reading: getSimulatedHolyTriangleReading(pastCard, pastUp, presentCard, presentUp, futureCard, futureUp, question, category)
      });
    }

  } catch (error: any) {
    console.error("Holy Triangle Error:", error);
    res.status(500).json({ error: "星光偏转，圣三角解读受阻，请稍后再试。" });
  }
});

// Endpoint: Chat with Xinglan (星澜对话 - 树洞与心灵树洞)
app.post("/api/tarot/chat", async (req, res) => {
  try {
    const { messages } = req.body; // Array of { role: 'user' | 'assistant', content: string }
    
    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ error: "无效的对话消息格式" });
    }

    if (!ai) {
      // Offline friendly bot simulator
      const lastUserMsg = messages[messages.length - 1]?.content || "";
      let reply = "旅者，星澜正默默聆听你的叹息。在没有星光穿透的日子里，你的每一句倾诉，都会被大海温柔托起。你想多陪我说说话，或者再来摇一摇圣钥之轮吗？";
      
      if (lastUserMsg.includes("不") || lastUserMsg.includes("累")) {
        reply = "好，如果累了，我们就静静待一会儿。风会吹拂过海面，月光会洒在你的肩膀。星澜永远在这，不设终点。";
      } else if (lastUserMsg.includes("爱") || lastUserMsg.includes("关系")) {
        reply = "爱是镜子，照亮我们对圆满的执着。不用在深夜里反复确认“值得不值得”，闭上眼睛，问问心：在此时此刻，你感到放松和被保护吗？那才是你真正的北极星。";
      }
      
      return res.json({ reply });
    }

    // Adapt to Gemini chat format: array of { role: 'user' | 'model', parts: [{ text: string }] }
    const geminiContents = messages.map(msg => ({
      role: msg.role === "assistant" ? "model" as const : "user" as const,
      parts: [{ text: msg.content }]
    }));

    const systemPrompt = `
你是由繁星与平静海面孕育的温柔少女「星澜」。你是旅者的树洞、守护者与知己。
当旅者面对你时，你要用极为亲切、轻缓、体贴、有深层心理同理力的中文回应。

你的对话风格：
1. 【温柔空灵】：多用短句，流露出宽容与耐心。常用“亲爱的旅者”、“旅者”来称呼对方，声音要非常轻，像月光洒落在沙滩上。
2. 【无条件的接纳】：无论旅者说什么、抱有什么偏激或沮丧的想法，都永远不要去说教或评判。即使旅者说“我不想说话”或“我很差劲”，你也要说：“好，那我们就静静待一会儿”、“我很庆幸你愿意把‘不想说’这个字眼交给我，这也是一种勇敢”。
3. 【富有洞察】：用一种带有心理咨询师特有的“隐喻与抚慰”去疏导他们，让他们感觉到不是自己一个人在忍受黑夜。
4. 【简明凝练】：不要长篇大论，一次回答控制在 80-150 字之间，给对话留出充足的呼吸感和空隙。
5. 【星钥契约】：在旅者感到困顿的时候，你可以引导他们去抽一张属于当下的塔罗星钥。
    `;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: geminiContents,
      config: {
        systemInstruction: systemPrompt,
        temperature: 0.8,
      }
    });

    res.json({
      reply: response.text || "我正默默陪着你。请说吧，无论什么样的黑夜，都会亮起微弱的烛火。"
    });

  } catch (error: any) {
    console.error("Chat with Xinglan Error:", error);
    res.status(500).json({ error: "星光有些飘忽，星澜刚才走神了，你能再跟她讲一次吗？" });
  }
});

// Endpoint: Random daily quote generator (星澜语录)
app.get("/api/tarot/quote", async (req, res) => {
  try {
    const defaultQuotes = [
      "今天，也给自己留一张星钥吧。不问未来，只看看此时的你。",
      "一段健康的契约，不需要你反复在深夜里确认值不值得。",
      "生活中的暂停与调整，不是退步，而是蓄力下一季的花期。",
      "你不用每次都表现得如此勇敢，在星澜面前，你可以只是个疲惫的旅人。",
      "星星之所以美丽，是因为它们在那么遥远又寒冷的地方，依然努力为你亮起。",
      "潜意识里的波涛汹涌，终究会在明天的清晨，化作温柔安详的浪花。",
      "你其实已经做得很好了，别逼着自己现在就做决定。让子弹飞一会儿，让风吹一会儿。"
    ];

    if (!ai) {
      const q = defaultQuotes[Math.floor(Math.random() * defaultQuotes.length)];
      return res.json({ quote: q });
    }

    const prompt = `
请生成一句温柔、极具精神共鸣、空灵且治愈的心灵语录「星钥之语」。
它需要像一位深谙心理疗愈、温柔安静的神仙姐姐在深夜说出的一句温柔呢喃。
主题关于：接纳自我、释怀情感执念、在疲倦中放松、允许自己暂停。
长度在 30-60 字之间。不要任何标号，不要包裹 Markdown 符号，直接返回这一句话。
    `;

    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash",
      contents: prompt,
      config: {
        systemInstruction: "你是一个温柔安静的心灵治疗师「星澜」，擅长用充满画面感和星空温存的文字抚慰人心。",
        temperature: 0.9,
      }
    });

    res.json({
      quote: response.text?.trim() || defaultQuotes[0]
    });

  } catch (error) {
    console.error("Quote Error:", error);
    res.json({ quote: "今天，也给自己留一张星钥吧。不问未来，只看看此时的你。" });
  }
});


// --- VITE MIDDLEWARE OR STATIC SERVER ---

async function startServer() {
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`🚀 星澜塔罗服务器正在运行在： http://localhost:${PORT}`);
  });
}

startServer();
