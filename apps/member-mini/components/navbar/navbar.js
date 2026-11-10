// 自定义导航栏：避开状态栏和微信右上角胶囊；左侧返回键，右侧留出胶囊宽度，保证标题居中。
Component({
  options: { styleIsolation: 'apply-shared', multipleSlots: true },
  properties: {
    title: { type: String, value: '' },
    back: { type: Boolean, value: true },
    // 返回键不可用（例如提交中）
    locked: { type: Boolean, value: false },
  },
  data: { top: 44, height: 44, side: 87 },
  lifetimes: {
    attached() {
      let top = 44;
      let height = 32;
      let side = 87;
      try {
        const win = wx.getWindowInfo();
        const menu = wx.getMenuButtonBoundingClientRect();
        const status = win.statusBarHeight || 20;
        const gap = Math.max(menu.top - status, 4);
        top = status + gap;
        height = Math.max(menu.height, 44);
        side = Math.max(win.windowWidth - menu.left + 8, 87);
        // px -> 组件内统一用 px（导航栏尺寸来自系统，不按设计稿缩放）
        this.setData({ top, height, side });
        return;
      } catch (e) {
        // 取不到系统信息（极少）：用设计稿的默认尺寸
      }
      this.setData({ top, height, side });
    },
  },
  methods: {
    onBack() {
      if (this.data.locked) return;
      this.triggerEvent('back');
    },
  },
});
