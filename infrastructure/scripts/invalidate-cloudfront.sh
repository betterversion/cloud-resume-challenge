#!/usr/bin/env bash
# invalidate-cloudfront.sh - Invalidate CloudFront distribution cache
# Usage: ./invalidate-cloudfront.sh <test|main>

set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
PROFILE="crc-prod"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
INFRA_DIR="$PROJECT_ROOT/infrastructure/terraform/persistent"

# ── Input validation ─────────────────────────────────────────────────────────
TARGET=${1:-}
if [[ ! "$TARGET" =~ ^(test|main)$ ]]; then
    echo "❌ Usage: $0 <test|main>"
    echo "   test = Invalidate test CloudFront (test.dzresume.dev)"
    echo "   main = Invalidate main CloudFront (dzresume.dev)"
    exit 1
fi

# ── Get CloudFront distribution ID ───────────────────────────────────────────
echo "🔍 Getting CloudFront distribution info..."

if [[ "$TARGET" == "test" ]]; then
    CF_ID=$(terraform -chdir="$INFRA_DIR" output -raw cf_test_distribution_id)
    CF_DOMAIN="test.dzresume.dev"
    CF_TYPE="Test"
else
    CF_ID=$(terraform -chdir="$INFRA_DIR" output -raw cf_main_distribution_id)
    CF_DOMAIN="dzresume.dev"
    CF_TYPE="Main"
fi

if [[ -z "$CF_ID" ]]; then
    echo "❌ Could not get CloudFront distribution ID for $TARGET"
    exit 1
fi

# ── Show current environment state ───────────────────────────────────────────
ACTIVE=$(terraform -chdir="$INFRA_DIR" output -raw active_environment)
echo "📊 Current State:"
echo "   Active environment: $ACTIVE"
echo "   Target: $CF_TYPE CloudFront"
echo "   Domain: $CF_DOMAIN"
echo "   Distribution ID: $CF_ID"
echo

# ── Perform invalidation ─────────────────────────────────────────────────────
echo "🔄 Creating CloudFront invalidation..."
echo "   Distribution: $CF_ID ($CF_TYPE)"
echo "   Paths: /*"

INVALIDATION_ID=$(aws cloudfront create-invalidation \
    --distribution-id "$CF_ID" \
    --paths '/*' \
    --profile "$PROFILE" \
    --query 'Invalidation.Id' --output text)

echo "   Invalidation ID: $INVALIDATION_ID"
echo "⏳ Waiting for invalidation to complete..."

# Wait for completion with timeout protection
aws cloudfront wait invalidation-completed \
    --distribution-id "$CF_ID" \
    --id "$INVALIDATION_ID" \
    --profile "$PROFILE"

echo "✅ CloudFront invalidation complete!"
echo "   Target: $CF_TYPE ($CF_DOMAIN)"
echo "   Distribution: $CF_ID"
echo "   Invalidation: $INVALIDATION_ID"
echo
echo "👉 Next: ./smoke-test.sh https://$CF_DOMAIN/"
