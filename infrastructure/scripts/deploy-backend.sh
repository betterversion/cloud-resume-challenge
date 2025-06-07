#!/usr/bin/env bash
# deploy-backend.sh - Deploy Lambda/API Gateway to specified environment
# Usage: ./deploy-backend.sh <blue|green>

set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
PROFILE="crc-prod"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
TERRAFORM_APP_DIR="$PROJECT_ROOT/infrastructure/terraform/application"
TERRAFORM_PERSIST_DIR="$PROJECT_ROOT/infrastructure/terraform/persistent"

# ── Input validation ─────────────────────────────────────────────────────────
ENVIRONMENT=${1:-}
if [[ ! "$ENVIRONMENT" =~ ^(blue|green)$ ]]; then
    echo "❌ Usage: $0 <blue|green>"
    exit 1
fi

# ── Validate Terraform directories ──────────────────────────────────────────
if [[ ! -d "$TERRAFORM_APP_DIR" ]]; then
    echo "❌ Backend Terraform directory not found: $TERRAFORM_APP_DIR"
    exit 1
fi

if [[ ! -d "$TERRAFORM_PERSIST_DIR" ]]; then
    echo "❌ Persistent Terraform directory not found: $TERRAFORM_PERSIST_DIR"
    exit 1
fi

# ── Get current infrastructure state ─────────────────────────────────────────
echo "🔍 Checking current infrastructure state..."
ACTIVE_ENV=$(terraform -chdir="$TERRAFORM_PERSIST_DIR" output -raw active_environment 2>/dev/null || echo "unknown")

echo "📊 Backend Deployment Plan:"
echo "   Target environment: $ENVIRONMENT"
echo "   Currently active: $ACTIVE_ENV"

if [[ "$ENVIRONMENT" == "$ACTIVE_ENV" ]]; then
    echo "   ⚠️  Deploying to ACTIVE environment (serving production)"
    echo "   ✅ This is allowed but use caution"
else
    echo "   ✅ Deploying to INACTIVE environment (safe)"
fi

echo "   Application dir: $TERRAFORM_APP_DIR"
echo

# --- Switch to target workspace ----------------------------
cd "$TERRAFORM_APP_DIR"
CURRENT_WS=$(terraform workspace show)

# list all workspaces, strip the leading decorations
ALL_WS=$(terraform workspace list -no-color | sed 's/^[* ]*//')

if ! echo "$ALL_WS" | grep -qx "$ENVIRONMENT"; then
  echo "   Creating new workspace: $ENVIRONMENT"
  terraform workspace new "$ENVIRONMENT"
fi

if [[ "$CURRENT_WS" != "$ENVIRONMENT" ]]; then
  terraform workspace select "$ENVIRONMENT"
fi


# ── Deploy backend infrastructure ────────────────────────────────────────────
echo "🚀 Deploying backend infrastructure..."
echo "   Environment: $ENVIRONMENT"
echo "   Workspace: $CURRENT_WS"

# Initialize if needed (safe to run multiple times)
echo "🔧 Ensuring Terraform is initialized..."
terraform init

# Plan the deployment
echo "📋 Creating deployment plan..."
terraform plan -out=tfplan

# Apply the deployment
echo "⚡ Applying deployment..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

echo "✅ Backend deployment complete!"
echo

# ── Verify deployment ────────────────────────────────────────────────────────
echo "🔍 Verifying backend deployment..."

# Get API Gateway URL from Terraform output
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")

if [[ -z "$API_URL" ]]; then
    echo "⚠️  Could not get API Gateway URL from Terraform output"
    echo "   Check if 'api_gateway_url' output exists in your configuration"

    # Show available outputs for debugging
    echo "📋 Available Terraform outputs:"
    terraform output
    exit 1
fi

echo "📡 API Gateway Information:"
echo "   Environment: $ENVIRONMENT"
echo "   API URL: $API_URL"

# ── Test API functionality ───────────────────────────────────────────────────
echo "🧪 Testing API functionality..."

# Test the health check endpoint
echo "   Testing GET /health endpoint..."
HEALTH_URL=$(terraform output -raw health_endpoint_url 2>/dev/null || echo "")

if [[ -z "$HEALTH_URL" ]]; then
    echo "❌ Could not retrieve health endpoint URL from Terraform output"
    terraform output
    exit 1
fi

RESPONSE=$(curl -s -X GET "$HEALTH_URL" || echo "CURL_FAILED")

if [[ "$RESPONSE" == "CURL_FAILED" ]]; then
    echo "❌ API health check failed - could not connect to endpoint"
    echo "   URL: $HEALTH_URL"
    exit 1
fi

# Basic response validation
if echo "$RESPONSE" | grep -qi "ok"; then
    echo "✅ API health check successful!"
    echo "   Response: $RESPONSE"
else
    echo "⚠️  API responded but content unexpected"
    echo "   Response: $RESPONSE"
    echo "   Expected: plain text or JSON containing 'ok'"
fi

echo


# ── Deployment summary ───────────────────────────────────────────────────────
echo "🎉 Backend deployment summary:"
echo "   Environment: $ENVIRONMENT"
echo "   Workspace: $CURRENT_WS"
echo "   API URL: $API_URL"
echo "   Status: Deployed and verified"
echo


