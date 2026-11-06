// Match merchant-v1's pinned SDK URL; self-hosted workers need no import map.
export {
  createClient,
  type SupabaseClient,
} from 'npm:@supabase/supabase-js@2.118.0';
