#!/usr/bin/env bash
# deploy-to-s3.sh - Deploy Hugo build to S3 (blue-green safe)
# Usage: ./deploy-to-s3.sh <blue|green>

set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
PROFILE="crc-prod"
BUCKET="dzresume-prod"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HUGO_DIR="$PROJECT_ROOT/frontend/hugo"
INFRA_DIR="$PROJECT_ROOT/infrastructure/terraform/persistent"

# ── Input validation ─────────────────────────────────────────────────────────
COLOR=${1:-}
if [[ ! "$COLOR" =~ ^(blue|green)$ ]]; then
    echo "❌ Usage: $0 <blue|green>"
    exit 1
fi

# ── Environment validation ───────────────────────────────────────────────────
# Ensure Hugo build exists
if [[ ! -d "$HUGO_DIR/public" ]] || [[ -z "$(ls -A "$HUGO_DIR/public" 2>/dev/null)" ]]; then
    echo "❌ No Hugo build found at: $HUGO_DIR/public/"
    echo "   Run: ./build-hugo-site.sh $COLOR"
    exit 1
fi

# ── Discover current state ───────────────────────────────────────────────────
echo "🔍 Checking current environment state..."
ACTIVE=$(terraform -chdir="$INFRA_DIR" output -raw active_environment)

# Safety check - don't overwrite active environment
if [[ "$COLOR" == "$ACTIVE" ]]; then
    echo "❌ '$COLOR' is currently ACTIVE (serving production traffic)"
    echo "   Deploy to inactive environment only"
    echo "   Active: $ACTIVE"
    echo "   Deploy to: $([[ "$ACTIVE" == "blue" ]] && echo "green" || echo "blue")"
    exit 1
fi

INACTIVE="$COLOR"
S3_PATH="s3://$BUCKET/$INACTIVE/"

# ── Version information ──────────────────────────────────────────────────────
LOCAL_VERSION="$(cat "$HUGO_DIR/VERSION" 2>/dev/null || echo 'unknown')"

echo "🚀 S3 Deployment Plan"
echo "   Environment: $INACTIVE (inactive - safe to deploy)"
echo "   Active environment: $ACTIVE (serving production)"
echo "   Version: v$LOCAL_VERSION"
echo "   Source: $HUGO_DIR/public/"
echo "   Target: $S3_PATH"
echo

# ── S3 Upload ────────────────────────────────────────────────────────────────
echo "📤 Syncing files to S3..."
echo "   Command: aws s3 sync $HUGO_DIR/public/ $S3_PATH --delete --profile $PROFILE"

# Count files before upload for verification
FILE_COUNT=$(find "$HUGO_DIR/public" -type f | wc -l)
echo "   Files to upload: $FILE_COUNT"

# Perform the sync
aws s3 sync "$HUGO_DIR/public/" "$S3_PATH" --delete --profile "$PROFILE"

echo "✅ S3 deployment complete!"
echo "   Environment: $INACTIVE"
echo "   Version: v$LOCAL_VERSION"
echo "   Files uploaded: $FILE_COUNT"
echo "   S3 location: $S3_PATH"
echo
echo "👉 Next step: ./invalidate-and-test.sh $INACTIVE"
