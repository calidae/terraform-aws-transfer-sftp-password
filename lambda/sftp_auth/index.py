import os
import secrets


_MASTER_PASSWORD = os.getenv('TRANSFER_PASSWORD')
_UNAUTHENTICATED = {}
_DEFAULT_AUTH = {
    'HomeDirectory': os.getenv('TRANSFER_HOME_DIRECTORY'),
    'Role': os.getenv('TRANSFER_ROLE'),
}


def lambda_handler(event, context):
    if secrets.compare_digest(
        event.get('password', ''),
        _MASTER_PASSWORD,
    ):
        return _DEFAULT_AUTH
    else:
        return _UNAUTHENTICATED
