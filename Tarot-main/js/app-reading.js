const AppReading = (function() {

  const U = Core.Util;

  const local = {
    deck: 'tarot',
    spread: 3,
    reversed: true,
    drawn: [],
    freeDeck: [],
    activeIdx: 0
  };

  const SPREAD_POS = {
    1: ['当下'],
    3: ['过去', '现在', '将来'],
    4: ['你', '对方', '关系', '走向'],
    5: ['处境', '阻碍', '选择A', '选择B', '建议']
  };

  function init() {}

  function render() {
    const screen = document.getElementById('screen-reading');
    screen.innerHTML = `
      <div class="app-header">
        <button class="btn-back" onclick="Core.goHome()">${U.icon('back', 20)}</button>
        <div class="app-title">占卜</div>
      </div>
      <div class="app-body">
        <div class="config-block">
          <div class="label">牌组</div>
          <div class="seg" id="rd-deck-seg">
            <button class="${local.deck==='tarot'?'on':''}" data-v="tarot">塔罗</button>
            <button class="${local.deck==='lenormand'?'on':''}" data-v="lenormand">雷诺曼</button>
          </div>
        </div>
        <div class="config-block">
          <div class="label">牌阵</div>
          <div class="seg" id="rd-spread-seg">
            <button class="${local.spread===1?'on':''}" data-v="1">单张</button>
            <button class="${local.spread===3?'on':''}" data-v="3">三张</button>
            <button class="${local.spread===4?'on':''}" data-v="4">四张</button>
            <button class="${local.spread===5?'on':''}" data-v="5">五张</button>
            <button class="${local.spread==='free'?'on':''}" data-v="free">不限</button>
          </div>
        </div>

        <div class="check-row" id="rd-rev-check">
          <span class="check-box ${local.reversed?'on':''}">
            <svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"/></svg>
          </span>
          <span>包含逆位</span>
        </div>

        <button class="btn btn-block" id="rd-draw-btn" style="margin-bottom:18px;">
          ${U.icon('refresh', 16)} <span id="rd-btn-label">${local.spread==='free' ? '抽一张' : '抽牌'}</span>
        </button>
        <div class="spread-area ${local.drawn.length?'':'empty'}" id="rd-area">
          ${local.drawn.length ? '' : '<span>选好牌阵后点击抽牌</span>'}
        </div>
        <div class="interp-list" id="rd-interp"></div>
      </div>
    `;

    screen.querySelectorAll('#rd-deck-seg button').forEach(b => {
      b.onclick = () => { local.deck = b.dataset.v; local.drawn = []; local.freeDeck = []; render(); };
    });
    screen.querySelectorAll('#rd-spread-seg button').forEach(b => {
      b.onclick = () => {
        const v = b.dataset.v;
        local.spread = v === 'free' ? 'free' : parseInt(v);
        local.drawn = [];
        local.freeDeck = [];
        render();
      };
    });
    document.getElementById('rd-rev-check').onclick = () => {
      local.reversed = !local.reversed;
      render();
    };
    document.getElementById('rd-draw-btn').onclick = draw;

    if (local.drawn.length) renderDrawn();
  }

  function draw() {
    local.activeIdx = 0;
    const deck = local.deck === 'tarot' ? TAROT_CARDS : LEN_CARDS;
    if (local.spread === 'free') {
      if (!local.freeDeck.length && !local.drawn.length) {
        local.freeDeck = U.shuffle(deck);
      }
      if (!local.freeDeck.length) {
        local.freeDeck = U.shuffle(deck);
      }
      const c = local.freeDeck.shift();
      local.drawn.push({
        card: c,
        reversed: local.reversed && Math.random() < 0.3,
        revealed: true
      });
    } else {
      local.drawn = U.sample(deck, local.spread).map(c => ({
        card: c,
        reversed: local.reversed && Math.random() < 0.3,
        revealed: false
      }));
    }
    render();
  }

  function renderDrawn() {
    const area = document.getElementById('rd-area');
    const positions = local.spread === 'free'
      ? local.drawn.map((_, i) => `第 ${i+1} 张`)
      : (SPREAD_POS[local.spread] || local.drawn.map((_, i) => `第${i+1}张`));
    area.classList.remove('empty');
    area.innerHTML = local.drawn.map((d, i) => {
      if (!d.revealed) {
        return `<div class="draw-slot" data-i="${i}"></div>`;
      }
      const isActive = i === local.activeIdx ? 'active' : '';
      return `
        <div class="draw-slot revealed ${d.reversed?'reversed':''} ${isActive}" data-i="${i}">
          <div class="d-num">${U.escape(d.card.num)}${d.reversed?' · R':''}</div>
          <div class="d-name">${U.escape(d.card.name)}</div>
          <div class="d-pos">${U.escape(positions[i])}</div>
        </div>
      `;
    }).join('');
  
    area.querySelectorAll('.draw-slot[data-i]').forEach(el => {
      el.onclick = () => {
        const i = parseInt(el.dataset.i);
        if (!local.drawn[i].revealed) {
          reveal(i);
        } else {
          local.activeIdx = i;
          renderDrawn();
        }
      };
    });
    renderInterp();
  }

  function reveal(i) {
    local.drawn[i].revealed = true;
    local.activeIdx = i;
    render(); 
  }

  function renderInterp() {
    const list = document.getElementById('rd-interp');
    const d = local.drawn[local.activeIdx];
    if (!d || !d.revealed) {
      list.innerHTML = '';
      return;
    }
    const positions = local.spread === 'free'
      ? local.drawn.map((_, i) => `第 ${i+1} 张`)
      : (SPREAD_POS[local.spread] || local.drawn.map((_, i) => `第${i+1}张`));
  
    list.innerHTML = `
      <div class="interp-item" style="animation: stageIn .3s ease both;">
        <div class="interp-h">
          <span class="pos">${U.escape(positions[local.activeIdx])}</span>
          <h3>${U.escape(d.card.name)}</h3>
          ${d.reversed?'<span class="rev-mark">逆位</span>':''}
        </div>
        <div class="interp-body">
          <div class="interp-section"><div class="label">${d.reversed?'逆位':'正位'}</div><div class="content">${U.escape(d.reversed?d.card.rev:d.card.up)}</div></div>
          <div class="interp-section"><div class="label">核心</div><div class="content">${U.escape(d.card.core)}</div></div>
          <div class="interp-section"><div class="label">情感</div><div class="content">${U.escape(d.card.love)}</div></div>
          <div class="interp-section"><div class="label">事业</div><div class="content">${U.escape(d.card.career)}</div></div>
          <div class="interp-section"><div class="label">建议</div><div class="content">${U.escape(d.card.advice)}</div></div>
          <div class="interp-section"><div class="label">警示</div><div class="content">${U.escape(d.card.warn)}</div></div>
        </div>
      </div>
    `;
  }

  return { init, render, draw, reveal };
})();