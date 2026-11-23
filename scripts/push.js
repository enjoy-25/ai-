#!/usr/bin/env node
/**
 * 把本目录内容推送到 GitHub（无需本地 git 客户端）。
 * 用法：
 *   $env:GITHUB_TOKEN="ghp_xxx"
 *   node scripts/push.js --owner enjoy-25 --repo ai- --private
 * 可选：--public 表示建公开库（默认沿用已有仓库可见性；仓库不存在时建私有库）
 */
const https = require('https');
const fs = require('fs');
const path = require('path');

const args = process.argv.slice(2);
const opt = (name, dflt) => {
  const i = args.indexOf('--' + name);
  return i >= 0 && args[i + 1] && !args[i + 1].startsWith('--') ? args[i + 1] : dflt;
};
const TOKEN = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;
const OWNER = opt('owner', 'enjoy-25');
const REPO = opt('repo', 'ai-');
const PRIVATE = !args.includes('--public');
const BRANCH = opt('branch', '');
const ROOT = path.resolve(opt('dir', path.join(__dirname, '..')));

if (!TOKEN) {
  console.error('缺少 GITHUB_TOKEN 环境变量（需要一个有 repo 权限的 Personal Access Token）。');
  process.exit(1);
}

function api(method, url, body) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const req = https.request(
      'https://api.github.com' + url,
      {
        method,
        headers: {
          'user-agent': 'ai-refs-push',
          accept: 'application/vnd.github+json',
          authorization: 'Bearer ' + TOKEN,
          'content-type': 'application/json',
          ...(data ? { 'content-length': Buffer.byteLength(data) } : {}),
        },
      },
      (res) => {
        let d = '';
        res.on('data', (c) => (d += c));
        res.on('end', () => {
          let j = null;
          try { j = d ? JSON.parse(d) : null; } catch { j = { raw: d }; }
          if (res.statusCode >= 200 && res.statusCode < 300) resolve(j);
          else reject(Object.assign(new Error(`${method} ${url} → ${res.statusCode} ${(j && j.message) || d.slice(0, 200)}`), { status: res.statusCode, body: j }));
        });
      }
    );
    req.on('error', reject);
    req.setTimeout(30000, () => { req.destroy(new Error('timeout')); });
    if (data) req.write(data);
    req.end();
  });
}

function walk(dir, base = '') {
  const out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (e.name === '.git' || e.name === 'node_modules' || e.name === 'vendor') continue;
    const rel = base ? base + '/' + e.name : e.name;
    const abs = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...walk(abs, rel));
    else out.push({ rel, abs });
  }
  return out;
}

(async () => {
  // 1. 确认仓库存在，不存在则创建
  let repoInfo = null;
  try {
    repoInfo = await api('GET', `/repos/${OWNER}/${REPO}`);
    console.log(`仓库已存在：${repoInfo.html_url}（${repoInfo.private ? '私有' : '公开'}）`);
  } catch (e) {
    if (e.status !== 404) throw e;
    console.log(`仓库不存在，正在创建 ${OWNER}/${REPO} …`);
    repoInfo = await api('POST', '/user/repos', {
      name: REPO,
      private: PRIVATE,
      description: 'AI 摄影构图 / Vlog 辅助 App —— 开源项目选型库（Android 优先）',
      auto_init: false,
      has_issues: true,
    });
    console.log('已创建：' + repoInfo.html_url);
  }

  const branch = BRANCH || repoInfo.default_branch || 'main';
  const files = walk(ROOT).filter((f) => !/\.(apk|zip)$/i.test(f.rel));
  console.log(`待上传 ${files.length} 个文件 → 分支 ${branch}`);

  // 2. 取已有文件的 sha（支持增量更新）
  const shaMap = new Map();
  async function loadTree() {
    try {
      const t = await api('GET', `/repos/${OWNER}/${REPO}/git/trees/${branch}?recursive=1`);
      for (const n of t.tree) if (n.type === 'blob') shaMap.set(n.path, n.sha);
    } catch { /* 空仓库 */ }
  }
  await loadTree();

  let ok = 0, fail = 0;
  for (const f of files) {
    const content = fs.readFileSync(f.abs).toString('base64');
    const sha = shaMap.get(f.rel);
    try {
      await api('PUT', `/repos/${OWNER}/${REPO}/contents/${encodeURI(f.rel)}`, {
        message: (sha ? 'update: ' : 'add: ') + f.rel,
        content,
        branch,
        ...(sha ? { sha } : {}),
      });
      ok++;
      console.log('  ✓ ' + f.rel);
    } catch (e) {
      fail++;
      console.error('  ✗ ' + f.rel + ' — ' + e.message);
    }
  }
  console.log(`\n完成：成功 ${ok}，失败 ${fail}`);
  console.log('仓库地址：' + repoInfo.html_url);
  if (fail) process.exit(1);
})().catch((e) => {
  console.error('失败：' + e.message);
  if (e.status === 401) console.error('→ token 无效或已过期');
  if (e.status === 403) console.error('→ token 权限不足（需 repo）或触发限流');
  process.exit(1);
});
