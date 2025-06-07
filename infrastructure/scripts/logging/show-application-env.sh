#!/bin/bash
# show-application-env.sh - Application layer (Lambda + API) status

set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ✅ FIXED: Go up TWO levels to reach project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TERRAFORM_APP_DIR="$PROJECT_ROOT/infrastructure/terraform/application"

echo -e "${CYAN}📁 Using terraform directory: ${TERRAFORM_APP_DIR}${NC}"

# Check if terraform directory exists
if [ ! -d "$TERRAFORM_APP_DIR" ]; then
    echo -e "${RED}❌ Error: Terraform application directory not found: ${TERRAFORM_APP_DIR}${NC}"
    echo -e "${YELLOW}💡 Expected directory structure:${NC}"
    echo -e "  $PROJECT_ROOT/infrastructure/scripts/show-application-env.sh (this script)"
    echo -e "  $PROJECT_ROOT/infrastructure/terraform/application/ (terraform files)"

    # Show what actually exists
    echo -e "${YELLOW}📂 What exists in project root:${NC}"
    ls -la "$PROJECT_ROOT" 2>/dev/null || echo "Cannot list project root contents"

    echo -e "${YELLOW}📂 What exists in infrastructure:${NC}"
    ls -la "$PROJECT_ROOT/infrastructure" 2>/dev/null || echo "Cannot list infrastructure contents"
    exit 1
fi

# Change to terraform directory
cd "$TERRAFORM_APP_DIR"
echo -e "${GREEN}✅ Changed to: $(pwd)${NC}"

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}⚠️  Terraform not initialized in application layer.${NC}"
    echo -e "${CYAN}💡 Run: cd terraform/application && terraform init${NC}"
    exit 1
fi

# Get current workspace
WORKSPACE=$(terraform workspace show 2>/dev/null || echo "default")

echo ""
echo -e "${WHITE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}║                🚀 APPLICATION LAYER STATUS                  ║${NC}"
echo -e "${WHITE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Environment Info
echo -e "${CYAN}🌍 Environment:${NC} ${GREEN}$WORKSPACE${NC}"
echo -e "${CYAN}🏗️  Layer:${NC}      ${BLUE}Application (Lambda + API Gateway + Monitoring)${NC}"
if terraform output environment_info &>/dev/null; then
    ENV_INFO=$(terraform output -json environment_info)
    echo -e "${CYAN}📍 Region:${NC}     $(echo $ENV_INFO | jq -r '.aws_region' 2>/dev/null)"
    echo -e "${CYAN}📊 Resources:${NC}  $(echo $ENV_INFO | jq -r '.resource_count' 2>/dev/null)"
else
    echo -e "${CYAN}📍 Region:${NC}     Unknown"
fi
echo ""

# Lambda Function Information
echo -e "${YELLOW}🔧 LAMBDA FUNCTION${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output lambda_info &>/dev/null; then
    LAMBDA_INFO=$(terraform output -json lambda_info)
    echo -e "${BLUE}🎯 Function Name:${NC}  $(echo $LAMBDA_INFO | jq -r '.function_name' 2>/dev/null)"
    echo -e "${BLUE}⚡ Runtime:${NC}       $(echo $LAMBDA_INFO | jq -r '.runtime' 2>/dev/null)"
    echo -e "${BLUE}⏱️  Timeout:${NC}       $(echo $LAMBDA_INFO | jq -r '.timeout' 2>/dev/null)s"
    echo -e "${BLUE}💾 Memory:${NC}        $(echo $LAMBDA_INFO | jq -r '.memory_size' 2>/dev/null)MB"
    echo -e "${BLUE}📦 Version:${NC}       $(echo $LAMBDA_INFO | jq -r '.version' 2>/dev/null)"
    echo -e "${BLUE}📏 Code Size:${NC}     $(echo $LAMBDA_INFO | jq -r '.source_code_size' 2>/dev/null) bytes"
else
    echo -e "${RED}🔧 Lambda info not available${NC}"
    echo -e "${CYAN}💡 Run: terraform apply${NC}"
fi
echo ""

# API Gateway Information
echo -e "${YELLOW}🌐 API GATEWAY${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output api_gateway_info &>/dev/null; then
    API_INFO=$(terraform output -json api_gateway_info)
    echo -e "${BLUE}🌍 API Name:${NC}       $(echo $API_INFO | jq -r '.api_name' 2>/dev/null)"
    echo -e "${BLUE}🆔 API ID:${NC}         $(echo $API_INFO | jq -r '.api_id' 2>/dev/null)"
    echo -e "${BLUE}🎭 Stage:${NC}          $(echo $API_INFO | jq -r '.stage_name' 2>/dev/null)"
    echo -e "${BLUE}📅 Created:${NC}        $(echo $API_INFO | jq -r '.created_date' 2>/dev/null)"
    echo -e "${BLUE}🏗️  Type:${NC}           $(echo $API_INFO | jq -r '.endpoint_type' 2>/dev/null)"
else
    echo -e "${RED}🌐 API Gateway info not available${NC}"
fi
echo ""

# API Endpoints
echo -e "${YELLOW}🌐 API ENDPOINTS${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output api_endpoints &>/dev/null; then
    ENDPOINTS=$(terraform output -json api_endpoints)
    echo -e "${GREEN}📊 Counter API:${NC}  $(echo $ENDPOINTS | jq -r '.counter_url' 2>/dev/null)"
    echo -e "${GREEN}💚 Health Check:${NC} $(echo $ENDPOINTS | jq -r '.health_url' 2>/dev/null)"
    echo -e "${GREEN}🔗 Base URL:${NC}     $(echo $ENDPOINTS | jq -r '.base_url' 2>/dev/null)"
else
    echo -e "${RED}🌐 API endpoints not available${NC}"
fi
echo ""

# Monitoring Information
echo -e "${YELLOW}📊 MONITORING & OBSERVABILITY${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output monitoring_info &>/dev/null; then
    MONITORING=$(terraform output -json monitoring_info)
    echo -e "${BLUE}📈 Dashboard:${NC}     $(echo $MONITORING | jq -r '.dashboard_name' 2>/dev/null)"
    echo -e "${BLUE}📝 Lambda Logs:${NC}   $(echo $MONITORING | jq -r '.lambda_log_group' 2>/dev/null)"
    echo -e "${BLUE}📝 API Logs:${NC}      $(echo $MONITORING | jq -r '.api_log_group' 2>/dev/null)"
    echo -e "${BLUE}⚠️  Alarms:${NC}        $(echo $MONITORING | jq -r '.alarm_count' 2>/dev/null)"
else
    echo -e "${RED}📊 Monitoring info not available${NC}"
fi
echo ""

# Quick Test Commands
echo -e "${YELLOW}💻 QUICK TEST COMMANDS${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output test_commands &>/dev/null; then
    TEST_CMDS=$(terraform output -json test_commands)
    echo -e "${PURPLE}Test Counter:${NC}"
    echo "  $(echo $TEST_CMDS | jq -r '.test_counter' 2>/dev/null)"
    echo ""
    echo -e "${PURPLE}Test Health:${NC}"
    echo "  $(echo $TEST_CMDS | jq -r '.test_health' 2>/dev/null)"
    echo ""
    echo -e "${PURPLE}View Lambda Logs:${NC}"
    echo "  $(echo $TEST_CMDS | jq -r '.view_lambda_logs' 2>/dev/null)"
    echo ""
    echo -e "${PURPLE}Invoke Lambda Directly:${NC}"
    echo "  $(echo $TEST_CMDS | jq -r '.invoke_lambda' 2>/dev/null)"
else
    echo -e "${RED}💻 Test commands not available${NC}"
    echo -e "${CYAN}💡 Run: terraform apply${NC}"
fi
echo ""

# AWS Console Quick Links
echo -e "${YELLOW}🔗 AWS CONSOLE QUICK LINKS${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if terraform output aws_console_links &>/dev/null; then
    CONSOLE_LINKS=$(terraform output -json aws_console_links)
    echo -e "${GREEN}🔧 Lambda Function:${NC}"
    echo "  $(echo $CONSOLE_LINKS | jq -r '.lambda_function' 2>/dev/null)"
    echo ""
    echo -e "${GREEN}🌐 API Gateway:${NC}"
    echo "  $(echo $CONSOLE_LINKS | jq -r '.api_gateway' 2>/dev/null)"
    echo ""
    echo -e "${GREEN}📈 CloudWatch Dashboard:${NC}"
    echo "  $(echo $CONSOLE_LINKS | jq -r '.cloudwatch_dashboard' 2>/dev/null)"
else
    echo -e "${RED}🔗 Console links not available${NC}"
fi
echo ""

# Workspace Status
# Workspace Status - SIMPLE VERSION
echo -e "${YELLOW}🔄 WORKSPACE STATUS${NC}"
echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CURRENT=$(terraform workspace show)

echo -e "${BLUE}📝 Available Workspaces:${NC}"
echo -e "  $([ "$CURRENT" = "default" ] && echo "${GREEN}●" || echo "${CYAN}○") default $([ "$CURRENT" = "default" ] && echo "${GREEN}← Current${NC}" || echo "${NC}")"
echo -e "  $([ "$CURRENT" = "blue" ] && echo "${GREEN}●" || echo "${CYAN}○") blue $([ "$CURRENT" = "blue" ] && echo "${GREEN}← Current${NC}" || echo "${NC}")"
echo -e "  $([ "$CURRENT" = "green" ] && echo "${GREEN}●" || echo "${CYAN}○") green $([ "$CURRENT" = "green" ] && echo "${GREEN}← Current${NC}" || echo "${NC}")"

echo ""
echo -e "${GREEN}✅ Application layer status complete!${NC}"
echo -e "${CYAN}💡 Usage from infrastructure/: ${WHITE}scripts/show-application-env.sh${NC}"
echo -e "${CYAN}🔄 Switch workspace: ${WHITE}cd terraform/application && terraform workspace select green${NC}"
echo -e "${CYAN}🧪 Test endpoints: ${WHITE}Copy test commands above${NC}"
