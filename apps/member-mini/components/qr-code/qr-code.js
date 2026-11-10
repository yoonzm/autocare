// 二维码：离线生成（utils/qrcode.js，MIT），canvas 2d 绘制。内容变化时重绘。
const qrcode = require('../../utils/qrcode');

Component({
  properties: {
    text: { type: String, value: '' },
    // 画布边长，单位 rpx
    size: { type: Number, value: 420 },
  },
  observers: {
    text() {
      this.draw();
    },
  },
  lifetimes: {
    ready() {
      this.draw();
    },
  },
  methods: {
    draw() {
      if (!this.data.text) return;
      this.createSelectorQuery()
        .select('#qr')
        .fields({ node: true, size: true })
        .exec((res) => {
          const target = res && res[0];
          if (!target || !target.node) return;
          const canvas = target.node;
          const ctx = canvas.getContext('2d');
          const dpr = wx.getWindowInfo().pixelRatio || 2;
          canvas.width = target.width * dpr;
          canvas.height = target.height * dpr;
          ctx.scale(dpr, dpr);
          const qr = qrcode(0, 'M');
          qr.addData(this.data.text);
          qr.make();
          const n = qr.getModuleCount();
          const margin = 2;
          const cell = target.width / (n + margin * 2);
          ctx.fillStyle = '#FFFFFF';
          ctx.fillRect(0, 0, target.width, target.height);
          ctx.fillStyle = '#18181B';
          for (let r = 0; r < n; r++) {
            for (let c = 0; c < n; c++) {
              if (qr.isDark(r, c)) ctx.fillRect((c + margin) * cell, (r + margin) * cell, Math.ceil(cell), Math.ceil(cell));
            }
          }
        });
    },
  },
});
