"""Archive paths arrive from SSH and are extracted as root: validate the boundary."""
import importlib.util
import base64
import hashlib
import posixpath
from pathlib import Path
import re
import sys
import tarfile
import tempfile
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
        production.validate_members(self.valid() + [member('supabase/functions/admin-v1/index.ts')])
        production.validate_members(self.valid() + [member('supabase/functions/member-v1/index.ts')])

    def test_member_migration_requires_function(self):
        with self.assertRaises(ValueError):
            production.validate_members(self.valid()+[member('supabase/migrations/202611100003_member_portal.sql')])
        production.validate_members(self.valid()+[member('supabase/migrations/202611100003_member_portal.sql'),member('supabase/functions/member-v1/index.ts')])

    def test_static_legal_pair_is_the_only_allowed_static_content(self):
        pages = [member('supabase/static/legal/' + name + '.html') for name in ['privacy', 'terms']]
        production.validate_members(self.valid() + pages)
        with self.assertRaises(ValueError):
            production.validate_members(self.valid() + pages[:1])
        for name in ['index.html', 'script.js', '../secret.html', 'nested/privacy.html']:
            with self.subTest(name=name), self.assertRaises(ValueError):
                production.validate_members(self.valid() + pages + [member('supabase/static/legal/' + name)])

    def test_package_rejects_duplicate_migration_versions(self):
        package_spec = importlib.util.spec_from_file_location('backend_package', Path(__file__).with_name('package.py'))
        package_tool = importlib.util.module_from_spec(package_spec)
        package_spec.loader.exec_module(package_tool)
        with self.assertRaisesRegex(ValueError, 'Duplicate migration version 202611200005'):
            package_tool.validate_migration_versions([
                Path('202611200005_manager_store_maintenance.sql'),
                Path('202611200005_manager_expense_permission.sql'),
            ])
        package_tool.validate_migration_versions([
            Path('202611200005_manager_store_maintenance.sql'),
            Path('202611200006_manager_expense_permission.sql'),
        ])

    def test_package_contains_static_pages_with_exact_content(self):
        package_spec = importlib.util.spec_from_file_location('backend_package', Path(__file__).with_name('package.py'))
        package_tool = importlib.util.module_from_spec(package_spec)
        package_spec.loader.exec_module(package_tool)
        root = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as directory:
            archive_path = Path(directory) / 'backend.tar.gz'
            package_tool.package('a' * 40, archive_path)
            with tarfile.open(archive_path) as archive:
                production.validate_members(archive.getmembers())
                for name in ['privacy', 'terms']:
                    path = 'supabase/static/legal/' + name + '.html'
                    content = (root / path).read_bytes().replace(b'\r\n', b'\n')
                    self.assertEqual(archive.extractfile(path).read(), content)
                    self.assertIn(b'<meta name="viewport"', content)
                    scripts = re.findall(rb'<script>(.*?)</script>', content, re.S)
                    self.assertEqual(len(scripts), 1)
                    digest = base64.b64encode(hashlib.sha256(scripts[0]).digest()).decode()
                    self.assertIn("script-src 'sha256-" + digest + "'", (root / 'supabase/deploy/legal.caddy').read_text())

    def test_member_function_is_self_contained(self):
        package_spec = importlib.util.spec_from_file_location('backend_package', Path(__file__).with_name('package.py'))
        package_tool = importlib.util.module_from_spec(package_spec)
        package_spec.loader.exec_module(package_tool)
        with tempfile.TemporaryDirectory(prefix='autocare-member-package-') as directory:
            archive_path = Path(directory) / 'backend.tar.gz'
            package_tool.package('b' * 40, archive_path)
            with tarfile.open(archive_path) as archive:
                production.validate_members(archive.getmembers())
                names = set(archive.getnames())
                self.assertIn('supabase/functions/member-v1/index.ts', names)
                checked = 0
                for name in names:
                    if not name.startswith('supabase/functions/member-v1/') or not name.endswith('.ts') or name.endswith('.test.ts'):
                        continue
                    source = archive.extractfile(name).read().decode('utf-8')
                    for relative in re.findall(r'''(?:from\s*|import\s*\(\s*)['"](\.[^'"]+\.ts)['"]''', source):
                        target = posixpath.normpath(posixpath.join(posixpath.dirname(name), relative))
                        # 函数按目录分别部署：运行时代码不得 import 其他函数目录（测试文件除外）
                        self.assertTrue(target.startswith('supabase/functions/member-v1/'), msg=f'{name} imports outside member-v1: {relative}')
                        self.assertIn(target, names, msg=f'{name} imports missing module {relative}')
                        checked += 1
                self.assertGreater(checked, 5)

    def test_admin_migration_requires_function(self):
        with self.assertRaises(ValueError):
            production.validate_members(self.valid()+[member('supabase/migrations/202611060004_admin_platform.sql')])

    def test_packaged_admin_function_contains_all_relative_imports(self):
        package_spec = importlib.util.spec_from_file_location('backend_package', Path(__file__).with_name('package.py'))
        package_tool = importlib.util.module_from_spec(package_spec)
        package_spec.loader.exec_module(package_tool)
        with tempfile.TemporaryDirectory(prefix='autocare-admin-package-') as directory:
            archive_path = Path(directory) / 'backend.tar.gz'
            package_tool.package('a' * 40, archive_path)
            with tarfile.open(archive_path) as archive:
                production.validate_members(archive.getmembers())
                names = set(archive.getnames())
                for name in names:
                    if not name.startswith('supabase/functions/admin-v1/') or not name.endswith('.ts'):
                        continue
                    source = archive.extractfile(name).read().decode('utf-8')
                    # Both static and literal dynamic imports must be deployable.
                    for relative in re.findall(r'''(?:from\s*|import\s*\(\s*)['"](\.[^'"]+\.ts)['"]''', source):
                        target = posixpath.normpath(posixpath.join(posixpath.dirname(name), relative))
                        self.assertIn(target, names, msg=f'{name} imports missing module {relative}')

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
