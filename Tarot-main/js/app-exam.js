const AppExam = (function() {

  const U = Core.Util;

  const local = {
    scope: 'tarot',
    qCount: 15,
    running: false,
    mode: null,
    idx: 0,
    score: 0,
    lives: 0,
    streak: 0,
    questions: [],
    timer: null,
    timeLeft: 0,
    correctCnt: 0,
    wrongCnt: 0,
    selectedMulti: []
  };

  const MODES = {
    beginner: {
      label: '入门', opts: 4, time: 0, showAnswer: true, penalty: 0, lives: 0,
      types: ['nameToCore', 'coreToName', 'uprightToCard', 'booleanQ']
    },
    intermediate: {
      label: '进阶', opts: 5, time: 30, showAnswer: true, penalty: 0, lives: 0,
      types: ['nameToCore', 'coreToName', 'uprightToCard', 'reversedToCard', 'multiKeyword', 'fillBlank', 'booleanQ']
    },
    advanced: {
      label: '高阶', opts: 5, time: 18, showAnswer: true, penalty: 5, lives: 0,
      types: ['combined', 'multiKeyword', 'reversedToCard', 'fillBlank', 'scenarioQ']
    },
    master: {
      label: '大师', opts: 5, time: 10, showAnswer: false, penalty: 8, lives: 3,
      types: ['imageryQ', 'scenarioQ', 'fillBlank', 'multiKeyword', 'combined']
    }
  };

  const Q = {
    nameToCore(card, pool, n) {
      const correct = card.core.split('。')[0];
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.core.split('。')[0]);
      return { type: 'single', kind: '识义', text: `「${card.name}」的核心含义是？`, correct, opts: U.shuffle([...distractors, correct]) };
    },
    coreToName(card, pool, n) {
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.name);
      return { type: 'single', kind: '识牌', text: `下列哪张牌指向「${card.core.split('。')[0]}」？`, correct: card.name, opts: U.shuffle([...distractors, card.name]) };
    },
    uprightToCard(card, pool, n) {
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.name);
      return {
        type: 'single', kind: '正位', text: `下列正位关键词属于哪张牌？`,
        clues: [['正位', card.up]],
        correct: card.name, opts: U.shuffle([...distractors, card.name])
      };
    },
    reversedToCard(card, pool, n) {
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.name);
      return {
        type: 'single', kind: '逆位', text: `下列逆位含义属于哪张牌？`,
        clues: [['逆位', card.rev]],
        correct: card.name, opts: U.shuffle([...distractors, card.name])
      };
    },
    combined(card, pool, n) {
      const clues = [
        ['元素', card.ele],
        ['对应', card.astro],
        ['正位', card.up.split('/').slice(0, 2).join('/')]
      ].filter(c => c[1] && c[1] !== '—');
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.name);
      return {
        type: 'single', kind: '多线索', text: `根据线索判断这是哪张牌：`,
        clues, correct: card.name, opts: U.shuffle([...distractors, card.name])
      };
    },
    imageryQ(card, pool, n) {
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.name);
      return {
        type: 'single', kind: '意象', text: `这段意象描述属于哪张牌？`,
        clues: [['意象', card.imagery]],
        correct: card.name, opts: U.shuffle([...distractors, card.name])
      };
    },
    scenarioQ(card, pool, n) {
      const scenes = [
        `占卜情感时抽到，可能在暗示：${card.love}`,
        `占卜事业时抽到，可能在暗示：${card.career}`,
        `占卜财运时抽到，可能在暗示：${card.money}`
      ];
      const scene = U.pick(scenes);
      const distractors = U.sample(pool.filter(c => c.name !== card.name), n - 1).map(c => c.name);
      return {
        type: 'single', kind: '情境', text: `这段解读对应哪张牌？`,
        clues: [['情境', scene]],
        correct: card.name, opts: U.shuffle([...distractors, card.name])
      };
    },
    booleanQ(card, pool, n) {
      const isTrue = Math.random() < 0.5;
      let text = '';
      let correct = '';
      if (isTrue) {
        text = `「${card.name}」的核心含义是「${card.core.split('❖')[0].split('。')[0]}」，这个说法是否正确？`;
        correct = '正确';
      } else {
        const wrongCard = U.pick(pool.filter(c => c.name !== card.name));
        text = `「${card.name}」的核心含义是「${wrongCard.core.split('❖')[0].split('。')[0]}」，这个说法是否正确？`;
        correct = '错误';
      }
      return {
        type: 'single',
        kind: '判断',
        text,
        correct,
        opts: ['正确', '错误']
      };
    },
    multiKeyword(card, pool, n) {
      const allKw = card.up.split('/').filter(Boolean);
      const correctKw = U.sample(allKw, Math.min(3, Math.max(2, allKw.length - 1)));
      const otherPool = pool.filter(c => c.name !== card.name);
      const wrongKw = [];
      const seen = new Set(correctKw);
      while (wrongKw.length < n - correctKw.length && otherPool.length) {
        const oc = U.pick(otherPool);
        const k = U.pick(oc.up.split('/').filter(Boolean));
        if (!seen.has(k)) { seen.add(k); wrongKw.push(k); }
      }
      return {
        type: 'multi',
        kind: '多选',
        text: `「${card.name}」的正位关键词包含以下哪些？`,
        correctSet: correctKw,
        opts: U.shuffle([...correctKw, ...wrongKw])
      };
    },
    fillBlank(card, pool, n) {
      const variants = [
        { hint: card.core.split('。')[0], blank: 'name', text: `「${card.core.split('。')[0]}」是哪张牌的核心？请填入牌名：`, answer: card.name },
        { hint: card.up.split('/')[0], blank: 'name', text: `根据正位关键词「${card.up.split('/')[0]}」，请填入牌名：`, answer: card.name },
      ];
      if (card.ele && card.ele !== '—') {
        variants.push({ text: `「${card.name}」对应的元素是？（一个字）`, answer: card.ele });
      }
      const v = U.pick(variants);
      return {
        type: 'fill',
        kind: '填空',
        text: v.text,
        answer: v.answer,
        accept: (input) => {
          const a = String(input).trim().replace(/\s/g, '').toLowerCase();
          const b = String(v.answer).trim().replace(/\s/g, '').toLowerCase();
          return a === b;
        }
      };
    }
  };

  function getPool() {
    if (local.scope === 'tarot') return TAROT_CARDS;
    if (local.scope === 'lenormand') return LEN_CARDS;
    return ALL_CARDS;
  }

  function init() {}

  function render() {
    if (local.running) return;
    const screen = document.getElementById('screen-exam');
    screen.innerHTML = `
      <div class="app-header">
        <button class="btn-back" onclick="Core.goHome()">${U.icon('back', 20)}</button>
        <div class="app-title">练习</div>
      </div>
      <div class="app-body">
        <div class="config-block">
          <div class="label">范围</div>
          <div class="seg" id="ex-scope-seg">
            <button class="${local.scope==='tarot'?'on':''}" data-v="tarot">塔罗</button>
            <button class="${local.scope==='lenormand'?'on':''}" data-v="lenormand">雷诺曼</button>
            <button class="${local.scope==='mixed'?'on':''}" data-v="mixed">混合</button>
          </div>
        </div>
        <div class="config-block">
          <div class="label">题数</div>
          <div class="seg" id="ex-qc-seg">
            <button class="${local.qCount===10?'on':''}" data-v="10">10 题</button>
            <button class="${local.qCount===15?'on':''}" data-v="15">15 题</button>
            <button class="${local.qCount===20?'on':''}" data-v="20">20 题</button>
          </div>
        </div>

        <div class="config-block" style="margin-top:18px;">
          <div class="label">难度</div>
        </div>
        <div class="mode-list">
          <button class="mode-card" data-mode="beginner">
            <span class="mode-icon icon-cards"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.7"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3"/></svg></span>
            <span style="flex:1;">
              <div class="mode-name">入门</div>
              <div class="mode-desc">基础知识</div>
            </span>
          </button>
          <button class="mode-card" data-mode="intermediate">
            <span class="mode-icon icon-exam"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M4 7h16M4 12h10M4 17h16"/></svg></span>
            <span style="flex:1;">
              <div class="mode-name">进阶</div>
              <div class="mode-desc">混合题型 加入多选与填空</div>
            </span>
          </button>
          <button class="mode-card" data-mode="advanced">
            <span class="mode-icon icon-reading"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M12 2L3 7v5c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V7z"/></svg></span>
            <span style="flex:1;">
              <div class="mode-name">高阶</div>
              <div class="mode-desc">复合线索 / 情境</div>
            </span>
          </button>
          <button class="mode-card" data-mode="master">
  <span class="mode-icon"><svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.4"><path d="M12 2l2.5 7H22l-6 4.5L18.5 21 12 16.5 5.5 21 8 13.5 2 9h7.5z"/></svg></span>
  <span style="flex:1;">
    <div class="mode-name">大师</div>
    <div class="mode-desc">意象 / 情境为主</div>
  </span>
</button>
        </div>
      </div>
    `;

    screen.querySelectorAll('#ex-scope-seg button').forEach(b => {
      b.onclick = () => { local.scope = b.dataset.v; render(); };
    });
    screen.querySelectorAll('#ex-qc-seg button').forEach(b => {
      b.onclick = () => { local.qCount = parseInt(b.dataset.v); render(); };
    });
    screen.querySelectorAll('.mode-card').forEach(m => {
      m.onclick = () => startExam(m.dataset.mode);
    });
  }

  function startExam(mode) {
    const cfg = MODES[mode];
    local.running = true;
    local.mode = mode;
    local.idx = 0;
    local.score = 0;
    local.lives = cfg.lives;
    local.streak = 0;
    local.correctCnt = 0;
    local.wrongCnt = 0;
    local.questions = [];

    const pool = getPool();
    for (let i = 0; i < local.qCount; i++) {
      const typeName = cfg.types[i % cfg.types.length];
      const card = U.pick(pool);
      local.questions.push(Q[typeName](card, pool, cfg.opts));
    }
    renderQ();
  }

  function exitExam() {
    clearInterval(local.timer);
    local.running = false;
    render();
  }

  function renderQ() {
    clearInterval(local.timer);
    if (local.idx >= local.qCount) return showResult(false);
    const cfg = MODES[local.mode];
    if (cfg.lives && local.lives <= 0) return showResult(true);

    const q = local.questions[local.idx];
    local.selectedMulti = [];

    const screen = document.getElementById('screen-exam');
    screen.innerHTML = `
      <div class="app-header">
        <button class="btn-back" onclick="AppExam.exit()">${U.icon('close', 20)}</button>
        <div class="app-title">${cfg.label}</div>
        <div class="app-actions">
          ${cfg.lives ? `<div id="ex-lives" class="lives" style="padding:0 4px;"></div>` : ''}
        </div>
      </div>
      <div class="app-body">
        <div class="exam-bar">
          <div class="exam-meta"><span id="q-curr">${local.idx + 1}</span>/${local.qCount}</div>
          <div class="progress"><div class="progress-fill" id="prog" style="width:${(local.idx/local.qCount)*100}%;"></div></div>
          ${cfg.time > 0 ? `<div class="timer" id="timer">--</div>` : ''}
          <div class="exam-meta">分数 <span id="q-score">${local.score}</span></div>
        </div>
        <div class="q-frame">
          <div class="q-kind">${q.kind}</div>
          <div class="q-text">${U.escape(q.text)}</div>
          ${q.clues ? `<div class="q-clues">${q.clues.map(c => `<div class="clue"><span class="clue-k">${U.escape(c[0])}</span><span class="clue-v">${U.escape(c[1])}</span></div>`).join('')}</div>` : ''}
          <div id="q-body"></div>
          <div class="feedback" id="feedback"></div>
        </div>
        <div class="exam-foot">
          <button class="btn btn-ghost" onclick="AppExam.exit()">退出</button>
          <button class="btn" id="confirm-btn" style="display:none;" onclick="AppExam.confirmAnswer()">提交答案</button>
          <button class="btn" id="next-btn" style="display:none;" onclick="AppExam.next()">下一题 →</button>
        </div>
      </div>
    `;

    const body = document.getElementById('q-body');
    if (q.type === 'fill') {
      body.innerHTML = `<input class="fill-input" id="fill-input" placeholder="输入答案…" autocomplete="off">`;
      document.getElementById('fill-input').focus();
      document.getElementById('fill-input').onkeydown = (e) => {
        if (e.key === 'Enter') confirmAnswer();
      };
      document.getElementById('confirm-btn').style.display = '';
    } else if (q.type === 'multi') {
      body.innerHTML = `<div class="opts">${q.opts.map((o, i) =>
        `<button class="opt multi" data-i="${i}">
          <span class="check">${U.icon('check', 12)}</span>
          <span>${U.escape(o)}</span>
        </button>`
      ).join('')}</div>`;
      body.querySelectorAll('.opt').forEach(el => {
        el.onclick = () => toggleMulti(el);
      });
      document.getElementById('confirm-btn').style.display = '';
    } else {
      body.innerHTML = `<div class="opts">${q.opts.map((o, i) =>
        `<button class="opt" data-i="${i}">
          <span class="check">${U.icon('check', 12)}</span>
          <span>${U.escape(o)}</span>
        </button>`
      ).join('')}</div>`;
      body.querySelectorAll('.opt').forEach(el => {
        el.onclick = () => answerSingle(el);
      });
    }

    renderLives();

    if (cfg.time > 0) {
      let t = cfg.time;
      if (cfg.lives && local.streak < 0) t = Math.max(5, cfg.time + local.streak);
      local.timeLeft = t;
      const tEl = document.getElementById('timer');
      tEl.innerText = t.toFixed(1) + 's';
      local.timer = setInterval(() => {
        local.timeLeft -= 0.1;
        if (local.timeLeft <= 0) {
          clearInterval(local.timer);
          local.timeLeft = 0;
          tEl.innerText = '0.0s';
          tEl.classList.add('urgent');
          timeOut();
          return;
        }
        tEl.innerText = local.timeLeft.toFixed(1) + 's';
        tEl.classList.toggle('urgent', local.timeLeft <= 5);
      }, 100);
    }
  }

  function renderLives() {
    const cfg = MODES[local.mode];
    if (!cfg.lives) return;
    const el = document.getElementById('ex-lives');
    if (!el) return;
    let html = '';
    for (let i = 0; i < cfg.lives; i++) {
      html += `<div class="life-dot${i >= local.lives ? ' lost' : ''}"></div>`;
    }
    el.innerHTML = html;
  }

  function toggleMulti(el) {
    const i = parseInt(el.dataset.i);
    const idx = local.selectedMulti.indexOf(i);
    if (idx >= 0) {
      local.selectedMulti.splice(idx, 1);
      el.classList.remove('selected');
    } else {
      local.selectedMulti.push(i);
      el.classList.add('selected');
    }
  }

  function answerSingle(el) {
    clearInterval(local.timer);
    const q = local.questions[local.idx];
    const i = parseInt(el.dataset.i);
    const selected = q.opts[i];
    document.querySelectorAll('.opt').forEach(b => b.disabled = true);
    judge(selected === q.correct, q, el);
  }

  function confirmAnswer() {
    clearInterval(local.timer);
    const q = local.questions[local.idx];
    document.getElementById('confirm-btn').style.display = 'none';

    if (q.type === 'fill') {
      const input = document.getElementById('fill-input');
      input.disabled = true;
      const isCorrect = q.accept(input.value);
      input.classList.add(isCorrect ? 'correct' : 'wrong');
      judge(isCorrect, q);
    } else if (q.type === 'multi') {
      const selectedSet = local.selectedMulti.map(i => q.opts[i]).sort();
      const correctSet = q.correctSet.slice().sort();
      const isCorrect = selectedSet.length === correctSet.length && selectedSet.every((v, i) => v === correctSet[i]);
      document.querySelectorAll('.opt').forEach((b, idx) => {
        b.disabled = true;
        const val = q.opts[idx];
        if (q.correctSet.includes(val)) b.classList.add('correct');
        else if (b.classList.contains('selected')) b.classList.add('wrong');
      });
      judge(isCorrect, q);
    }
  }

  function judge(isCorrect, q, selectedEl) {
    const cfg = MODES[local.mode];
    if (isCorrect) {
      if (selectedEl) selectedEl.classList.add('correct');
      local.correctCnt++;
      local.streak = Math.max(1, local.streak + 1);
      let gain = 10;
      if (local.streak >= 3) gain += 2;
      local.score += gain;
      showFeedback(true, q);
    } else {
      if (selectedEl) selectedEl.classList.add('wrong');
      local.wrongCnt++;
      local.streak = local.streak > 0 ? -1 : local.streak - 1;
      local.score = Math.max(0, local.score - cfg.penalty);
      if (cfg.lives) { local.lives--; renderLives(); }
      if (cfg.showAnswer) {
        if (q.type === 'single') {
          document.querySelectorAll('.opt').forEach((b, idx) => {
            if (q.opts[idx] === q.correct) b.classList.add('correct');
          });
        } else if (q.type === 'fill') {
        }
      }
      showFeedback(false, q);
    }
    document.getElementById('q-score').innerText = local.score;
    document.getElementById('next-btn').style.display = '';
  }

  function timeOut() {
    document.querySelectorAll('.opt').forEach(b => b.disabled = true);
    const fi = document.getElementById('fill-input');
    if (fi) fi.disabled = true;
    document.getElementById('confirm-btn').style.display = 'none';
    judge(false, local.questions[local.idx]);
  }

  function showFeedback(correct, q) {
    const fb = document.getElementById('feedback');
    fb.classList.remove('ok', 'no');
    fb.classList.add(correct ? 'ok' : 'no');
    fb.classList.add('show');
    let msg = `<div class="label">${correct ? '✓ 正确' : '✗ 错误'}</div>`;
    const cfg = MODES[local.mode];
    if (correct || cfg.showAnswer) {
      if (q.type === 'single') {
        const card = ALL_CARDS.find(c => c.name === q.correct);
        if (card) msg += `${U.escape(card.name)} · ${U.escape(card.up.split('/').slice(0,2).join('/'))}`;
        else msg += U.escape(q.correct);
      } else if (q.type === 'multi') {
        msg += `正确答案：${q.correctSet.map(U.escape).join('、')}`;
      } else if (q.type === 'fill') {
        msg += `正确答案：${U.escape(q.answer)}`;
      }
    } else {
      msg += '本难度不揭示答案';
    }
    fb.innerHTML = msg;
  }

  function next() {
    local.idx++;
    renderQ();
  }

  function showResult(gameOver) {
    clearInterval(local.timer);
    local.running = false;
    const cfg = MODES[local.mode];
    const total = local.correctCnt + local.wrongCnt;
    const acc = total ? Math.round(local.correctCnt / total * 100) : 0;
    let msg = '继续走 路还长。';
    if (gameOver) msg = '挑战失败了呢 再来一次？';
    else if (acc >= 90) msg = '炉火纯青 或许该叫你「巫」';
    else if (acc >= 70) msg = '做得不错 可以再练练细节';
    else if (acc >= 50) msg = '粗心了 先巩固吧';
    else msg = '不急 回牌库慢慢看';

    const screen = document.getElementById('screen-exam');
    screen.innerHTML = `
      <div class="app-header">
        <button class="btn-back" onclick="Core.goHome()">${U.icon('back', 20)}</button>
        <div class="app-title">${cfg.label} · ${gameOver ? '中止' : '完成'}</div>
      </div>
      <div class="app-body">
        <div class="result">
          <div class="result-label">最终分数</div>
          <div class="result-num">${local.score}</div>
          <div class="result-msg">${msg}</div>
          <div class="result-stats">
            <div class="stat"><b>${local.correctCnt}</b>正确</div>
            <div class="stat"><b>${local.wrongCnt}</b>错误</div>
            <div class="stat"><b>${acc}%</b>正确率</div>
          </div>
        </div>
        <div style="margin-top:18px;display:flex;gap:8px;">
          <button class="btn btn-ghost" style="flex:1;" onclick="AppExam.render()">返回</button>
          <button class="btn" style="flex:1;" onclick="AppExam.restart('${local.mode}')">再来一次</button>
        </div>
      </div>
    `;
  }

  function restart(mode) {
    startExam(mode);
  }

  return {
    init, render,
    exit: exitExam,
    confirmAnswer,
    next,
    restart
  };
})();
