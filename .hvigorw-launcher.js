// hvigor 启动包装脚本
// 修复 git bash 下 node cwd 盘符小写（d:）导致 hvigor exitIfNotExists 的
// realpathSync.native 校验失败（NTFS 返回大写 D:）。
// 方案：以大写路径为 cwd，spawn 子进程执行 hvigorw.js，转发 stdio 与退出码。
'use strict';
const { spawnSync } = require('child_process');
const path = require('path');

const projectRoot = 'D:\\XingKeyTarot';
const hvigorwPath = path.join('D:', 'HarmonyOS', 'DevEco Studio', 'tools', 'hvigor', 'bin', 'hvigorw.js');

// argv: ['node', '.hvigorw-launcher.js', 'assembleHap', '--mode', ...]
const hvigorArgs = process.argv.slice(2);

const result = spawnSync(process.execPath, [hvigorwPath, ...hvigorArgs], {
  cwd: projectRoot,
  stdio: 'inherit',
  shell: false,
});

process.exit(result.status === null ? 1 : result.status);
