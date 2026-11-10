const api = require('../../utils/api');
const page = require('../../utils/page');

// TODO: 消息通知依赖微信订阅消息 / 短信通知渠道，服务端目前没有消息数据来源（预期后端：mb_notices 返回施工进度、预约确认、储值福利、
// 次卡到期、充值到账等消息，并在发送时记录送达状态）。接口已预留并返回空列表，这里如实显示“暂无消息”，不展示示例消息。
Page({
  data: { state: 'loading', error: '', groups: [] },
  onShow() { if (page.requireLogin()) this.reload(); },
  reload() {
    page.load(this, async () => {
      const res = await api.notices();
      return { groups: res.items || [], __empty: !(res.items && res.items.length) };
    });
  },
  onRetry() { this.reload(); },
});
