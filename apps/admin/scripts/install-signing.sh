#!/bin/bash
set -euo pipefail
umask 077

printf '%s' "$BUILD_CERTIFICATE_BASE64" | base64 --decode > "$RUNNER_TEMP/signing.p12"
printf '%s' "$ADMIN_BUILD_PROVISION_PROFILE_BASE64" | base64 --decode > "$RUNNER_TEMP/profile.mobileprovision"
security cms -D -i "$RUNNER_TEMP/profile.mobileprovision" > "$RUNNER_TEMP/profile.plist"

python3 - <<'PY'
import datetime
import os
import pathlib
import plistlib

temp = pathlib.Path(os.environ['RUNNER_TEMP'])
profile = plistlib.loads((temp / 'profile.plist').read_bytes())
team = '6F7QRYSM6W'
bundle = 'com.yoonzm.autocare.admin'
assert team in profile['TeamIdentifier'], 'Provisioning profile team mismatch'
assert profile['Entitlements']['application-identifier'] == f'{team}.{bundle}', 'Bundle ID mismatch'
assert not profile['Entitlements'].get('get-task-allow', False), 'Development profile is not supported'
assert 'ProvisionedDevices' not in profile and not profile.get('ProvisionsAllDevices'), 'App Store profile required'
assert profile['ExpirationDate'] > datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None), 'Profile expired'
uuid = profile['UUID']
with open(os.environ['GITHUB_ENV'], 'a') as output:
    output.write(f'PROFILE_UUID={uuid}\n')
options = {
    'method': 'app-store-connect',
    'destination': 'export',
    'teamID': team,
    'signingStyle': 'manual',
    'signingCertificate': 'Apple Distribution',
    'provisioningProfiles': {bundle: uuid},
    'manageAppVersionAndBuildNumber': False,
    'testFlightInternalTestingOnly': True,
    'uploadSymbols': True,
}
(temp / 'ExportOptions.plist').write_bytes(plistlib.dumps(options))
directory = pathlib.Path.home() / 'Library/MobileDevice/Provisioning Profiles'
directory.mkdir(parents=True, exist_ok=True)
(directory / f'{uuid}.mobileprovision').write_bytes((temp / 'profile.mobileprovision').read_bytes())
PY

keychain_path="$RUNNER_TEMP/autocare-signing.keychain-db"
keychain_password="$(openssl rand -hex 24)"
echo "::add-mask::$keychain_password"
security create-keychain -p "$keychain_password" "$keychain_path"
security set-keychain-settings -lut 21600 "$keychain_path"
security unlock-keychain -p "$keychain_password" "$keychain_path"
security import "$RUNNER_TEMP/signing.p12" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$keychain_path"
security set-key-partition-list -S apple-tool:,apple: -k "$keychain_password" "$keychain_path" >/dev/null
security list-keychains -d user -s "$keychain_path"
