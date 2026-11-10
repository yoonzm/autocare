// 会员会话与当前门店：只存在本机存储里。令牌明文只此一份，服务端只存哈希。
const KEY = 'autocare.member.session';
const STORE_KEY = 'autocare.member.store';

function read(key) {
  try {
    return wx.getStorageSync(key) || null;
  } catch (e) {
    return null;
  }
}
function write(key, value) {
  try {
    if (value == null) wx.removeStorageSync(key);
    else wx.setStorageSync(key, value);
  } catch (e) {
    // 存储不可用（极少见）时本次进程内仍可用，只是下次要重新登录
  }
}

/** 小程序码 scene（32 位十六进制）或 query.s（带连字符）-> 门店编号；无效返回 null。 */
function storeFromLaunch(options) {
  const query = (options && options.query) || {};
  const raw = decodeURIComponent(String(query.scene || query.s || '')).trim().toLowerCase();
  const hex = raw.replace(/-/g, '');
  if (!/^[0-9a-f]{32}$/.test(hex)) return null;
  return [hex.slice(0, 8), hex.slice(8, 12), hex.slice(12, 16), hex.slice(16, 20), hex.slice(20)].join('-');
}

let memory = null;
module.exports = {
  storeFromLaunch,
  get() {
    if (memory) return memory;
    const saved = read(KEY);
    if (saved && saved.token && (!saved.expires_at || Date.parse(saved.expires_at) > Date.now())) memory = saved;
    return memory;
  },
  save(session) {
    memory = { token: session.token, phone: session.phone, masked_phone: session.masked_phone, expires_at: session.expires_at };
    write(KEY, memory);
  },
  clear() {
    memory = null;
    write(KEY, null);
    write(STORE_KEY, null);
  },
  storeId() {
    return read(STORE_KEY);
  },
  setStoreId(id) {
    write(STORE_KEY, id);
  },
};
