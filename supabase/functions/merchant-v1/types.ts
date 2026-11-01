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
  | { action: 'register'; phone: string; code: string; password: string; store_name: string }
  | { action: 'login_password'; phone: string; password: string }
  | { action: 'login_code'; phone: string; code: string };

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
  | { items: ServiceItemRow[] | CardTypeRow[] }
  | { item: ServiceItemRow | CardTypeRow }
  | { error: string };
