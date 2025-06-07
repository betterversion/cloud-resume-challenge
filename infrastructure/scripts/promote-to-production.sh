#!/usr/bin/env bash
# promote-to-production.sh - Promote staging deployment to production
# Usage: ./promote-to-production.sh <blue|green>

set -euo pipefail

ENVIRONMENT=${1:-}
if [[ ! "$ENVIRONMENT" =~ ^(blue|green)$ ]]; then
    echo "❌ Usage: $0 <blue|green>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Production Promotion: $ENVIRONMENT"
echo "===================================="
echo "⚠️  Switching production traffic to $ENVIRONMENT environment"
echo

# ── Traffic Switch ───────────────────────────────────────────────────────────
echo "🔄 Switching production traffic..."
"$SCRIPT_DIR/switch-environment.sh" "$ENVIRONMENT"

echo "🔄 Invalidating production cache..."
"$SCRIPT_DIR/invalidate-cloudfront.sh" main

echo "🧪 Verifying production deployment..."
"$SCRIPT_DIR/smoke-test.sh" main

# ── Production Summary ──────────────────────────────────────────────────────
echo
echo "🎉 PRODUCTION PROMOTION COMPLETE"
echo "==============================="
echo "✅ Environment: $ENVIRONMENT is now live"
echo "🌐 Production: https://dzresume.dev/"
echo "🧪 Staging: https://test.dzresume.dev/"
echo
echo "🛡️  Zero-downtime switch completed successfully"
