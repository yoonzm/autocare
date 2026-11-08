from types import SimpleNamespace
from pathlib import Path
from unittest import TestCase, mock
import bridge_dev_inventory as bridge


class LegacyInventoryBridgeTests(TestCase):
    def history(self):
        result = [{'version': p.name.split('_', 1)[0], 'name': p.stem.split('_', 1)[1]}
                  for p in (bridge.ROOT / 'supabase/migrations').glob('*.sql') if p.name < '202611060001']
        return result + [{'version': v, 'name': pair[0]} for v, pair in bridge.LEGACY.items()]

    def test_canonical_database_is_untouched(self):
        self.assertIsNone(bridge.plan(bridge.ROOT / 'supabase/migrations', []))

    def test_archives_match_published_migrations(self):
        self.assertEqual(len(bridge.legacy_files()), 2)

    def test_unknown_history_is_never_repaired(self):
        history = self.history() + [{'version': '202611059999', 'name': 'unknown'}]
        with self.assertRaisesRegex(ValueError, 'Unrecognized'):
            bridge.plan(bridge.ROOT / 'supabase/migrations', history)

    def test_wrong_legacy_name_is_never_repaired(self):
        history = self.history()
        history[-1]['name'] = 'different_migration'
        with self.assertRaisesRegex(ValueError, 'Unrecognized'):
            bridge.plan(bridge.ROOT / 'supabase/migrations', history)

    def test_completed_bridge_does_not_replay_migrations(self):
        history = self.history() + [{'version': bridge.TARGET, 'name': 'inventory_management'}]
        self.assertEqual(bridge.plan(bridge.ROOT / 'supabase/migrations', history), '')

    def test_production_connection_is_rejected_before_query(self):
        with mock.patch.dict('os.environ', {'SUPABASE_PROJECT_REF': 'production', 'SUPABASE_DB_URL': 'postgresql://postgres:unused@localhost/postgres'}):
            with mock.patch.object(bridge.subprocess, 'run') as run:
                with self.assertRaisesRegex(ValueError, 'restricted'):
                    bridge.main()
                run.assert_not_called()

    def test_metadata_query_keeps_password_out_of_process_arguments(self):
        password = 'test-only-password'
        url = 'postgresql://postgres.' + bridge.PROJECT + ':' + password + '@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres'
        with mock.patch.dict('os.environ', {'SUPABASE_PROJECT_REF': bridge.PROJECT, 'SUPABASE_DB_URL': url}):
            with mock.patch.object(bridge.subprocess, 'run', side_effect=[SimpleNamespace(returncode=0,stdout='t\n'),SimpleNamespace(returncode=0,stdout='[]')]) as run:
                bridge.main()
                for call in run.call_args_list:
                    self.assertNotIn(password, str(call.args))
                    self.assertEqual(call.kwargs['env']['PGPASSWORD'],password)
