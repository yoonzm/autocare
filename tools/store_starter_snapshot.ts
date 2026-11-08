// Publish a NEW version if defaults change. Never mutate an applied migration.
import { storeStarterTemplate } from '../supabase/functions/merchant-v1/defaults.ts';
console.log(JSON.stringify(storeStarterTemplate(), null, 2));
