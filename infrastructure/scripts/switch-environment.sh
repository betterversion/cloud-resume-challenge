#!/usr/bin/env bash
# switch-environment.sh - Switch production traffic between blue/green
# Usage: ./switch-environment.sh <blue|green>

set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
PROFILE="crc-prod"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
INFRA_DIR="$PROJECT_ROOT/infrastructure/terraform/persistent"

# ── Input validation ─────────────────────────────────────────────────────────
TARGET_ENV=${1:-}
if [[ ! "$TARGET_ENV" =~ ^(blue|green)$ ]]; then
    echo "❌ Usage: $0 <blue|green>"
    exit 1
fi

# ── Show current state ───────────────────────────────────────────────────────
echo "🔍 Checking current environment state..."
CURRENT_ENV=$(terraform -chdir="$INFRA_DIR" output -raw active_environment)

echo "📊 Environment Switch Plan:"
echo "   Current active: $CURRENT_ENV"
echo "   Target active: $TARGET_ENV"

if [[ "$CURRENT_ENV" == "$TARGET_ENV" ]]; then
    echo "⚠️  '$TARGET_ENV' is already active!"
    echo "   No switch needed"
    exit 0
fi

echo "   Action: Switch $CURRENT_ENV → $TARGET_ENV"
echo

# ── Confirm the switch ───────────────────────────────────────────────────────
read -p "🚨 Switch production traffic to $TARGET_ENV? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Switch cancelled"
    exit 1
fi

# ── Execute the switch ───────────────────────────────────────────────────────
echo "🔄 Switching production traffic..."
echo "   Target: $TARGET_ENV"

cd "$INFRA_DIR"
terraform apply -var="active_environment=$TARGET_ENV" -auto-approve

# ── Verify the switch ────────────────────────────────────────────────────────
NEW_ENV=$(terraform output -raw active_environment)
if [[ "$NEW_ENV" == "$TARGET_ENV" ]]; then
    echo "✅ Traffic switch successful!"
    echo "   Previous: $CURRENT_ENV"
    echo "   Current: $NEW_ENV"
    echo "   Production URL: https://dzresume.dev/"
    echo
    echo "👉 Recommended next steps:"
    echo "   1. ./invalidate-cloudfront.sh main"
    echo "   2. ./smoke-test.sh https://dzresume.dev/"
else
    echo "❌ Switch failed!"
    echo "   Expected: $TARGET_ENV"
    echo "   Actual: $NEW_ENV"
    exit 1
fi
