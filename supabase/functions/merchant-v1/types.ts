export type CatalogKind =
  | 'services'
  | 'cards'
  | 'packages'
  | 'members'
  | 'vehicles'
  | 'member_packages'
  | 'orders'
  | 'follow_ups';
export const isCatalogKind = (value: unknown): value is CatalogKind =>
  value === 'services' || value === 'cards' || value === 'packages' || value === 'members' ||
  value === 'vehicles' || value === 'member_packages' || value === 'orders' || value === 'follow_ups';

export interface StoreRow {
  id: string;
  owner_id: string;
  name: string;
  phone: string | null;
}

export interface ServiceItemRow {
  id: string;
  store_id: string;
  name: string;
  category: string;
  description: string;
  price: number;
  active: boolean;
  created_at: string;
}

/** 预设名（black / champagne / silver / blue / white）或自定义的 `#RRGGBB`。 */
export type CardColor = string;
export type CardValidity = 'forever' | '1y' | '2y';

export interface CardTypeRow {
  id: string;
  store_id: string;
  name: string;
  description: string;
  discount: number;
  active: boolean;
  created_at: string;
  color: CardColor;
  upgrade_recharge: number | null;
  upgrade_cumulative: number | null;
  points_multiplier: number;
  birthday_gift: string;
  priority_booking: boolean;
  validity: CardValidity;
}

export interface PackageRow {
  id: string;
  store_id: string;
  name: string;
  price: number;
  validity_months: number;
  purchase_limit: number | null;
  vehicle_scope: string;
  show_in_mini: boolean;
  description: string;
  active: boolean;
  deleted_at: string | null;
  created_at: string;
  items: {
    service_id: string;
    count: number;
    position: number;
    service: { name: string; price: number; active: boolean } | null;
  }[];
}

export interface CardRules {
  auto_upgrade: boolean;
  balance_refundable: boolean;
}

export type AuthAction =
  | { action: 'send_code'; phone: string; purpose: import('./sms_types.ts').SmsPurpose }
  | { action: 'check_code'; phone: string; code: string }
  | { action: 'forgot_verify'; phone: string; code: string }
  | { action: 'reset_password'; phone: string; code: string; new_password: string }
  | { action: 'register'; phone: string; code: string; password: string; store_name: string }
  | { action: 'login_password'; phone: string; password: string }
  | { action: 'login_code'; phone: string; code: string }
  | { action: 'get_store' }
  | { action: 'change_password'; old_password: string; new_password: string }
  | { action: 'change_phone'; code: string; new_phone: string; new_code: string }
  | { action: 'delete_account'; code: string };

export interface StoreProfileRow {
  name: string;
  phone: string | null;
  city: string;
  address: string;
  contact_name: string;
  contact_role: string;
  bay_range: string;
  business_types: string[];
  plan: string;
  trial_ends_at: string | null;
  delete_requested_at: string | null;
}

export type CatalogAction =
  | { action: 'list'; kind: CatalogKind }
  | { action: 'save'; kind: 'services'; id?: string; name: string; category: string; description: string; price: number }
  | {
    action: 'save'; kind: 'cards'; id?: string; name: string; description?: string; discount: number;
    color?: CardColor; upgrade_recharge?: number | null; upgrade_cumulative?: number | null;
    points_multiplier?: number; birthday_gift?: string; priority_booking?: boolean; validity?: CardValidity;
  }
  | { action: 'rules'; kind: 'cards' }
  | { action: 'save_rules'; kind: 'cards'; auto_upgrade: boolean; balance_refundable: boolean }
  | { action: 'delete'; kind: CatalogKind; id: string };

export type MerchantAction = AuthAction | CatalogAction;
export type Input = Record<string, unknown>;

export type ApiResponse =
  | { ok: true }
  | { ok: true; services: number; products: number; cards: number; packages: number; bays: number }
  | { ok: true; retry_after: number; expires_in: number }
  | { matched: boolean; plate: string; vehicle_model: string; vehicle_color: string; plate_color: string; member?: unknown; package_summary?: string; last_visit_text?: string }
  | { access_token: string; refresh_token: string }
  | { store: StoreProfileRow }
  | { items: ServiceItemRow[] | CardTypeRow[] | PackageRow[] | unknown[]; counts?: Record<string, number>; total?: number; matched?: number; total_balance?: number; new_this_month?: number }
  | { rules: CardRules }
  | { item: ServiceItemRow | CardTypeRow | PackageRow | unknown }
  | { error: string };
