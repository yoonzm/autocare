export type CatalogKind = 'services' | 'cards';
export const isCatalogKind = (value: unknown): value is CatalogKind =>
  value === 'services' || value === 'cards';

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

export interface CardTypeRow {
  id: string;
  store_id: string;
  name: string;
  description: string;
  discount: number;
  active: boolean;
  created_at: string;
}

export type AuthAction =
  | { action: 'send_mock_code'; phone: string }
  | { action: 'check_code'; phone: string; code: string }
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
  | { action: 'save'; kind: 'cards'; id?: string; name: string; description: string; discount: number; active?: boolean }
  | { action: 'delete'; kind: CatalogKind; id: string };

export type MerchantAction = AuthAction | CatalogAction;
export type Input = Record<string, unknown>;

export type ApiResponse =
  | { ok: true }
  | { code: string; mock: true }
  | { access_token: string; refresh_token: string }
  | { store: StoreProfileRow }
  | { items: ServiceItemRow[] | CardTypeRow[] }
  | { item: ServiceItemRow | CardTypeRow }
  | { error: string };
