#!/usr/bin/env bash
# deploy-to-staging.sh - Professional Blue-Green Deployment Pipeline
# Usage: ./deploy-to-staging.sh <blue|green>

set -euo pipefail

ENVIRONMENT=${1:-}
if [[ ! "$ENVIRONMENT" =~ ^(blue|green)$ ]]; then
    echo "❌ Usage: $0 <blue|green>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Cloud Resume Challenge - Blue-Green Deployment"
echo "================================================="
echo "🎯 Target Environment: $ENVIRONMENT"
echo "📊 Deployment Strategy: Zero-downtime blue-green"
echo

# ── Step 1: Build Application ───────────────────────────────────────────────
echo "📦 Step 1: Building application..."
if "$SCRIPT_DIR/build-hugo-site.sh" "$ENVIRONMENT"; then
    echo "✅ Step 1 completed successfully"
else
    echo "❌ Step 1 failed - build-hugo-site.sh returned error"
    exit 1
fi
echo

# ── Step 2: Deploy Backend ──────────────────────────────────────────────────
echo "📡 Step 2: Deploying backend infrastructure..."
if "$SCRIPT_DIR/deploy-backend.sh" "$ENVIRONMENT"; then
    echo "✅ Step 2 completed successfully"
else
    echo "❌ Step 2 failed - deploy-backend.sh returned error"
    exit 1
fi
echo

# ── Step 3: Deploy Frontend ─────────────────────────────────────────────────
echo "🎨 Step 3: Deploying frontend assets..."
"$SCRIPT_DIR/deploy-to-s3.sh" "$ENVIRONMENT"
echo

# ── Step 4: Invalidate Cache ────────────────────────────────────────────────
echo "🔄 Step 4: Invalidating staging cache..."
"$SCRIPT_DIR/invalidate-cloudfront.sh" test
echo

# ── Step 5: Verify Deployment ───────────────────────────────────────────────
echo "🧪 Step 5: Running deployment verification..."
"$SCRIPT_DIR/smoke-test.sh" test
echo

# ── Staging Complete ────────────────────────────────────────────────────────
echo "✅ STAGING DEPLOYMENT COMPLETE"
echo "=============================="
echo "🎯 Environment: $ENVIRONMENT deployed to staging"
echo "🧪 Staging URL: https://test.dzresume.dev/"
echo "🔍 Verification: All tests passed"
echo
echo "👉 Production Promotion:"
echo "   ./promote-to-production.sh $ENVIRONMENT"
