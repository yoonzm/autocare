"""Create the requested initial administrator; never put passwords in a migration.

Run in the target environment with SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.
The generated password is printed once, only after both Auth and profile exist.
Existing accounts are never reset. This is an operator CLI, not a public endpoint.
"""
import json
import os
import secrets
import urllib.error
import urllib.request


def bootstrap(url, key, username='superman', request=None):
    def send(method, path, body=None):
        req=urllib.request.Request(url.rstrip('/')+path,
            data=None if body is None else json.dumps(body).encode(),method=method,
            headers={'apikey':key,'Authorization':'Bearer '+key,'Content-Type':'application/json','Prefer':'return=representation'})
        try:
            with urllib.request.urlopen(req,timeout=30) as response:
                text=response.read()
                return json.loads(text) if text else None
        except urllib.error.HTTPError as error:
            # Do not print response bodies, credentials, or request headers.
            raise RuntimeError(f'Bootstrap request failed (HTTP {error.code}); existing accounts were not reset') from None
    send=request or send
    existing=send('GET','/rest/v1/admin_accounts?select=id&username=eq.'+username)
    if existing:
        raise RuntimeError('Administrator already exists; refusing to reset its password')
    password='Ac9!'+secrets.token_urlsafe(24)
    user=send('POST','/auth/v1/admin/users',{'email':username+'@admin.autocare.internal','password':password,'email_confirm':True})
    user_id=user['id']
    try:
        send('POST','/rest/v1/admin_accounts',{'id':user_id,'username':username,'name':'Superman','role':'superAdmin','enabled':True,'must_change':True})
    except Exception:
        # If a response was lost after commit, preserve the valid profile/Auth user.
        linked=send('GET','/rest/v1/admin_accounts?select=id&id=eq.'+user_id)
        if not linked:
            send('DELETE','/auth/v1/admin/users/'+user_id)
            raise
    return username,password


if __name__=='__main__':
    name,password=bootstrap(os.environ['SUPABASE_URL'],os.environ['SUPABASE_SERVICE_ROLE_KEY'])
    print('Username: '+name)
    print('Initial password: '+password)
    print('First login requires a password change. Store this password securely; it is not saved by this script.')
