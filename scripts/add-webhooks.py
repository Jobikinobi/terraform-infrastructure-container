#!/usr/bin/env python3
"""
Add webhooks to all GitHub repositories (excluding forks)
Safe and non-destructive - only adds webhooks
"""

import json
import subprocess
import sys
import time

WORKER_URL = "https://terraform-infrastructure-container.joe-1a2.workers.dev/api/github/webhook"
WEBHOOK_EVENTS = ["push", "pull_request", "issues", "release", "create", "delete"]

def run_gh_command(args):
    """Run gh CLI command and return JSON output"""
    try:
        result = subprocess.run(
            ["gh"] + args,
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout) if result.stdout.strip() else None
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.stderr}", file=sys.stderr)
        return None
    except json.JSONDecodeError:
        return None

def get_all_repos():
    """Get all non-fork repositories"""
    print("📥 Fetching repositories...")
    repos = run_gh_command([
        "repo", "list", "Jobikinobi",
        "--limit", "200",
        "--json", "name,isFork,isPrivate,description"
    ])

    if not repos:
        print("❌ Failed to fetch repositories")
        sys.exit(1)

    # Filter out forks
    own_repos = [r for r in repos if not r['isFork']]
    print(f"✓ Found {len(own_repos)} repositories (excluding {len(repos) - len(own_repos)} forks)")
    return own_repos

def check_webhook(repo_name):
    """Check if repository already has our webhook"""
    hooks = run_gh_command(["api", f"repos/Jobikinobi/{repo_name}/hooks"])
    if not hooks:
        return False

    for hook in hooks:
        if hook.get('config', {}).get('url') == WORKER_URL:
            return True
    return False

def add_webhook(repo_name):
    """Add webhook to repository"""
    webhook_config = {
        "name": "web",
        "active": True,
        "events": WEBHOOK_EVENTS,
        "config": {
            "url": WORKER_URL,
            "content_type": "json",
            "insecure_ssl": "0"
        }
    }

    try:
        # Create webhook via gh api
        result = subprocess.run(
            ["gh", "api", f"repos/Jobikinobi/{repo_name}/hooks", "-X", "POST", "--input", "-"],
            input=json.dumps(webhook_config),
            capture_output=True,
            text=True,
            check=True
        )
        return True, "✓"
    except subprocess.CalledProcessError as e:
        error_msg = e.stderr
        if "Hook already exists" in error_msg or "already exists" in error_msg:
            return True, "⊘ (already exists)"
        return False, f"✗ ({error_msg.strip()[:50]})"

def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Add Webhooks to All GitHub Repositories                  ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()

    # Get all repos
    repos = get_all_repos()

    # Check existing webhooks
    print("\n🔍 Checking existing webhooks...")
    repos_with_webhook = []
    repos_without_webhook = []

    for repo in repos:
        if check_webhook(repo['name']):
            repos_with_webhook.append(repo['name'])
        else:
            repos_without_webhook.append(repo['name'])

    print(f"✓ {len(repos_with_webhook)} repos already have webhook")
    print(f"➕ {len(repos_without_webhook)} repos need webhook")

    if len(repos_without_webhook) == 0:
        print("\n✨ All repositories already have webhooks!")
        return

    # Confirm
    print("\n" + "=" * 60)
    print(f"This will add webhooks to {len(repos_without_webhook)} repositories")
    print()
    print("Webhook configuration:")
    print(f"  URL: {WORKER_URL}")
    print(f"  Events: {', '.join(WEBHOOK_EVENTS)}")
    print()
    print("✓ SAFE: Only adds webhooks, no other changes")
    print("✓ Can be removed anytime")
    print()

    response = input("Continue? (y/N): ")
    if response.lower() != 'y':
        print("\n❌ Aborted. No changes made.")
        return

    # Add webhooks
    print("\n" + "=" * 60)
    print("🚀 Adding webhooks...")
    print()

    success_count = 0
    skip_count = 0
    fail_count = 0

    for i, repo_name in enumerate(repos_without_webhook, 1):
        print(f"[{i}/{len(repos_without_webhook)}] {repo_name}...", end=" ", flush=True)

        success, status = add_webhook(repo_name)
        print(status)

        if success:
            if "already" in status:
                skip_count += 1
            else:
                success_count += 1
        else:
            fail_count += 1

        # Rate limiting
        time.sleep(0.5)

    # Summary
    print()
    print("=" * 60)
    print("✅ Webhook deployment complete!")
    print()
    print(f"Summary:")
    print(f"  ✓ Success: {success_count}")
    print(f"  ⊘ Skipped: {skip_count}")
    print(f"  ✗ Failed: {fail_count}")
    print(f"  📊 Total: {len(repos_without_webhook)}")
    print()
    print(f"All {len(repos_with_webhook) + success_count} repositories are now tracked!")
    print()
    print("Next: All GitHub activity will be logged to D1 database")
    print("Query: npx wrangler d1 execute terraform-deployments \\")
    print("  --command \"SELECT repo_full_name FROM github_repositories\" --remote")
    print()

if __name__ == "__main__":
    main()
