const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', me: null, tel: '', logoutBusy: false },

  onShow() {
    if (!page.requireLogin()) return;
    const tab = this.getTabBar && this.getTabBar();
    if (tab) tab.setData({ selected: 2 });
    this.reload(this.data.state === 'content');
  },

  reload(silent) {
    page.load(
      this,
      async () => {
        const store = await page.currentStore();
        if (!store) return { __empty: true };
        const [ov, rc] = await Promise.all([page.overview(true), api.rechargeOptions(store)]);
        const m = ov.member;
        const first = rc.item.presets[0];
        return {
          tel: ov.store.phone || '',
          me: {
            initial: (m.name || '会').slice(0, 1),
            name: m.name,
            level: m.level.name,
            sub: f.maskPhone(m.phone) + ' · 入会 ' + f.ymd(m.joined_at).slice(0, 7),
            balance: f.yuan(m.balance),
            points: f.int(m.points),
            packages: ov.counts.packages + ' 张',
            waiting: ov.counts.waiting,
            working: ov.counts.in_progress,
            cars: ov.counts.vehicles + ' 辆',
            rechargeSub: rc.item.online ? (first ? '赠送 ' + f.yuan(first.gift) + ' 活动中' : '') : '线上支付暂未开通',
            packagesSub: ov.counts.packages + ' 张',
          },
        };
      },
      silent
    );
  },

  onRetry() { this.reload(false); },
  go(e) { page.go(e.currentTarget.dataset.url); },
  call() {
    if (this.data.tel) wx.makePhoneCall({ phoneNumber: this.data.tel });
    else page.toast('门店暂未登记电话');
  },
  logout() {
    if (this.data.logoutBusy) return;
    wx.showModal({
      title: '退出登录',
      content: '退出后需要重新授权手机号登录。',
      confirmColor: '#A43433',
      success: (res) => {
        if (!res.confirm) return;
        this.setData({ logoutBusy: true });
        // 服务端撤销会话；网络失败也要清掉本机登录态，避免用户以为已退出
        api.logout().catch(() => {}).then(() => {
          this.setData({ logoutBusy: false });
          getApp().logout(false);
        });
      },
    });
  },
});
