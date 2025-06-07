#!/usr/bin/env bash
# smoke-test.sh - Test deployment at main or test domain
# Usage: ./smoke-test.sh <main|test> [expected-version]

set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
HUGO_DIR="$PROJECT_ROOT/frontend/hugo"
INFRA_DIR="$PROJECT_ROOT/infrastructure/terraform/persistent"

# ── Input validation ─────────────────────────────────────────────────────────
TARGET=${1:-}
EXPECTED_VERSION=${2:-}

if [[ ! "$TARGET" =~ ^(main|test)$ ]]; then
    echo "❌ Usage: $0 <main|test> [expected-version]"
    echo ""
    echo "   main = Test production domain (dzresume.dev)"
    echo "   test = Test staging domain (test.dzresume.dev)"
    echo ""
    echo "Examples:"
    echo "   $0 test           # Test staging with local version"
    echo "   $0 main           # Test production with local version"
    echo "   $0 main v42       # Test production for specific version"
    exit 1
fi

# ── Domain mapping ───────────────────────────────────────────────────────────
if [[ "$TARGET" == "main" ]]; then
    URL="https://dzresume.dev/"
    DOMAIN_TYPE="Production"
    ENV_DESCRIPTION="main domain"
else
    URL="https://test.dzresume.dev/"
    DOMAIN_TYPE="Staging"
    ENV_DESCRIPTION="test domain"
fi

# ── Get environment context ──────────────────────────────────────────────────
echo "🔍 Getting environment information..."
ACTIVE=$(terraform -chdir="$INFRA_DIR" output -raw active_environment 2>/dev/null || echo "unknown")

if [[ "$TARGET" == "main" ]]; then
    SERVING_ENV="$ACTIVE"
    ENV_STATUS="(serving $ACTIVE environment)"
else
    SERVING_ENV=$([[ "$ACTIVE" == "blue" ]] && echo "green" || echo "blue")
    ENV_STATUS="(serving $SERVING_ENV environment)"
fi

echo "📊 Test Target:"
echo "   Domain: $DOMAIN_TYPE $ENV_STATUS"
echo "   URL: $URL"
echo "   Current active: $ACTIVE"
echo

# ── Get expected version ─────────────────────────────────────────────────────
if [[ -z "$EXPECTED_VERSION" ]]; then
    # Try to get version from local Hugo build
    LOCAL_VERSION="$(cat "$HUGO_DIR/VERSION" 2>/dev/null || echo '')"
    if [[ -n "$LOCAL_VERSION" ]]; then
        EXPECTED_VERSION="v$LOCAL_VERSION"
        echo "📦 Using local version: $EXPECTED_VERSION"
    else
        echo "📦 No expected version specified - connectivity test only"
    fi
else
    echo "📦 Expected version: $EXPECTED_VERSION"
fi

# ── Connectivity test ────────────────────────────────────────────────────────
echo "🌐 Testing connectivity to $DOMAIN_TYPE..."
HTTP_STATUS=$(curl -sL -w "%{http_code}" -o /dev/null "$URL" || echo "000")

if [[ "$HTTP_STATUS" != "200" ]]; then
    echo "❌ Connectivity test failed!"
    echo "   Target: $DOMAIN_TYPE $ENV_STATUS"
    echo "   URL: $URL"
    echo "   HTTP Status: $HTTP_STATUS"
    echo "   Expected: 200"
    exit 1
fi

echo "✅ Connectivity OK (HTTP $HTTP_STATUS)"

# ── Version verification ─────────────────────────────────────────────────────
if [[ -n "$EXPECTED_VERSION" ]]; then
    echo "🔍 Checking deployment version..."

    # Try multiple times with backoff for eventual consistency
    MAX_RETRIES=3
    RETRY_COUNT=0

    while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
        echo "   Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES..."

        # Fetch and extract version
        PAGE_CONTENT=$(curl -sL "$URL" 2>/dev/null || echo "")
        DEPLOYED_VERSION=$(echo "$PAGE_CONTENT" | grep 'name=.*deployment-version' | sed 's/.*deployment-version content=//' | sed 's/^"//' | sed 's/".*//' 2>/dev/null || echo "not_found")

        if [[ "$DEPLOYED_VERSION" == "not_found" ]]; then
            echo "   ⚠️  Could not extract version from page"
        elif [[ "$DEPLOYED_VERSION" == *"$EXPECTED_VERSION"* ]]; then
            echo "✅ Version verification successful!"
            echo "   Target: $DOMAIN_TYPE $ENV_STATUS"
            echo "   URL: $URL"
            echo "   Expected: $EXPECTED_VERSION"
            echo "   Found: $DEPLOYED_VERSION"
            echo "   Status: Deployment verified ✨"
            exit 0
        else
            echo "   ❌ Version mismatch"
            echo "      Expected: $EXPECTED_VERSION"
            echo "      Found: $DEPLOYED_VERSION"
        fi

        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; then
            echo "   ⏳ Waiting 5 seconds before retry..."
            sleep 5
        fi
    done

    # Version verification failed
    echo "❌ Version verification failed after $MAX_RETRIES attempts!"
    echo "   Target: $DOMAIN_TYPE $ENV_STATUS"
    echo "   URL: $URL"
    echo "   Expected: $EXPECTED_VERSION"
    echo "   Last found: $DEPLOYED_VERSION"
    echo
    echo "🔧 Debug command: curl -sL $URL | grep deployment-version"
    exit 1
else
    echo "✅ Smoke test complete (connectivity only)"
    echo "   Target: $DOMAIN_TYPE $ENV_STATUS"
    echo "   URL: $URL"
    echo "   Status: Site is responding"
fi
