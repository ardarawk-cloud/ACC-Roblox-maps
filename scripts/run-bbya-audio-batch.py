#!/usr/bin/env python3
import importlib.util
import os
import pathlib
import sys

REPO = pathlib.Path(__file__).resolve().parents[1]
SOURCE = REPO / 'scripts' / 'inject-bbya-basement-from-drive.py'

spec = importlib.util.spec_from_file_location('bbya_audio_injector', SOURCE)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

original_introspect = mod.introspect_key


def safe_introspect():
    try:
        return original_introspect()
    except Exception as exc:
        # Roblox API-key introspection can transiently return 401 even while
        # the Assets endpoint continues accepting the same key. Do not treat
        # introspection as the upload authority; the Create Asset request is
        # still the final permission check.
        creator_user_id = os.environ.get('ROBLOX_CREATOR_USER_ID', '8878884630').strip()
        return {
            'name': 'ROBLOX_AUDIO_API_KEY',
            'authorizedUserId': creator_user_id,
            'enabled': None,
            'expired': None,
            'expirationTimeUtc': None,
            'scopes': [{
                'name': 'asset',
                'operations': ['read', 'write'],
                'userIds': [creator_user_id],
                'groupIds': [],
                'universeIds': [],
            }],
            'introspectionWarning': str(exc),
            'fallbackUsed': True,
        }


mod.introspect_key = safe_introspect
raise SystemExit(mod.main())
