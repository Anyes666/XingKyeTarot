const Core = (function() {

  const state = {
    notes: [],
    theme: 'light',
    currentApp: 'home'
  };

  function load() {
    try {
      const s = localStorage.getItem('tarot_app_v3');
      if (s) Object.assign(state, JSON.parse(s));
    } catch(e) {}
  }
  function save() {
    localStorage.setItem('tarot_app_v3', JSON.stringify({
      notes: state.notes,
      theme: state.theme
    }));
  }

  function applyTheme() {
    document.documentElement.setAttribute('data-theme', state.theme);
  }
  function toggleTheme() {
    state.theme = state.theme === 'light' ? 'dark' : 'light';
    applyTheme();
    save();
  }

function goto(appName) {
    state.currentApp = appName;
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('is-active'));
    const target = document.getElementById('screen-' + appName);
    if (target) target.classList.add('is-active');

    if (appName === 'cards' && typeof AppCards !== 'undefined') AppCards.render();
    if (appName === 'exam' && typeof AppExam !== 'undefined') AppExam.render();
    if (appName === 'reading' && typeof AppReading !== 'undefined') AppReading.render();
    if (appName === 'notes' && typeof AppNotes !== 'undefined') AppNotes.render();
  }
  function goHome() { goto('home'); }

  const Util = {
    shuffle(arr) { return arr.slice().sort(() => Math.random() - 0.5); },
    sample(arr, n) { return Util.shuffle(arr).slice(0, n); },
    pick(arr) { return arr[Math.floor(Math.random() * arr.length)]; },
    escape(s) { return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); },
    formatDate(d) {
      d = d || new Date();
      const pad = n => String(n).padStart(2, '0');
      return `${d.getFullYear()}.${pad(d.getMonth()+1)}.${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
    },
    icon(name, size = 18) {
      const icons = {
        back: '<path d="M15 18l-6-6 6-6"/>',
        search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>',
        close: '<path d="M18 6L6 18M6 6l12 12"/>',
        edit: '<path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 1 1 3 3L7 19l-4 1 1-4z"/>',
        trash: '<path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>',
        check: '<path d="M20 6L9 17l-5-5"/>',
        save: '<path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><path d="M17 21v-8H7v8M7 3v5h8"/>',
        refresh: '<path d="M21 12a9 9 0 1 1-3.5-7.1"/><path d="M21 4v6h-6"/>',
      };
      return `<svg viewBox="0 0 24 24" width="${size}" height="${size}" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">${icons[name] || ''}</svg>`;
    }
  };

  function tickClock() {
    const d = new Date();
    const pad = n => String(n).padStart(2, '0');
    const el = document.getElementById('status-time');
    if (el) el.innerText = `${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }

  function updateGreeting() {
    const h = new Date().getHours();
    let g = '你好';
    if (h < 5) g = '夜深了';
    else if (h < 11) g = '早上好';
    else if (h < 13) g = '中午好';
    else if (h < 18) g = '下午好';
    else if (h < 23) g = '晚上好';
    else g = '夜深了';
    const el = document.getElementById('home-greeting');
    if (el) el.innerText = g;
  }

  function init() {
    load();
    applyTheme();
    updateGreeting();

    document.addEventListener('click', e => {
      const tile = e.target.closest('[data-app]');
      if (tile) {
        goto(tile.dataset.app);
        return;
      }
      if (e.target.closest('#theme-toggle')) {
        toggleTheme();
      }
    });

    if (typeof AppCards !== 'undefined') AppCards.init();
    if (typeof AppExam !== 'undefined') AppExam.init();
    if (typeof AppReading !== 'undefined') AppReading.init();
    if (typeof AppNotes !== 'undefined') AppNotes.init();
  }
  return {
    init, goto, goHome, save, state, Util
  };
})();