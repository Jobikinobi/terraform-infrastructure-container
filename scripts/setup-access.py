#!/usr/bin/env python3
"""
Configure Cloudflare Access for HOLE Substrate programmatically
Requires: Cloudflare API token with Account-level Access permissions
"""

import json
import requests
import sys

ACCOUNT_ID = "1a25a792e801e687b9fe4932030cf6a6"
API_TOKEN = "tbeRzIn22V5qvW2o31gVN8vx9vPB4j02pYurEJZY"
WORKER_DOMAIN = "hole-substrate.joe-1a2.workers.dev"
BASE_URL = f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT_ID}"

headers = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}

def create_access_application():
    """Create Cloudflare Access application"""
    print("📱 Creating Access Application...")

    app_config = {
        "name": "HOLE Substrate",
        "domain": WORKER_DOMAIN,
        "type": "self_hosted",
        "session_duration": "24h",
        "auto_redirect_to_identity": False,
        "cors_headers": {
            "allow_all_origins": True,
            "allow_all_methods": True,
            "allow_all_headers": True,
            "allow_credentials": True
        }
    }

    response = requests.post(
        f"{BASE_URL}/access/apps",
        headers=headers,
        json=app_config
    )

    if response.status_code == 200:
        app_id = response.json()['result']['id']
        print(f"✅ Application created: {app_id}")
        return app_id
    else:
        # Check if already exists
        print(f"⚠️  Status {response.status_code}: {response.json().get('errors', [{}])[0].get('message', 'Unknown error')}")

        # Try to find existing
        apps_response = requests.get(f"{BASE_URL}/access/apps", headers=headers)
        if apps_response.status_code == 200:
            apps = apps_response.json()['result']
            for app in apps:
                if app['domain'] == WORKER_DOMAIN:
                    print(f"ℹ️  Application already exists: {app['id']}")
                    return app['id']

        print("❌ Failed to create or find application")
        print(response.json())
        return None

def create_policies(app_id):
    """Create Access policies for the application"""
    print("\n🔐 Creating Access Policies...")

    policies = [
        {
            "name": "Public Discovery",
            "decision": "bypass",
            "include": [{"everyone": {}}],
            "precedence": 1
        },
        {
            "name": "HOLE Foundation Team",
            "decision": "allow",
            "include": [
                {"email_domain": {"domain": "theholetruth.org"}},
                {"email": {"email": "joe@theholetruth.org"}}
            ],
            "precedence": 2
        },
        {
            "name": "Service Tokens",
            "decision": "non_identity",
            "include": [{"everyone": {}}],
            "precedence": 3
        }
    ]

    created_policies = []

    for policy in policies:
        response = requests.post(
            f"{BASE_URL}/access/apps/{app_id}/policies",
            headers=headers,
            json=policy
        )

        if response.status_code == 200 or response.status_code == 201:
            policy_id = response.json()['result']['id']
            print(f"  ✅ Created policy: {policy['name']} ({policy_id})")
            created_policies.append(policy_id)
        else:
            print(f"  ⚠️  Failed to create policy '{policy['name']}': {response.json().get('errors', [{}])[0].get('message', 'Unknown')}")

    return created_policies

def generate_service_tokens():
    """Generate service tokens for projects"""
    print("\n🎫 Generating Service Tokens...")

    projects = [
        ("theholetruth-org-v2", "Service token for The HOLE Truth V2 project"),
        ("mipds", "Service token for MIPDS project"),
        ("legal-intelligence", "Service token for Legal Intelligence project")
    ]

    tokens = {}

    for project_id, description in projects:
        token_data = {
            "name": f"substrate-{project_id}",
            "duration": "8760h"  # 1 year
        }

        response = requests.post(
            f"{BASE_URL}/access/service_tokens",
            headers=headers,
            json=token_data
        )

        if response.status_code == 200 or response.status_code == 201:
            result = response.json()['result']
            token_info = {
                "client_id": result['client_id'],
                "client_secret": result['client_secret'],
                "name": result['name'],
                "id": result['id']
            }
            tokens[project_id] = token_info
            print(f"  ✅ {project_id}:")
            print(f"     Client ID: {result['client_id']}")
            print(f"     Client Secret: {result['client_secret'][:20]}...")
        else:
            print(f"  ❌ Failed to create token for {project_id}")
            print(f"     Error: {response.json().get('errors', [{}])[0].get('message', 'Unknown')}")

    return tokens

def save_tokens(tokens):
    """Save tokens to file for reference"""
    with open('service-tokens.json', 'w') as f:
        json.dump(tokens, f, indent=2)
    print(f"\n💾 Tokens saved to service-tokens.json")

def main():
    print("Setting up Cloudflare Access for HOLE Substrate...")
    print(f"Account: {ACCOUNT_ID}")
    print(f"Domain: {WORKER_DOMAIN}\n")

    # Create application
    app_id = create_access_application()
    if not app_id:
        sys.exit(1)

    # Create policies
    policies = create_policies(app_id)

    # Generate service tokens
    tokens = generate_service_tokens()

    if tokens:
        save_tokens(tokens)

    print("\n" + "=" * 60)
    print("✅ Cloudflare Access setup complete!")
    print()
    print("Summary:")
    print(f"  Application ID: {app_id}")
    print(f"  Policies created: {len(policies)}")
    print(f"  Service tokens: {len(tokens)}")
    print()
    print("Next: Add service tokens to project .env files")
    print()

if __name__ == "__main__":
    main()
