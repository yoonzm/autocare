// 页面公共流程：登录守卫、当前门店、异步加载（骨架 / 错误重试，丢弃过期响应）、提示。
const session = require('./session');
const api = require('./api');

/** 没有登录就去登录页。返回是否已登录。 */
function requireLogin() {
  if (session.get()) return true;
  wx.reLaunch({ url: '/pages/auth/auth' });
  return false;
}

/**
 * 当前门店：先取本机记住的（扫码进入的门店也写在这里），不在会员门店里就用第一家。
 * 一个门店都没有（手机号不是任何门店的会员）返回 null。
 */
async function currentStore() {
  const app = getApp();
  if (!app.ctx.stores) app.ctx.stores = (await api.stores()).items || [];
  const stores = app.ctx.stores;
  if (!stores.length) return null;
  let id = app.ctx.storeId || session.storeId();
  if (!stores.some((s) => s.store_id === id)) id = stores[0].store_id;
  app.ctx.storeId = id;
  session.setStoreId(id);
  return id;
}

function switchStore(id) {
  const app = getApp();
  app.ctx.storeId = id;
  app.ctx.overview = null;
  app.ctx.booking = null;
  session.setStoreId(id);
}

async function overview(force) {
  const app = getApp();
  const store = await currentStore();
  if (!store) return null;
  if (!force && app.ctx.overview && app.ctx.overview.store.id === store) return app.ctx.overview;
  app.ctx.overview = (await api.overview(store)).item;
  return app.ctx.overview;
}

/**
 * 统一的异步加载：state = loading → content / empty / error。
 * fn 返回要 setData 的对象；返回 { __empty: true, ... } 表示空数据。
 * 连续触发时只采用最后一次的结果。silent=true 时不回到骨架（下拉刷新 / 返回页面时静默刷新）。
 */
async function load(page, fn, silent) {
  const seq = (page.__seq = (page.__seq || 0) + 1);
  if (!silent || !page.data.state || page.data.state === 'error') page.setData({ state: 'loading', error: '' });
  try {
    const data = (await fn()) || {};
    if (seq !== page.__seq) return;
    const empty = data.__empty;
    delete data.__empty;
    page.setData(Object.assign({}, data, { state: empty ? 'empty' : 'content', error: '' }));
  } catch (e) {
    if (seq !== page.__seq) return;
    if (e && e.type === 'auth') return; // 已跳转登录页
    page.setData({ state: 'error', error: (e && e.message) || '加载失败，请重试' });
  }
}

function toast(title) {
  wx.showToast({ title, icon: 'none', duration: 2400 });
}

function go(url) {
  const tabs = ['/pages/home/home', '/pages/book/book', '/pages/mine/mine'];
  if (tabs.indexOf(url.split('?')[0]) >= 0) wx.switchTab({ url });
  else wx.navigateTo({ url });
}

/** 返回上一页；没有上一页（分享 / 直达）时回首页。 */
function back(fallback) {
  if (getCurrentPages().length > 1) wx.navigateBack();
  else wx.switchTab({ url: fallback || '/pages/home/home' });
}

/** 每次提交一个新的请求标识；失败重试沿用同一个，服务端据此幂等。 */
function newRequestId() {
  const h = '0123456789abcdef';
  let s = '';
  for (let i = 0; i < 32; i++) s += h[Math.floor(Math.random() * 16)];
  return s.slice(0, 8) + '-' + s.slice(8, 12) + '-4' + s.slice(13, 16) + '-a' + s.slice(17, 20) + '-' + s.slice(20);
}

module.exports = { requireLogin, currentStore, switchStore, overview, load, toast, go, back, newRequestId };
