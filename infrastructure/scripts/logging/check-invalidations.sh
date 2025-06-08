#!/bin/bash
# check-invalidations.sh - Check CloudFront invalidation usage (FIXED VERSION)

set -e

PROFILE="crc-prod"
CURRENT_MONTH=$(date +%Y-%m)

# Hardcoded distribution IDs
MAIN_DIST_ID="E2CMT6GV5TOTQ8"    # dzresume.dev
TEST_DIST_ID="E1DED3Q3VSWZ2R"    # test.dzresume.dev

echo "🔍 CLOUDFRONT INVALIDATION USAGE REPORT"
echo "========================================"
echo "Month: $CURRENT_MONTH"
echo "Profile: $PROFILE"
echo ""

# Function to count invalidations for a distribution (returns count only)
count_invalidations() {
    local dist_id=$1

    # Get invalidations for this month (return count only, no echo)
    COUNT=$(aws cloudfront list-invalidations \
        --distribution-id "$dist_id" \
        --profile $PROFILE \
        --query "InvalidationList.Items[?starts_with(CreateTime, '$CURRENT_MONTH')]" \
        --output json | jq length)

    if [[ "$COUNT" == "null" ]]; then
        COUNT=0
    fi

    # Only return the count, no echo messages
    echo "$COUNT"
}

# Function to show recent invalidations
show_recent_invalidations() {
    local dist_id=$1
    local dist_name=$2

    echo ""
    echo "📋 Recent $dist_name invalidations:"
    aws cloudfront list-invalidations \
        --distribution-id "$dist_id" \
        --profile $PROFILE \
        --query "InvalidationList.Items[?starts_with(CreateTime, '$CURRENT_MONTH')][CreateTime,Status]" \
        --output table 2>/dev/null || echo "   Unable to fetch details"
}

# Check both distributions
echo "📊 DISTRIBUTION USAGE"
echo "===================="

echo "📊 Checking Main (dzresume.dev) ($MAIN_DIST_ID)..."
MAIN_COUNT=$(count_invalidations "$MAIN_DIST_ID")

echo "📊 Checking Test (test.dzresume.dev) ($TEST_DIST_ID)..."
TEST_COUNT=$(count_invalidations "$TEST_DIST_ID")

# Calculate totals
TOTAL_COUNT=$((MAIN_COUNT + TEST_COUNT))
REMAINING=$((1000 - TOTAL_COUNT))

echo ""
echo "📊 USAGE SUMMARY"
echo "================"
echo "Main distribution:    $MAIN_COUNT invalidations"
echo "Test distribution:    $TEST_COUNT invalidations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total this month:     $TOTAL_COUNT / 1,000 (free)"
echo "Remaining free:       $REMAINING invalidations"

# Status and warnings
echo ""
echo "💰 COST STATUS"
echo "=============="
if [[ $TOTAL_COUNT -eq 0 ]]; then
    echo "✅ No invalidations used this month"
elif [[ $TOTAL_COUNT -lt 500 ]]; then
    echo "✅ Well within free tier limits"
elif [[ $TOTAL_COUNT -lt 900 ]]; then
    echo "⚠️  Moderate usage - monitor if doing lots of deployments"
elif [[ $TOTAL_COUNT -lt 1000 ]]; then
    echo "🟡 Approaching free tier limit ($REMAINING remaining)"
else
    OVERAGE=$((TOTAL_COUNT - 1000))
    COST=$(echo "scale=2; $OVERAGE * 0.005" | bc)
    echo "🔴 Over free tier! $OVERAGE extra invalidations ≈ \$$COST"
fi

# Show recent invalidations if requested
if [[ "${1:-}" == "--details" ]] || [[ "${1:-}" == "-d" ]]; then
    show_recent_invalidations "$MAIN_DIST_ID" "Main"
    show_recent_invalidations "$TEST_DIST_ID" "Test"
fi

echo ""
echo "💡 USAGE BREAKDOWN"
echo "=================="
echo "• Main (production): Usually 1-2 invalidations/day"
echo "• Test (staging): Usually 3-5 invalidations/day"
echo "• Monthly estimate: ~60-90 total invalidations"
echo "• Free tier: 1,000/month across ALL distributions"
echo ""
echo "🔧 Run with --details flag to see recent invalidation timestamps"

# Exit with appropriate code
if [[ $TOTAL_COUNT -gt 1000 ]]; then
    exit 2  # Over limit
elif [[ $TOTAL_COUNT -gt 900 ]]; then
    exit 1  # Warning
else
    exit 0  # All good
fi
