const api = require('../../utils/api');
const session = require('../../utils/session');
const { toast } = require('../../utils/page');

Page({
  data: { busy: false },

  onShow() {
    // 已有有效会话直接进首页
    if (session.get()) wx.switchTab({ url: '/pages/home/home' });
  },

  // 微信手机号授权：button open-type="getPhoneNumber" 回调。手机号由服务端用一次性 code 向微信换取，
  // 小程序拿不到明文手机号，也不能自己上报手机号。
  onPhone(e) {
    if (this.data.busy) return;
    const phoneCode = e.detail && e.detail.code;
    if (!phoneCode) {
      toast('需要授权手机号才能登录');
      return;
    }
    this.setData({ busy: true });
    wx.login({
      success: (res) => {
        api
          .login(res.code, phoneCode)
          .then((body) => {
            const app = getApp();
            session.save(body.item);
            app.ctx = { stores: null, storeId: session.storeId(), overview: null, booking: null };
            wx.switchTab({ url: '/pages/home/home' });
          })
          .catch((err) => toast(err.message))
          .then(() => this.setData({ busy: false }));
      },
      fail: () => {
        this.setData({ busy: false });
        toast('微信登录失败，请重试');
      },
    });
  },
});
