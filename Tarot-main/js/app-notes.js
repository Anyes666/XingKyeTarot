const AppNotes = (function() {

  const U = Core.Util;
  const local = { editId: null, expanded: new Set() };

  function init() {}

  function render() {
    const screen = document.getElementById('screen-notes');
    const editing = local.editId ? Core.state.notes.find(n => n.id === local.editId) : null;
    screen.innerHTML = `
      <div class="app-header">
        <button class="btn-back" onclick="Core.goHome()">${U.icon('back', 20)}</button>
        <div class="app-title">笔记</div>
      </div>
      <div class="app-body">
        <div class="note-editor">
          <div class="row">
            <select class="field" id="nt-type" style="flex:0 0 110px;">
              ${['梦境','占卜','日常'].map(t =>
                `<option value="${t}" ${editing && editing.type===t?'selected':''}>${t}</option>`
              ).join('')}
            </select>
            <input class="field" id="nt-title" placeholder="标题" value="${editing ? U.escape(editing.title) : ''}">
          </div>
          <textarea class="field" id="nt-content" placeholder="写点什么…">${editing ? U.escape(editing.content) : ''}</textarea>
          <div class="note-actions">
            ${editing ? '<button class="btn btn-ghost" onclick="AppNotes.cancelEdit()">取消</button>' : ''}
            <button class="btn" onclick="AppNotes.saveNote()">
              ${U.icon('save', 14)} ${editing ? '更新' : '保存'}
            </button>
          </div>
        </div>
        <div id="nt-list"></div>
      </div>
    `;
    renderList();
  }

  function renderList() {
    const list = document.getElementById('nt-list');
    if (!Core.state.notes.length) {
      list.innerHTML = `<div class="empty-state">还没有任何记录</div>`;
      return;
    }
    list.innerHTML = Core.state.notes.map(n => {
      const isLong = n.content.length > 100; 
      const isExpanded = local.expanded.has(n.id);
      const displayContent = isLong && !isExpanded
        ? U.escape(n.content.slice(0, 100)) + '...'
        : U.escape(n.content);
  
      return `
        <div class="note-item">
          <div class="note-tools">
            <button class="btn-icon" onclick="AppNotes.edit(${n.id})">${U.icon('edit', 14)}</button>
            <button class="btn-icon" onclick="AppNotes.del(${n.id})">${U.icon('trash', 14)}</button>
          </div>
          <div class="note-meta">
            <span class="note-type">${U.escape(n.type)}</span>
            <span class="note-date">${U.escape(n.date)}</span>
          </div>
          <div class="note-title">${U.escape(n.title)}</div>
          <div class="note-content">${displayContent}</div>
          ${isLong ? `
            <button class="btn-text-toggle" onclick="AppNotes.toggleExpand(${n.id})">
              ${isExpanded ? '收' : '展'}
            </button>
          ` : ''}
        </div>
      `;
    }).join('');
  }

  function toggleExpand(id) {
    if (local.expanded.has(id)) {
      local.expanded.delete(id);
    } else {
      local.expanded.add(id);
    }
    renderList();
  }

  function saveNote() {
    const type = document.getElementById('nt-type').value;
    const title = document.getElementById('nt-title').value.trim() || '无题';
    const content = document.getElementById('nt-content').value.trim();
    if (!content) return;

    if (local.editId) {
      const n = Core.state.notes.find(x => x.id === local.editId);
      if (n) { n.type = type; n.title = title; n.content = content; }
      local.editId = null;
    } else {
      Core.state.notes.unshift({
        id: Date.now(), type, title, content,
        date: U.formatDate()
      });
    }
    Core.save();
    render();
  }

  function edit(id) {
    local.editId = id;
    render();
    document.getElementById('nt-content').scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  function cancelEdit() {
    local.editId = null;
    render();
  }

  function del(id) {
    if (!confirm('删除这条记录？')) return;
    Core.state.notes = Core.state.notes.filter(n => n.id !== id);
    Core.save();
    render();
  }

  return { init, render, saveNote, edit, cancelEdit, del, toggleExpand };
})();
