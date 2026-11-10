// 统一的数据视图状态：loading（骨架，顶部对齐）/ error（可重试）/ empty / content（slot）。
// 规范：docs/frontend-guidelines.md 第 3~5 节；骨架贴着顶部、不居中，行数与真实列表一致。
Component({
  options: { styleIsolation: 'apply-shared' },
  properties: {
    state: { type: String, value: 'loading' },
    error: { type: String, value: '' },
    // list 行式骨架 / cards 卡片式 / hero 顶部大卡 + 列表
    skeleton: { type: String, value: 'list' },
    rows: { type: Number, value: 4 },
    emptyIcon: { type: String, value: 'list' },
    emptyTitle: { type: String, value: '暂无数据' },
    emptyText: { type: String, value: '' },
  },
  data: { items: [0, 1, 2, 3, 4, 5] },
  observers: {
    rows(n) {
      this.setData({ items: Array.from({ length: Math.min(Math.max(n, 1), 8) }, (_, i) => i) });
    },
  },
  methods: {
    onRetry() {
      this.triggerEvent('retry');
    },
  },
});
