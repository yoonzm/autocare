import type { SupabaseClient } from './deps.ts';

export type Input = Record<string, unknown>;

export interface AdminAccount {
  id: string;
  username: string;
  name: string;
  role: 'superAdmin' | 'ops';
  enabled: boolean;
  must_change: boolean;
}

export interface RpcError {
  code?: string;
  message: string;
}

export type CommandResult =
  | { data: Record<string, unknown>; error: null }
  | { data: null; error: RpcError };

/** Runtime dependencies are injectable for isolated tests, never a mock fallback. */
export interface AdminServices {
  db: SupabaseClient;
  publicClient: () => SupabaseClient;
  sendLoginCode: (
    phone: string,
    requestId: string,
  ) => Promise<Record<string, unknown>>;
}

export interface ReadContext {
  services: AdminServices;
  me: AdminAccount;
  sessionId: string;
}

export interface WriteContext extends ReadContext {
  requestId: string;
  command: (
    action: string,
    values: Input,
    sessionId?: string,
  ) => Promise<CommandResult>;
}
