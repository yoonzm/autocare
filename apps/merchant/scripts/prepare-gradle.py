"""Fetch and verify the pinned Gradle distribution before Flutter invokes its wrapper.

CI caches the ZIP. A local file URL keeps the legacy Flutter-generated wrapper
from making an un-retried network request of its own.
"""
import hashlib
from pathlib import Path
import re
import sys
import time
from urllib.request import urlopen


def download(url, destination):
    with urlopen(url, timeout=60) as response, destination.open('wb') as output:
        while chunk := response.read(1024 * 1024):
            output.write(chunk)


def checksum(path):
    with path.open('rb') as source:
        return hashlib.file_digest(source, 'sha256').hexdigest()


def prepare(wrapper, cache, fetch=download, pause=time.sleep):
    text = wrapper.read_text(encoding='utf-8')
    match = re.search(r'^distributionUrl=(.+)$', text, re.M)
    digest = re.search(r'^distributionSha256Sum=([0-9a-f]{64})$', text, re.M)
    if not match or not digest:
        raise ValueError('Gradle distribution URL and SHA-256 must both be pinned')
    url = match[1].replace('\\:', ':')
    filename = re.fullmatch(
        r'https://(?:downloads|services)\.gradle\.org/distributions/(gradle-[0-9.]+-bin\.zip)', url,
    )
    if not filename:
        raise ValueError('Expected an official, versioned Gradle binary distribution')
    cache.mkdir(parents=True, exist_ok=True)
    archive = cache / filename[1]
    if not archive.exists() or checksum(archive) != digest[1]:
        archive.unlink(missing_ok=True)
        partial = archive.with_suffix('.zip.part')
        for attempt in range(1, 5):
            try:
                fetch(url, partial)
                if checksum(partial) != digest[1]:
                    raise ValueError('Gradle SHA-256 mismatch')
                partial.replace(archive)
                break
            except (OSError, ValueError) as error:
                partial.unlink(missing_ok=True)
                if attempt == 4:
                    raise RuntimeError('Verified Gradle download failed after 4 attempts') from error
                print(f'Gradle download attempt {attempt} failed: {error}; retrying', flush=True)
                pause(attempt * 2)
    local_url = archive.resolve().as_uri()
    wrapper.write_text(text[:match.start(1)] + local_url + text[match.end(1):], encoding='utf-8')
    print(f'Gradle distribution verified: {archive.name}', flush=True)
    return archive


if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('Usage: prepare-gradle.py WRAPPER_PROPERTIES CACHE_DIRECTORY')
    prepare(Path(sys.argv[1]), Path(sys.argv[2]))
