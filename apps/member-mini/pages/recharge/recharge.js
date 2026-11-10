const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

// TODO: 线上储值充值需要微信支付商户号（服务商进件，见 docs/backend-integration.md「开通微信支付」）与支付回调
// （预期后端：payment_create 创建预支付订单、payment_callback 验签后在事务里入账并写 member_ledger，复用 recharge_member 的赠送规则）。
// 支付渠道开通前 mb_recharge 明确返回“线上支付暂未开通”，本页不创建订单、不入账，也不跳转成功页。
Page({
  data: { state: 'loading', error: '', balance: '', discount: '', presets: [], amount: 0, online: false, busy: false, gift: 0 },
  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content'); },
  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      const [ov, rc] = await Promise.all([page.overview(true), api.rechargeOptions(store)]);
      const presets = rc.item.presets.map((p, i) => ({ amount: p.amount, gift: p.gift, label: f.yuan(p.amount), giftText: p.gift ? '送 ' + f.yuan(p.gift) : '', rec: i === 0 }));
      const pick = this.data.amount && presets.some((p) => p.amount === this.data.amount) ? this.data.amount : (presets[0] || {}).amount || 0;
      return { balance: f.money2(ov.member.balance), discount: v.discountText(ov.member.level.discount), presets, online: rc.item.online, ...this.sum(presets, pick) };
    }, silent);
  },
  sum(presets, amount) {
    const hit = presets.find((p) => p.amount === amount);
    return { amount, gift: hit ? hit.gift : 0 };
  },
  onRetry() { this.reload(false); },
  pick(e) { this.setData(this.sum(this.data.presets, Number(e.currentTarget.dataset.amount))); },
  // TODO: 自定义金额需要设计稿里的输入界面（目前只有“其他金额”按钮），待确认后接入；赠送只对档位生效。
  other() { page.toast('自定义金额暂未开放，请选择档位'); },
  pay() {
    if (this.data.busy || !this.data.amount) return;
    this.setData({ busy: true });
    api.recharge(getApp().ctx.storeId, this.data.amount)
      .then(() => page.toast('请到店完成充值'))
      .catch((err) => page.toast(err.message))
      .then(() => this.setData({ busy: false }));
  },
});
