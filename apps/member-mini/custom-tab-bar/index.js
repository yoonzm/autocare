Component({
  options: { styleIsolation: 'apply-shared' },
  data: {
    selected: 0,
    list: [
      { url: '/pages/home/home', text: '首页', icon: 'shop' },
      { url: '/pages/book/book', text: '预约', icon: 'calendar' },
      { url: '/pages/mine/mine', text: '我的', icon: 'user' },
    ],
  },
  methods: {
    onTap(e) {
      const i = Number(e.currentTarget.dataset.i);
      if (i !== this.data.selected) wx.switchTab({ url: this.data.list[i].url });
    },
  },
});
