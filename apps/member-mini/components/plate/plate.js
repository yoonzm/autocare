const { plateText } = require('../../utils/format');

Component({
  options: { styleIsolation: 'apply-shared' },
  properties: {
    plate: { type: String, value: '' },
    energy: { type: String, value: '' },
  },
  data: { text: '', ev: false },
  observers: {
    'plate,energy'(plate, energy) {
      this.setData({ text: plateText(plate), ev: energy === 'ev' || String(plate).length === 8 });
    },
  },
});
