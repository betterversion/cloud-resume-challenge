#!/bin/bash
# build-hugo-site.sh - Build Hugo site for specified environment
# Usage: ./build-hugo-site.sh <blue|green>

set -e

# ── Input validation ────────────────────────────────────────────────────────
case "${1:-}" in
    blue|green) ENVIRONMENT="$1" ;;
    *) echo "❌ Usage: $0 <blue|green>" && exit 1 ;;
esac

# ── Project navigation (GitHub Actions compatible) ─────────────────────────
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HUGO_DIR="$PROJECT_ROOT/frontend/hugo"

if [[ ! -d "$HUGO_DIR" ]]; then
    echo "❌ Hugo directory not found: $HUGO_DIR"
    exit 1
fi

cd "$HUGO_DIR"

# ── Version management ─────────────────────────────────────────────────────
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "0")
NEW_VERSION=$((CURRENT_VERSION + 1))
export HUGO_DEPLOY_VERSION="$NEW_VERSION"
echo "$NEW_VERSION" > VERSION


echo "🔨 Building Hugo site: $ENVIRONMENT v$NEW_VERSION"

# ── Build process ──────────────────────────────────────────────────────────
rm -rf public/*

export HUGO_ENV="$ENVIRONMENT"
hugo --minify --environment "$ENVIRONMENT"

# ── Validate build output ──────────────────────────────────────────────────
if [[ ! -d "public" ]] || [[ -z "$(ls -A public 2>/dev/null)" ]]; then
    echo "❌ Build failed - no output generated"
    exit 1
fi

FILE_COUNT=$(find public -type f | wc -l)
echo "✅ Build complete: $FILE_COUNT files generated"
