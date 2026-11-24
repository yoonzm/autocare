import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import appointment_reminders as runner


class ReminderTimerTest(unittest.TestCase):
    def test_authenticated_request_uses_server_credentials(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / '.env').write_text('SERVICE_ROLE_KEY=test-key\nSUPABASE_PUBLIC_URL=https://example.test/\n')
            with patch.object(runner, 'PROJECT', root), patch.object(runner.urllib.request, 'urlopen') as send:
                send.return_value.__enter__.return_value = io.BytesIO(json.dumps({'ok': True, 'item': {'count': 2}}).encode())
                with patch('sys.stdout', new_callable=io.StringIO) as output:
                    runner.run()
                req = send.call_args.args[0]
                self.assertEqual(req.full_url, 'https://example.test/functions/v1/merchant-v1')
                self.assertEqual(req.get_header('Authorization'), 'Bearer test-key')
                self.assertEqual(json.loads(req.data), {'action': 'appointment_reminders_run'})
                self.assertNotIn('test-key', output.getvalue())
                self.assertIn('2', output.getvalue())

    def test_failure_response_is_not_reported_as_success(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / '.env').write_text('SERVICE_ROLE_KEY=test-key\nSUPABASE_PUBLIC_URL=https://example.test\n')
            with patch.object(runner, 'PROJECT', root), patch.object(runner.urllib.request, 'urlopen') as send:
                send.return_value.__enter__.return_value = io.BytesIO(b'{"error":"failed"}')
                with self.assertRaises(RuntimeError):
                    runner.run()


if __name__ == '__main__':
    unittest.main()
