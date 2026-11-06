import importlib.util
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('bootstrap_admin',Path(__file__).with_name('bootstrap_admin.py'))
module=importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class Bootstrap(unittest.TestCase):
    def test_initial_credentials_are_generated_and_profile_requires_change(self):
        calls=[]
        def request(method,path,body=None):
            calls.append((method,path,body))
            return [] if method=='GET' else {'id':'auth-id'}
        name,password=module.bootstrap('unused','unused',request=request)
        self.assertEqual(name,'superman')
        self.assertGreaterEqual(len(password),24)
        self.assertEqual(calls[2][2]['role'],'superAdmin')
        self.assertTrue(calls[2][2]['must_change'])
        self.assertNotIn('password',calls[2][2])

    def test_existing_account_is_never_reset(self):
        def request(method,path,body=None):
            self.assertEqual(method,'GET')
            return [{'id':'existing'}]
        with self.assertRaisesRegex(RuntimeError,'already exists'):
            module.bootstrap('unused','unused',request=request)
