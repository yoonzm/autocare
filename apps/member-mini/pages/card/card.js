const api = require('../../utils/api');
const f = require('../../utils/format');
const v = require('../../utils/view');
const page = require('../../utils/page');

Page({
  data: { state: 'loading', error: '', m: null, steps: [], benefits: [], hint: '', progress: 0, levelName: '' },
  onShow() { if (page.requireLogin()) this.reload(this.data.state === 'content'); },
  reload(silent) {
    page.load(this, async () => {
      const store = await page.currentStore();
      if (!store) return { __empty: true };
      const [ov, card] = await Promise.all([page.overview(true), api.card(store)]);
      const m = ov.member;
      const lad = v.ladder(card.item.tiers, m);
      return {
        m: { name: m.name, level: m.level.name, phone: f.maskPhone(m.phone), joined: '入会 ' + f.ymd(m.joined_at).slice(0, 7), points: f.int(m.points) },
        steps: lad.steps, hint: lad.hint, progress: lad.progress,
        benefits: v.benefits(lad.current), levelName: lad.current.name,
      };
    }, silent);
  },
  onRetry() { this.reload(false); },
  points() { page.go('/pages/orders/orders'); },
});
