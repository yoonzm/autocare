const api = require('../../utils/api');
const page = require('../../utils/page');

// 车身颜色：存名称（后端 color 为文本），色块只用于选择
const COLORS = [
  ['黑色', '#18181B'], ['白色', '#FFFFFF'], ['银色', '#C9CDD2'], ['灰色', '#8E8E93'], ['红色', '#C0392B'], ['蓝色', '#1E63AE'],
  ['棕色', '#6B4A2B'], ['香槟色', '#CDB68A'], ['绿色', '#2B7745'], ['橙色', '#E8761A'], ['紫色', '#6B46C1'],
];
const PLATE = /^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼][A-Z][A-Z0-9]{5,6}$/;

Page({
  data: { cells: [], plate: '', focus: false, brand: '', color: '黑色', colors: COLORS, isDefault: false, busy: false, ev: false },
  onShow() { page.requireLogin(); this.cells(''); },

  cells(plate) {
    const chars = plate.split('');
    const ev = chars.length >= 8;
    // 前两格（省份 + 发牌机关）后面有分隔点，之后 5 格（燃油）/ 6 格（新能源）
    const total = ev ? 8 : 7;
    const cells = [];
    for (let i = 0; i < total; i++) cells.push({ c: chars[i] || '', cur: i === chars.length, ev: ev && i === 7 });
    this.setData({ cells, plate, ev });
  },
  onInput(e) {
    const plate = String(e.detail.value || '').replace(/[\s·.]/g, '').toUpperCase().slice(0, 8);
    this.cells(plate);
    return plate;
  },
  focusInput() { this.setData({ focus: true }); },
  onBlur() { this.setData({ focus: false }); },
  onBrand(e) { this.setData({ brand: e.detail.value }); },
  pickColor(e) { this.setData({ color: e.currentTarget.dataset.c }); },
  toggleDefault() { this.setData({ isDefault: !this.data.isDefault }); },

  save() {
    if (this.data.busy) return;
    const { plate, brand, color, isDefault, ev } = this.data;
    if (!PLATE.test(plate)) return page.toast('请输入正确的车牌号');
    if ((ev && plate.length !== 8) || (!ev && plate.length !== 7)) return page.toast(ev ? '新能源车牌为 8 位' : '燃油车牌为 7 位');
    if (!brand.trim()) return page.toast('请填写品牌车型');
    this.setData({ busy: true });
    api.saveVehicle(getApp().ctx.storeId, { plate, brand_model: brand.trim(), color, is_default: isDefault }).then((res) => {
      const booking = getApp().ctx.booking;
      if (booking) booking.vehicleId = res.item.id; // 预约途中新增的车辆直接用于本次预约
      page.toast('已添加');
      wx.navigateBack();
    }).catch((e) => page.toast(e.message)).then(() => this.setData({ busy: false }));
  },
  back() { if (!this.data.busy) page.back('/pages/cars/cars'); },
});
