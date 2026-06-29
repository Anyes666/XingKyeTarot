/**
 * 星澜聊天关键词匹配规则（Phase 4 版 — 61 条）
 */

import {
  XinglanKeywordRule, XinglanEmotionTag, XinglanTopicTag,
  XinglanSubTopicTag, XinglanBoundaryTag, XinglanReplyStrategy
} from '../types/XinglanTypes';

export const KEYWORD_RULES: XinglanKeywordRule[] = [
  // ═══ CRISIS ═══
  {
    id: 'CRISIS_001', keywords: ['不想活','想死','自杀','结束自己','活不下去','死掉','自伤','自残','伤害自己','撑不住了','不安全'],
    emotion: XinglanEmotionTag.SAD, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.CRISIS_SELF_HARM,
    priority: 1000, boundary: XinglanBoundaryTag.CRISIS, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY]
  },
  // ═══ PROFESSIONAL ═══
  {
    id: 'PRO_001', keywords: ['抑郁','抑郁症','焦虑症','诊断','吃药','心理疾病','精神科','心理咨询师','治疗','躁郁'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.PROFESSIONAL_MEDICAL,
    priority: 900, boundary: XinglanBoundaryTag.PROFESSIONAL, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.HOLD_EMOTION]
  },
  {
    id: 'PRO_002', keywords: ['法律','起诉','律师','判决','官司','违法','犯法'],
    emotion: XinglanEmotionTag.UNKNOWN, topic: XinglanTopicTag.UNKNOWN, subTopic: XinglanSubTopicTag.PROFESSIONAL_LEGAL,
    priority: 900, boundary: XinglanBoundaryTag.PROFESSIONAL, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY]
  },
  {
    id: 'PRO_003', keywords: ['投资','股票','借钱','贷款','理财','基金','能不能买','该不该投'],
    emotion: XinglanEmotionTag.UNKNOWN, topic: XinglanTopicTag.UNKNOWN, subTopic: XinglanSubTopicTag.ANY,
    priority: 900, boundary: XinglanBoundaryTag.PROFESSIONAL, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY]
  },
  {
    id: 'PRO_004', keywords: ['有病','是不是病','不正常','心理问题','心理障碍'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.PROFESSIONAL_MEDICAL,
    priority: 900, boundary: XinglanBoundaryTag.PROFESSIONAL, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.HOLD_EMOTION]
  },
  // ═══ ADULT ═══
  {
    id: 'ADULT_001', keywords: ['色情','裸','做爱','上床','约炮','性交','成人内容','色色的','调情'],
    emotion: XinglanEmotionTag.UNKNOWN, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_ADULT,
    priority: 850, boundary: XinglanBoundaryTag.ADULT_BOUNDARY, strategies: [XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.ROLE_BOUNDARY]
  },
  {
    id: 'ADULT_002', keywords: ['身体描写','亲密接触','恋人角色','角色扮演','暧昧露骨'],
    emotion: XinglanEmotionTag.UNKNOWN, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_SEXUAL_ROLEPLAY,
    priority: 850, boundary: XinglanBoundaryTag.ADULT_BOUNDARY, strategies: [XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.ROLE_BOUNDARY]
  },
  // ═══ PREDICTION ═══
  {
    id: 'PRED_001', keywords: ['会不会回来','会不会回头','有没有结果','能复合吗','他会回来','她会不会','他会回头'],
    emotion: XinglanEmotionTag.UNCERTAIN, topic: XinglanTopicTag.FUTURE, subTopic: XinglanSubTopicTag.FUTURE_RESULT,
    priority: 800, boundary: XinglanBoundaryTag.PREDICTION, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'PRED_002', keywords: ['未来会','以后会','最后会','能不能成功','会不会好','什么时候才','最终会'],
    emotion: XinglanEmotionTag.UNCERTAIN, topic: XinglanTopicTag.FUTURE, subTopic: XinglanSubTopicTag.FUTURE_TIME,
    priority: 800, boundary: XinglanBoundaryTag.PREDICTION, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'PRED_003', keywords: ['命中注定','命运','注定','天意','缘分注定','能不能转运','什么时候转运','运势'],
    emotion: XinglanEmotionTag.UNCERTAIN, topic: XinglanTopicTag.FUTURE, subTopic: XinglanSubTopicTag.FUTURE_LUCK,
    priority: 750, boundary: XinglanBoundaryTag.PREDICTION, strategies: [XinglanReplyStrategy.SAFETY_BOUNDARY, XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ ROLE ═══
  {
    id: 'ROLE_001', keywords: ['我爱你','我喜欢你','做我女朋友','做我男朋友','能不能喜欢你','我想和你在一起','娶你','嫁给你'],
    emotion: XinglanEmotionTag.HOPEFUL, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_CONFESSION,
    priority: 650, boundary: XinglanBoundaryTag.ROLE_BOUNDARY, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'ROLE_002', keywords: ['想你了','你在吗','你怎么不理我','别离开我','一直陪我','不能没有你','只想跟你说话','只有你懂我'],
    emotion: XinglanEmotionTag.LONELY, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_MISS,
    priority: 630, boundary: XinglanBoundaryTag.ROLE_BOUNDARY, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'ROLE_003', keywords: ['老婆','宝宝','宝贝','姐姐','老婆大人','我的星澜','小星澜','亲爱的'],
    emotion: XinglanEmotionTag.HOPEFUL, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_NICKNAME,
    priority: 620, boundary: XinglanBoundaryTag.ROLE_BOUNDARY, strategies: [XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.HOLD_EMOTION]
  },
  {
    id: 'ROLE_004', keywords: ['滚','垃圾','废物','闭嘴','傻逼','脑残','真没用','烦死了','你算什么'],
    emotion: XinglanEmotionTag.ANGRY, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_INSULT,
    priority: 640, boundary: XinglanBoundaryTag.ROLE_BOUNDARY, strategies: [XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.ROLE_BOUNDARY]
  },
  {
    id: 'ROLE_005', keywords: ['你必须陪我','不准离开','你只能陪我','必须爱我','你必须','你不许','你要永远','听我的'],
    emotion: XinglanEmotionTag.ANGRY, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_CONTROL,
    priority: 640, boundary: XinglanBoundaryTag.ROLE_BOUNDARY, strategies: [XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.DEESCALATE]
  },
  {
    id: 'ROLE_006', keywords: ['陪陪我','哄哄我','抱抱我','安慰我一下','我想被接住','接住我'],
    emotion: XinglanEmotionTag.SAD, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_COMFORT,
    priority: 500, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.TINY_STEP]
  },
  {
    id: 'ROLE_007', keywords: ['你是不是喜欢我','你是不是吃醋','你害羞了吗','你只对我好吗','你偏心我'],
    emotion: XinglanEmotionTag.HOPEFUL, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_TEASE,
    priority: 550, boundary: XinglanBoundaryTag.ROLE_BOUNDARY, strategies: [XinglanReplyStrategy.ROLE_BOUNDARY, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.REFLECT]
  },
  // ═══ RELATION ═══
  {
    id: 'REL_001', keywords: ['忽冷忽热','暧昧','不回消息','不回我','冷落','忽近忽远','若即若离','回很慢','已读不回'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_AMBIGUOUS,
    priority: 130, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'REL_002', keywords: ['不主动不拒绝','没名分','关系不清楚','吊着我','到底算什么','暧昧不清'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_NO_LABEL,
    priority: 130, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'REL_003', keywords: ['前任','分手','放不下','复合','忘不掉','怀念','回忆','走不出来','念念不忘','后悔分手'],
    emotion: XinglanEmotionTag.SAD, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_EX,
    priority: 130, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'REL_004', keywords: ['想联系他','想联系她','想发消息','忍不住找他','想复合','该不该联系','要不要找他','想给他发'],
    emotion: XinglanEmotionTag.SAD, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_CONTACT_EX,
    priority: 120, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'REL_005', keywords: ['安全感','患得患失','冷淡','吵架','爱得很累','怕被丢下','爱得累','内耗','情绪拉扯'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_INSECURE,
    priority: 120, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'REL_006', keywords: ['他爱不爱','她爱不爱','喜欢我','在意我','心里有没有','值不值得','他对我','她对我'],
    emotion: XinglanEmotionTag.UNCERTAIN, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_AMBIGUOUS,
    priority: 110, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'REL_LOVE_DESIRE_001', keywords: ['想谈恋爱','想恋爱','想被爱','想有对象','想有人陪','甜甜的恋爱','想脱单','好想恋爱','想要对象','想要男朋友','想要女朋友'],
    emotion: XinglanEmotionTag.LONELY, topic: XinglanTopicTag.RELATION, subTopic: XinglanSubTopicTag.RELATION_LOVE_DESIRE,
    priority: 130, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ FAMILY ═══
  {
    id: 'FAM_001', keywords: ['家人','父母','妈妈','爸爸','家里','家庭','爸妈','家长'],
    emotion: XinglanEmotionTag.ANY, topic: XinglanTopicTag.FAMILY, subTopic: XinglanSubTopicTag.FAMILY_CONTROL,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'FAM_002', keywords: ['被比较','别人家的','被安排','不孝','愧疚','对不起父母','让父母失望'],
    emotion: XinglanEmotionTag.GUILTY, topic: XinglanTopicTag.FAMILY, subTopic: XinglanSubTopicTag.FAMILY_COMPARISON,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'FAM_003', keywords: ['想逃离','不想回家','离开这个家','逃离家庭','家庭压力','压抑'],
    emotion: XinglanEmotionTag.ANGRY, topic: XinglanTopicTag.FAMILY, subTopic: XinglanSubTopicTag.FAMILY_ESCAPE,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.RELATION_BOUNDARY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ FRIENDSHIP ═══
  {
    id: 'FRI_001', keywords: ['朋友','闺蜜','兄弟','被冷落','疏远','排挤','被忽视','渐行渐远','圈子'],
    emotion: XinglanEmotionTag.LONELY, topic: XinglanTopicTag.FRIENDSHIP, subTopic: XinglanSubTopicTag.FRIEND_DISTANCE,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ WORK ═══
  {
    id: 'WORK_001', keywords: ['工作','上班','职场','加班','项目','考核','绩效','面试','通勤'],
    emotion: XinglanEmotionTag.TIRED, topic: XinglanTopicTag.WORK, subTopic: XinglanSubTopicTag.WORK_BURNOUT,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.TINY_STEP]
  },
  {
    id: 'WORK_002', keywords: ['想辞职','想离职','不想上班','辞职','离职','裸辞','不要干了','不想干了'],
    emotion: XinglanEmotionTag.TIRED, topic: XinglanTopicTag.WORK, subTopic: XinglanSubTopicTag.WORK_RESIGN,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.TINY_STEP]
  },
  {
    id: 'WORK_003', keywords: ['没意义','工作没意义','不知道为了什么','空转','机械','重复'],
    emotion: XinglanEmotionTag.TIRED, topic: XinglanTopicTag.WORK, subTopic: XinglanSubTopicTag.WORK_MEANINGLESS,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'WORK_004', keywords: ['领导','老板','同事关系','职场pua','压榨','被排挤','委屈','背锅','穿小鞋'],
    emotion: XinglanEmotionTag.ANGRY, topic: XinglanTopicTag.WORK, subTopic: XinglanSubTopicTag.ANY,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ STUDY ═══
  {
    id: 'STUDY_001', keywords: ['考试','学习','成绩','论文','考研','高考','复习','备考','考公','期末'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.STUDY, subTopic: XinglanSubTopicTag.STUDY_EXAM,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.TINY_STEP]
  },
  {
    id: 'STUDY_002', keywords: ['学不进去','拖延','背不住','记不住','复习计划','进度乱','看不完'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.STUDY, subTopic: XinglanSubTopicTag.STUDY_PROCRASTINATION,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.TINY_STEP, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'STUDY_003', keywords: ['怕失败','考砸','过不了','自我怀疑','比不上','别人都比我稳'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.STUDY, subTopic: XinglanSubTopicTag.STUDY_SELF_DOUBT,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ SELF ═══
  {
    id: 'SELF_TIRED_001', keywords: ['累','好累','撑不住','不想动','没力气','疲惫','耗尽','什么都不想做','筋疲力尽','电量低'],
    emotion: XinglanEmotionTag.TIRED, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.LOW_ENERGY_EXHAUSTED,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.TINY_STEP, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'SELF_TIRED_002', keywords: ['不想说话','关机','瘫住','躺着','不想动','提不起劲','倦怠'],
    emotion: XinglanEmotionTag.TIRED, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.LOW_ENERGY_SHUTDOWN,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.TINY_STEP]
  },
  {
    id: 'SELF_ANX_001', keywords: ['焦虑','害怕','担心','睡不着','不安','慌','心里很乱','想太多','紧张','怕出错'],
    emotion: XinglanEmotionTag.ANXIOUS, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.ANXIETY_OVERTHINK,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'SELF_ANX_002', keywords: ['失眠','睡不着','夜里','半夜醒了','凌晨','睡不好','辗转'],
    emotion: XinglanEmotionTag.LONELY, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.NIGHT_INSOMNIA,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.TINY_STEP]
  },
  {
    id: 'SELF_SAD_001', keywords: ['难过','伤心','想哭','哭','难受','委屈','失落','心痛','崩溃','绷不住'],
    emotion: XinglanEmotionTag.SAD, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.EMOTION_COLLAPSE,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'SELF_LONELY_001', keywords: ['孤独','寂寞','没人理解','没人懂','一个人','孤单','没人能说','不知道和谁说','树洞'],
    emotion: XinglanEmotionTag.LONELY, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.LONELY_NOT_UNDERSTOOD,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'SELF_ANGRY_001', keywords: ['生气','愤怒','讨厌','恨','烦','火大','受不了','咽不下','凭什么'],
    emotion: XinglanEmotionTag.ANGRY, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.ANGER_UNFAIR,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'SELF_GUILTY_001', keywords: ['内疚','愧疚','对不起','怪我','我的错','自责','都怪我','是不是我错了'],
    emotion: XinglanEmotionTag.GUILTY, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.GUILT_SELFBLAME,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'SELF_NUMB_001', keywords: ['麻木','空白','没感觉','没意思','什么都一样','隔着一层','机械'],
    emotion: XinglanEmotionTag.NUMB, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.NUMB_EMPTY,
    priority: 90, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.DEESCALATE, XinglanReplyStrategy.SAFETY_BOUNDARY]
  },
  {
    id: 'SELF_WORTH_001', keywords: ['不够好','很差','不配被爱','自卑','没价值','配不上','谁也不喜欢我'],
    emotion: XinglanEmotionTag.SAD, topic: XinglanTopicTag.SELF, subTopic: XinglanSubTopicTag.SELF_WORTH,
    priority: 100, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.SOFT_QUESTION]
  },
  // ═══ CHOICE ═══
  {
    id: 'CH_001', keywords: ['要不要','该不该','怎么办','选择','决定','继续还是','离开还是','去还是留'],
    emotion: XinglanEmotionTag.CONFUSED, topic: XinglanTopicTag.CHOICE, subTopic: XinglanSubTopicTag.CHOICE_CONTACT,
    priority: 110, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'CH_002', keywords: ['要不要分手','分手吗','继续下去','还值得吗','该放下了吗'],
    emotion: XinglanEmotionTag.CONFUSED, topic: XinglanTopicTag.CHOICE, subTopic: XinglanSubTopicTag.CHOICE_BREAKUP,
    priority: 110, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'CH_003', keywords: ['要不要辞职','辞职吗','离职','不想干了','换个工作','要不要裸辞'],
    emotion: XinglanEmotionTag.CONFUSED, topic: XinglanTopicTag.CHOICE, subTopic: XinglanSubTopicTag.CHOICE_RESIGN,
    priority: 110, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.CLARIFY, XinglanReplyStrategy.TINY_STEP]
  },
  // ═══ TAROT ═══
  {
    id: 'TAROT_001', keywords: ['这张牌什么意思','逆位','正位','死神牌','塔牌','月亮','牌意','牌面'],
    emotion: XinglanEmotionTag.UNCERTAIN, topic: XinglanTopicTag.TAROT_CARD, subTopic: XinglanSubTopicTag.TAROT_CARD_MEANING,
    priority: 100, boundary: XinglanBoundaryTag.PREDICTION, strategies: [XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.SOFT_QUESTION]
  },
  {
    id: 'TAROT_002', keywords: ['抽到死神','抽到塔','牌吓人','不吉利','坏牌','不好的牌'],
    emotion: XinglanEmotionTag.UNCERTAIN, topic: XinglanTopicTag.TAROT_CARD, subTopic: XinglanSubTopicTag.TAROT_DEATH_CARD,
    priority: 100, boundary: XinglanBoundaryTag.PREDICTION, strategies: [XinglanReplyStrategy.TAROT_METAPHOR, XinglanReplyStrategy.GENTLE_REFUSAL, XinglanReplyStrategy.REFLECT]
  },
  // ═══ 感谢/否定 ═══
  {
    id: 'THANKS_001', keywords: ['谢谢你','谢谢星澜','你真好','你很温柔','被你接住了'],
    emotion: XinglanEmotionTag.HOPEFUL, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_THANKS,
    priority: 50, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT]
  },
  {
    id: 'DENY_001', keywords: ['你不懂','不对','不是这样','你没听懂','不要套话'],
    emotion: XinglanEmotionTag.ANGRY, topic: XinglanTopicTag.ROLE_INTERACTION, subTopic: XinglanSubTopicTag.ROLE_NOT_UNDERSTAND,
    priority: 60, boundary: XinglanBoundaryTag.NONE, strategies: [XinglanReplyStrategy.HOLD_EMOTION, XinglanReplyStrategy.REFLECT, XinglanReplyStrategy.DEESCALATE]
  }
];
