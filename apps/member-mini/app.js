const session = require('./utils/session');
const api = require('./utils/api');
const { storeFromLaunch } = require('./utils/session');

App({
  // 跨页面共享的运行时状态；持久化的只有会话令牌和当前门店（见 utils/session.js）
  ctx: { stores: null, storeId: null, overview: null, booking: null },

  onLaunch(options) {
    api.setAuthLostHandler(() => this.logout(true));
    // 扫门店码进入：小程序码 scene 为门店编号（32 位十六进制，scene 上限 32 字符，所以去掉了连字符）
    const id = storeFromLaunch(options);
    if (id) session.setStoreId(id);
  },

  /** 清理本机状态并回到登录页。lost=true 表示服务端判定登录失效。 */
  logout(lost) {
    session.clear();
    this.ctx = { stores: null, storeId: null, overview: null, booking: null };
    if (lost) wx.showToast({ title: '登录已过期，请重新登录', icon: 'none' });
    wx.reLaunch({ url: '/pages/auth/auth' });
  },
});
