export interface Region {
  code: string;
  name: string;
  parent_code: string | null;
  level: number;
}

export function cityProfile(rows: Region[], provinceCode: unknown, cityCode: unknown) {
  const province = rows.find((r) => r.code === provinceCode && r.level === 1);
  const city = rows.find((r) => r.code === cityCode && r.level === 2);
  if (!province || !city || city.parent_code !== province.code) return null;
  return {
    province_code: province.code,
    city_code: city.code,
    city: `${province.name} · ${city.name}`,
  };
}
