import hashlib
import os
import secrets


_MASTER_PASSWORD = os.getenv('TRANSFER_PASSWORD')
_UNAUTHENTICATED = {}
_DEFAULT_AUTH = {
    'HomeDirectory': os.getenv('TRANSFER_HOME_DIRECTORY'),
    'Role': os.getenv('TRANSFER_ROLE'),
}


def digest(password):
    dk = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode(),
        salt=b'uMaVww64FUnDLcWF',
        iterations=1_000_000,
    )
    return dk.hex()


def lambda_handler(event, context):
    if secrets.compare_digest(
        digest(event.get('password', '')),
        _MASTER_PASSWORD,
    ):
        return _DEFAULT_AUTH
    else:
        return _UNAUTHENTICATED


if __name__ == '__main__':
    import json
    import sys
    print(json.dumps({
        'digest': digest(sys.argv[1])
    }))
