const { iconUri } = require('../../utils/svg');
const K = 750 / 390;

Component({
  options: { styleIsolation: 'apply-shared' },
  properties: {
    name: { type: String, value: '' },
    size: { type: Number, value: 24 },
    color: { type: String, value: '#18181B' },
    stroke: { type: Number, value: 1.8 },
  },
  data: { src: '', box: 0 },
  observers: {
    'name,size,color,stroke'(name, size, color, stroke) {
      this.setData({ src: iconUri(name, color, 48, stroke), box: Math.round(size * K * 100) / 100 });
    },
  },
});
