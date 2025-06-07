#!/bin/bash
# show-persistent-env.sh - Persistent Layer Environment Display
# Updated for reliable path resolution

set -e

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TERRAFORM_PERSISTENT_DIR="$PROJECT_ROOT/infrastructure/terraform/persistent"

echo -e "${CYAN}📁 Using terraform directory: ${TERRAFORM_PERSISTENT_DIR}${NC}"

# Check if terraform directory exists
if [ ! -d "$TERRAFORM_PERSISTENT_DIR" ]; then
    echo -e "${RED}❌ Error: Terraform persistent directory not found: ${TERRAFORM_PERSISTENT_DIR}${NC}"
    echo -e "${YELLOW}💡 Expected directory structure:${NC}"
    echo -e "  $PROJECT_ROOT/infrastructure/scripts/show-persistent-env.sh (this script)"
    echo -e "  $PROJECT_ROOT/infrastructure/terraform/persistent/ (terraform files)"

    # Show what actually exists
    echo -e "${YELLOW}📂 What exists in project root:${NC}"
    ls -la "$PROJECT_ROOT" 2>/dev/null || echo "Cannot list project root contents"

    echo -e "${YELLOW}📂 What exists in infrastructure:${NC}"
    ls -la "$PROJECT_ROOT/infrastructure" 2>/dev/null || echo "Cannot list infrastructure contents"
    exit 1
fi

# Change to terraform directory
cd "$TERRAFORM_PERSISTENT_DIR"
echo -e "${GREEN}✅ Changed to: $(pwd)${NC}"

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}⚠️  Terraform not initialized in persistent layer.${NC}"
    echo -e "${CYAN}💡 Run: cd terraform/persistent && terraform init${NC}"
    exit 1
fi

echo ""
echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}║                🏗️  PERSISTENT LAYER STATUS                  ║${NC}"
echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Environment Info
echo -e "${CYAN}🌍 Layer Type:${NC}  ${BLUE}Persistent (Shared Infrastructure)${NC}"
echo -e "${CYAN}📍 Region:${NC}     $(terraform output -raw aws_region 2>/dev/null || echo 'Unknown')"
echo -e "${CYAN}🔐 Account:${NC}    $(terraform output -raw account_id 2>/dev/null || echo 'Unknown')"
echo ""

# Website Infrastructure
echo -e "${YELLOW}🌐 WEBSITE HOSTING${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
WEBSITE_URL=$(terraform output -raw website_url 2>/dev/null || echo 'Not deployed')
CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null || echo 'Not deployed')
WEBSITE_BUCKET=$(terraform output -raw website_bucket_name 2>/dev/null || echo 'Not deployed')

echo -e "${GREEN}🌍 Website URL:${NC}      ${WEBSITE_URL}"
echo -e "${GREEN}☁️  CloudFront ID:${NC}   ${CLOUDFRONT_ID}"
echo -e "${GREEN}🪣 S3 Bucket:${NC}        ${WEBSITE_BUCKET}"
echo ""

# Database Infrastructure
echo -e "${YELLOW}🗄️ DATABASE${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output dynamodb_table_info &>/dev/null; then
    DB_INFO=$(terraform output -json dynamodb_table_info)
    echo -e "${BLUE}📊 Table Name:${NC}     $(echo $DB_INFO | jq -r '.table_name' 2>/dev/null)"
    echo -e "${BLUE}💳 Billing Mode:${NC}   $(echo $DB_INFO | jq -r '.billing_mode' 2>/dev/null)"
    echo -e "${BLUE}🔑 Hash Key:${NC}       $(echo $DB_INFO | jq -r '.hash_key' 2>/dev/null)"
    echo -e "${BLUE}🔄 PITR Enabled:${NC}   $(echo $DB_INFO | jq -r '.pitr_enabled' 2>/dev/null)"
else
    echo -e "${RED}🗄️ Database info not available${NC}"
fi
echo ""

# Security Infrastructure
echo -e "${YELLOW}🔐 SECURITY & IAM${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
LAMBDA_ROLE=$(terraform output -raw lambda_execution_role_name 2>/dev/null || echo 'Not deployed')
CERT_STATUS=$(terraform output -raw consolidated_cert_status 2>/dev/null || echo 'Unknown')

echo -e "${BLUE}🎭 Lambda IAM Role:${NC}  ${LAMBDA_ROLE}"
echo -e "${BLUE}🔒 SSL Certificate:${NC}  ${CERT_STATUS}"
echo ""

# Quick Commands
echo -e "${YELLOW}💻 DEPLOYMENT COMMANDS${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if terraform output website_sync_blue_command &>/dev/null; then
    echo -e "${PURPLE}Deploy to Blue:${NC}"
    echo "  $(terraform output -raw website_sync_blue_command 2>/dev/null)"
    echo ""
    echo -e "${PURPLE}Deploy to Green:${NC}"
    echo "  $(terraform output -raw website_sync_green_command 2>/dev/null)"
    echo ""
    echo -e "${PURPLE}Invalidate Cache:${NC}"
    echo "  $(terraform output -raw cache_invalidation_command 2>/dev/null)"
    echo ""
    echo -e "${PURPLE}Check S3 Contents:${NC}"
    echo "  $(terraform output -raw s3_list_environments_command 2>/dev/null)"
else
    echo -e "${RED}💻 Deployment commands not available${NC}"
    echo -e "${CYAN}💡 Run: terraform apply${NC}"
fi
echo ""

# AWS Console Links
echo -e "${YELLOW}🔗 AWS CONSOLE QUICK LINKS${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if terraform output aws_console_links &>/dev/null; then
    CONSOLE_LINKS=$(terraform output -json aws_console_links)
    echo -e "${GREEN}🪣 S3 Website Bucket:${NC}"
    echo "  $(echo $CONSOLE_LINKS | jq -r '.s3_website_bucket' 2>/dev/null)"
    echo ""
    echo -e "${GREEN}☁️  CloudFront Console:${NC}"
    echo "  $(echo $CONSOLE_LINKS | jq -r '.cloudfront_console' 2>/dev/null)"
    echo ""
    echo -e "${GREEN}🗃️  DynamoDB Console:${NC}"
    echo "  $(echo $CONSOLE_LINKS | jq -r '.dynamodb_console' 2>/dev/null)"
else
    echo -e "${RED}🔗 Console links not available${NC}"
fi
echo ""

# S3 Environment Structure
echo -e "${YELLOW}📁 S3 ENVIRONMENT STRUCTURE${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
BUCKET_NAME=$(terraform output -raw website_bucket_name 2>/dev/null)
if [ "$BUCKET_NAME" != "Not deployed" ] && [ "$BUCKET_NAME" != "" ]; then
    echo -e "${BLUE}📂 S3 Structure:${NC}"
    echo "  s3://${BUCKET_NAME}/"
    echo "    ├── blue/     ← Blue environment files"
    echo "    └── green/    ← Green environment files"
    echo ""
    echo -e "${CYAN}💡 Hugo builds to: frontend/hugo/public/${NC}"
    echo -e "${CYAN}💡 CloudFront origin path: /\${environment}${NC}"
else
    echo -e "${RED}📂 S3 bucket not deployed${NC}"
fi

echo ""
echo -e "${GREEN}✅ Persistent layer status complete!${NC}"
echo -e "${CYAN}💡 Usage from infrastructure/: ${WHITE}scripts/show-persistent-env.sh${NC}"
echo -e "${CYAN}🔗 Website deployment: ${WHITE}Deploy Hugo → S3/env/ → CloudFront${NC}"
