"""Archive paths arrive from SSH and are extracted as root: validate the boundary."""
import importlib.util
from pathlib import Path
import sys
import tarfile
import unittest

# The deployment runtime is Linux; this module's archive validation is portable.
if sys.platform == 'win32':
    import types
    sys.modules.setdefault('fcntl', types.ModuleType('fcntl'))
spec = importlib.util.spec_from_file_location('production', Path(__file__).with_name('production.py'))
production = importlib.util.module_from_spec(spec)
spec.loader.exec_module(production)


def member(name, kind=tarfile.REGTYPE):
    value = tarfile.TarInfo(name)
    value.type = kind
    return value


class ArchiveValidation(unittest.TestCase):
    def valid(self):
        return [member('release.json'), member('supabase/functions/merchant-v1/index.ts')]

    def test_valid_archive(self):
        production.validate_members(self.valid() + [member('supabase/migrations/202611010002_merchant_v1.sql')])

    def test_reject_unsafe_members(self):
        for path, kind in [
            ('/etc/cron.d/payload', tarfile.REGTYPE),
            ('supabase/functions/merchant-v1/../../../../etc/cron.d/payload.ts', tarfile.REGTYPE),
            ('supabase/functions/merchant-v1/link.ts', tarfile.SYMTYPE),
            ('supabase/functions/merchant-v1/link.ts', tarfile.LNKTYPE),
            ('supabase/.env', tarfile.REGTYPE),
        ]:
            with self.subTest(path=path), self.assertRaises(ValueError):
                production.validate_members(self.valid() + [member(path, kind)])

    def test_reject_duplicates(self):
        with self.assertRaises(ValueError):
            production.validate_members(self.valid() + [member('release.json')])

    def test_reject_expanded_size_limit(self):
        members = self.valid()
        members[1].size = production.MAX_EXPANDED + 1
        with self.assertRaises(ValueError):
            production.validate_members(members)


if __name__ == '__main__':
    unittest.main()
