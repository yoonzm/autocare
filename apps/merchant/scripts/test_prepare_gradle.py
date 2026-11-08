import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
from urllib.error import HTTPError

spec = importlib.util.spec_from_file_location('prepare_gradle', Path(__file__).with_name('prepare-gradle.py'))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class PrepareGradleTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.wrapper = self.root / 'gradle-wrapper.properties'
        self.payload = b'verified fixture distribution'
        self.url = 'https://downloads.gradle.org/distributions/gradle-9.3.1-bin.zip'
        self.source = ('distributionBase=GRADLE_USER_HOME\n'
                       f'distributionUrl={self.url}\n'
                       f'distributionSha256Sum={hashlib.sha256(self.payload).hexdigest()}\n')
        self.wrapper.write_text(self.source)
        self.cache = self.root / 'cache with spaces'
        self.calls = 0

    def fetch(self, url, destination):
        self.assertEqual(url, self.url)
        self.calls += 1
        destination.write_bytes(self.payload)

    def test_retries_gateway_failure_and_uses_verified_local_archive(self):
        def fetch(url, destination):
            if self.calls == 0:
                self.calls += 1
                destination.write_bytes(b'partial download')
                raise HTTPError(url, 504, 'Gateway Timeout', {}, None)
            self.fetch(url, destination)
        archive = module.prepare(self.wrapper, self.cache, fetch, lambda _: None)
        self.assertEqual(self.calls, 2)
        self.assertEqual(archive.read_bytes(), self.payload)
        self.assertIn(f'distributionUrl={archive.as_uri()}', self.wrapper.read_text())
        self.assertIn('%20', archive.as_uri())
        self.assertEqual(list(self.cache.glob('*.part')), [])

    def test_valid_cache_avoids_network(self):
        archive = module.prepare(self.wrapper, self.cache, self.fetch)
        self.wrapper.write_text(self.source)
        module.prepare(self.wrapper, self.cache, lambda *_: self.fail('cache must avoid network'))
        self.assertEqual(archive.read_bytes(), self.payload)
        self.assertEqual(self.calls, 1)

    def test_bad_cache_is_replaced_only_with_verified_bytes(self):
        self.cache.mkdir()
        (self.cache / 'gradle-9.3.1-bin.zip').write_bytes(b'corrupt cache')
        archive = module.prepare(self.wrapper, self.cache, self.fetch)
        self.assertEqual(archive.read_bytes(), self.payload)
        self.assertEqual(self.calls, 1)

    def test_checksum_failure_never_changes_wrapper_or_caches_partial(self):
        def bad_fetch(_, destination):
            self.calls += 1
            destination.write_bytes(b'wrong distribution')
        with self.assertRaisesRegex(RuntimeError, 'after 4 attempts'):
            module.prepare(self.wrapper, self.cache, bad_fetch, lambda _: None)
        self.assertEqual(self.calls, 4)
        self.assertEqual(self.wrapper.read_text(), self.source)
        self.assertEqual(list(self.cache.iterdir()), [])

    def test_missing_checksum_fails_before_network(self):
        self.wrapper.write_text(f'distributionUrl={self.url}\n')
        with self.assertRaisesRegex(ValueError, 'SHA-256'):
            module.prepare(self.wrapper, self.cache, self.fetch)
        self.assertEqual(self.calls, 0)


if __name__ == '__main__':
    unittest.main()
