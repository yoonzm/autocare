"""Verify public static legal pages and unchanged API authentication."""
import argparse
from pathlib import Path
import urllib.error
import urllib.request


def check(base_url, expected_directory=None):
    failures = []
    cases = [
        ('GET', '/legal/privacy.html', 200),
        ('GET', '/legal/terms.html', 200),
        ('GET', '/legal/privacy.html?source=store', 200),
        ('HEAD', '/legal/privacy.html', 200),
        ('POST', '/legal/privacy.html', 404),
        ('GET', '/legal/unknown.html', 404),
        ('GET', '/legal/privacy.html/extra', 404),
        ('GET', '/functions/v1/merchant-v1/legal/privacy', 401),
        ('GET', '/functions/v1/merchant-v1/legal/terms', 401),
        ('POST', '/functions/v1/merchant-v1', 401),
        ('POST', '/functions/v1/admin-v1', 401),
        ('POST', '/functions/v1/member-v1', 401),
    ]
    for method, path, expected in cases:
        request = urllib.request.Request(
            base_url.rstrip('/') + path, method=method,
            data=b'{}' if method == 'POST' else None,
        )
        try:
            response = urllib.request.urlopen(request, timeout=20)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            body = response.read()
            valid = response.status == expected
            if expected == 200:
                valid &= 'text/html' in response.headers.get('Content-Type', '')
                valid &= response.headers.get('X-Content-Type-Options') == 'nosniff'
                valid &= "default-src 'none'" in response.headers.get('Content-Security-Policy', '')
                if method == 'GET':
                    valid &= b'<!doctype html>' in body.lower() and b'<h1>' in body
                    if expected_directory:
                        filename = path.split('?', 1)[0].rsplit('/', 1)[1]
                        valid &= body == (Path(expected_directory) / filename).read_bytes()
            print(f'{"PASS" if valid else "FAIL"} {method} {path}: {response.status}', flush=True)
            if not valid:
                failures.append(f'{method} {path}')
    if failures:
        raise RuntimeError('Static legal/auth checks failed: ' + ', '.join(failures))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base-url', default='https://autocare.mymember.ltd')
    parser.add_argument('--expected-directory')
    args = parser.parse_args()
    check(args.base_url, args.expected_directory)
