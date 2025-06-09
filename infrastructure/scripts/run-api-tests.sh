#!/bin/bash

# API Testing Script with Beautiful Reporting
set -euo pipefail

ENVIRONMENT=${1:-"blue"}
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
BACKEND_DIR="$PROJECT_ROOT/backend
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "🧪 Resume API Testing Suite"
echo "================================"
echo "🎯 Target Environment: $ENVIRONMENT"
echo "📁 Working Directory: $BACKEND_DIR"

cd "$BACKEND_DIR" || exit 1

# Validate environment
if [ ! -f "tests/environments/${ENVIRONMENT}.json" ]; then
    echo "❌ Environment file not found: tests/environments/${ENVIRONMENT}.json"
    echo "📝 Available environments:"
    ls tests/environments/*.json 2>/dev/null | xargs -n1 basename | sed 's/.json$//' | sed 's/^/   - /' || echo "   No environment files found"
    exit 1
fi

# Create reports directory
mkdir -p tests/reports

# Get API URL for logging
API_URL=$(grep -o 'https://[^"]*' "tests/environments/${ENVIRONMENT}.json" | head -1)
echo "🔗 Testing API: $API_URL"
echo ""

# Run tests with multiple report formats
echo "🧪 Executing comprehensive API test suite..."
docker run --rm \
    -v "$(pwd)/tests:/etc/newman" \
    postman/newman:latest \
    run collections/api-tests.json \
    -e environments/${ENVIRONMENT}.json \
    --reporters cli,json,htmlextra \
    --reporter-json-export reports/api-results-${ENVIRONMENT}-${TIMESTAMP}.json \
    --reporter-htmlextra-export reports/api-report-${ENVIRONMENT}-${TIMESTAMP}.html \
    --reporter-htmlextra-darkTheme \
    --reporter-htmlextra-title "Resume API Test Report - ${ENVIRONMENT^} Environment" \
    --reporter-htmlextra-logs

EXIT_CODE=$?

# Generate summary
if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ API tests PASSED for $ENVIRONMENT environment"
    echo "📊 Reports generated:"
    echo "   📄 JSON: tests/reports/api-results-${ENVIRONMENT}-${TIMESTAMP}.json"
    echo "   🌐 HTML: tests/reports/api-report-${ENVIRONMENT}-${TIMESTAMP}.html"
    echo ""
    echo "💡 Open HTML report in browser:"
    echo "   file://$(pwd)/tests/reports/api-report-${ENVIRONMENT}-${TIMESTAMP}.html"
    echo ""
    echo "🚀 $ENVIRONMENT environment validated and ready"
else
    echo ""
    echo "❌ API tests FAILED for $ENVIRONMENT environment"
    echo "📊 Check reports for details:"
    echo "   🌐 HTML: tests/reports/api-report-${ENVIRONMENT}-${TIMESTAMP}.html"
    echo ""
    echo "🚨 Environment has issues - investigate before proceeding"
    exit 1
fi
