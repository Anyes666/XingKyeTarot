const AppCards = (function() {

  const U = Core.Util;
  const local = {
    deck: 'tarot',
    suitFilter: 'all',
    keyword: ''
  };

  function init() {
    document.getElementById('card-modal').addEventListener('click', e => {
      if (e.target.classList.contains('modal-back') || e.target.closest('.modal-back')) {
        closeCard();
      }
    });
  }

  function render() {
    const screen = document.getElementById('screen-cards');
    screen.innerHTML = `
      <div class="app-header">
        <button class="btn-back" onclick="Core.goHome()">${U.icon('back', 20)}</button>
        <div class="app-title">牌库</div>
      </div>
      <div class="app-body">
        <div class="tab-row">
          <div class="seg" id="cd-deck-seg">
            <button class="${local.deck==='tarot'?'on':''}" data-deck="tarot">塔罗 · 79</button>
            <button class="${local.deck==='lenormand'?'on':''}" data-deck="lenormand">雷诺曼 · 40</button>
          </div>
        </div>
        <div class="suit-row" id="cd-suit-wrap" style="${local.deck==='tarot'?'':'display:none;'}">
          <div class="seg" id="cd-suit-seg">
            <button class="${local.suitFilter==='all'?'on':''}" data-suit="all">全部</button>
            <button class="${local.suitFilter==='major'?'on':''}" data-suit="major">大</button>
            <button class="${local.suitFilter==='wands'?'on':''}" data-suit="wands">权杖</button>
            <button class="${local.suitFilter==='cups'?'on':''}" data-suit="cups">圣杯</button>
            <button class="${local.suitFilter==='swords'?'on':''}" data-suit="swords">宝剑</button>
            <button class="${local.suitFilter==='pents'?'on':''}" data-suit="pents">星币</button>
          </div>
        </div>
        <div class="search-bar">
          ${U.icon('search', 14)}
          <input id="cd-search" placeholder="搜索牌名或关键词…" value="${U.escape(local.keyword)}">
        </div>
        <div class="card-list" id="cd-list"></div>
      </div>
    `;

    screen.querySelectorAll('#cd-deck-seg button').forEach(b => {
      b.onclick = () => {
        local.deck = b.dataset.deck;
        local.suitFilter = 'all';
        render();
      };
    });
    screen.querySelectorAll('#cd-suit-seg button').forEach(b => {
      b.onclick = () => {
        local.suitFilter = b.dataset.suit;
        screen.querySelectorAll('#cd-suit-seg button').forEach(btn => btn.classList.remove('on'));
        b.classList.add('on');
        renderList();
      };
    });
    const searchInput = document.getElementById('cd-search');
    searchInput.oninput = () => {
      local.keyword = searchInput.value;
      renderList();
    };

    renderList();
  }

  function renderList() {
    let pool = local.deck === 'tarot' ? TAROT_CARDS : LEN_CARDS;
    if (local.suitFilter !== 'all') pool = pool.filter(c => c.suit === local.suitFilter);
    const q = local.keyword.trim().toLowerCase();
    if (q) {
      pool = pool.filter(c =>
        c.name.toLowerCase().includes(q) ||
        c.up.toLowerCase().includes(q) ||
        c.core.toLowerCase().includes(q)
      );
    }
    const listEl = document.getElementById('cd-list');
    if (!pool.length) {
      listEl.innerHTML = `<div class="empty-state" style="grid-column:1/-1;">没找到对应的牌</div>`;
      return;
    }
    listEl.innerHTML = pool.map(c => `
      <button class="card-cell" data-name="${U.escape(c.name)}">
        <span class="num">${U.escape(c.num)}</span>
        <span class="name">${U.escape(c.name)}</span>
        <span class="kw">${U.escape(c.up.split('/')[0])}</span>
      </button>
    `).join('');
    listEl.querySelectorAll('.card-cell').forEach(el => {
      el.onclick = () => openCard(el.dataset.name);
    });
  }

  function openCard(name) {
    const c = ALL_CARDS.find(x => x.name === name);
    if (!c) return;
    const modal = document.getElementById('card-modal');
    modal.innerHTML = `
      <div class="card-modal-inner">
        <div class="card-modal-head">
          <button class="back modal-back">${U.icon('back', 18)}</button>
          <div class="num">${U.escape(c.deck === 'tarot' ? 'TAROT' : 'LENORMAND')} · ${U.escape(c.num)} · ${SUIT_NAMES[c.suit] || ''}</div>
          <div class="name">${U.escape(c.name)}</div>
          <div class="kw">${U.escape(c.up)}</div>
        </div>
        <div class="card-modal-body">
          <div class="pair-row">
            <div class="pair-cell">
              <div class="pk">正位 UPRIGHT</div>
              <div class="pv">${U.escape(c.up)}</div>
            </div>
            <div class="pair-cell dark-pair">
              <div class="pk">逆位 REVERSED</div>
              <div class="pv">${U.escape(c.rev)}</div>
            </div>
          </div>
          <div class="attr-row">
            <div class="attr-cell"><div class="k">元素</div><div class="v">${U.escape(c.ele)}</div></div>
            <div class="attr-cell"><div class="k">对应</div><div class="v">${U.escape(c.astro)}</div></div>
            <div class="attr-cell"><div class="k">数字</div><div class="v">${U.escape(c.numv)}</div></div>
          </div>
          <div class="section-cell" style="margin-bottom:14px;">
            <h4>核心</h4>
            <p>${U.escape(c.core)}</p>
          </div>
          <div class="section-grid">
            <div class="section-cell"><h4>情感</h4><p>${U.escape(c.love)}</p></div>
            <div class="section-cell"><h4>事业</h4><p>${U.escape(c.career)}</p></div>
            <div class="section-cell"><h4>财运</h4><p>${U.escape(c.money)}</p></div>
            <div class="section-cell"><h4>健康</h4><p>${U.escape(c.health)}</p></div>
            <div class="section-cell"><h4>学业</h4><p>${U.escape(c.study)}</p></div>
            <div class="section-cell"><h4>人际</h4><p>${U.escape(c.social)}</p></div>
            <div class="section-cell"><h4>时间</h4><p>${U.escape(c.time)}</p></div>
            <div class="section-cell"><h4>警示</h4><p>${U.escape(c.warn)}</p></div>
          </div>
          <div class="section-cell" style="margin-bottom:14px;">
            <h4>建议</h4>
            <p>${U.escape(c.advice)}</p>
          </div>
          <div class="imagery-box">${U.escape(c.imagery)}</div>
        </div>
      </div>
    `;
    modal.classList.add('show');
  }

  function closeCard() {
    document.getElementById('card-modal').classList.remove('show');
  }

  return { init, render, openCard, closeCard };
})();