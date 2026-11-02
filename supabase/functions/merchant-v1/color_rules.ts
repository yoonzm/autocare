// 卡面颜色：系统默认配色（预设名）或自定义的 `#RRGGBB`。

export const PRESET_CARD_COLORS = ['black', 'champagne', 'silver', 'blue', 'white'] as const;

export const isCardColor = (value: unknown): value is string =>
  typeof value === 'string' &&
  ((PRESET_CARD_COLORS as readonly string[]).includes(value) || /^#[0-9a-fA-F]{6}$/.test(value));

/** 自定义颜色统一存大写，便于比较。 */
export const normalizeCardColor = (value: string) => (value.startsWith('#') ? value.toUpperCase() : value);
