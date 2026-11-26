import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import push_dispatch


class PushDispatch(unittest.TestCase):
    def invoke(self, payload):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / '.env').write_text('SERVICE_ROLE_KEY=secret-test-key\nSUPABASE_PUBLIC_URL=https://example.test\n')
            response = io.BytesIO(json.dumps(payload).encode())
            with patch.object(push_dispatch, 'PROJECT', root), \
                 patch.object(push_dispatch.urllib.request, 'urlopen', return_value=response) as send, \
                 contextlib.redirect_stdout(io.StringIO()) as output:
                push_dispatch.run()
            request = send.call_args.args[0]
            self.assertEqual(json.loads(request.data), {'action': 'push_dispatch_run'})
            self.assertEqual(request.get_header('Authorization'), 'Bearer secret-test-key')
            self.assertNotIn('secret-test-key', output.getvalue())

    def test_empty_configured_queue_succeeds(self):
        self.invoke({'ok': True, 'item': {'claimed': 0, 'sent': 0, 'failed': 0}})

    def test_missing_configuration_is_not_reported_as_success(self):
        with self.assertRaises(RuntimeError):
            self.invoke({'ok': True, 'item': {'reason': 'aliyun_push_not_configured'}})

    def test_provider_failures_fail_timer(self):
        with self.assertRaises(RuntimeError):
            self.invoke({'ok': True, 'item': {'claimed': 1, 'failed': 1}})


if __name__ == '__main__':
    unittest.main()
