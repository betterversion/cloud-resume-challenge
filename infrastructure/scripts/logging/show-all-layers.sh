#!/bin/bash
# show-all-layers.sh - Complete Infrastructure Overview with Logging
# Enhanced version with timestamped logging and output management

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

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"   
LOGS_DIR="$PROJECT_ROOT/logs"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LOG_FILE="$LOGS_DIR/infrastructure-overview-$TIMESTAMP.log"
LATEST_LOG="$LOGS_DIR/latest-overview.log"

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -q, --quiet    Don't display output to terminal (log only)"
    echo "  -n, --no-log   Don't save output to log file (terminal only)"
    echo "  -c, --cleanup  Remove log files older than 7 days"
    echo "  -l, --list     List recent log files"
    echo "  -v, --view     View the latest log file"
    echo ""
    echo "Examples:"
    echo "  $0              # Normal run with both terminal and log output"
    echo "  $0 --quiet      # Save to log only, no terminal output"
    echo "  $0 --no-log     # Terminal output only, no log file"
    echo "  $0 --cleanup    # Clean old logs and exit"
}

# Parse command line arguments
QUIET=false
NO_LOG=false
CLEANUP=false
LIST_LOGS=false
VIEW_LOG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -n|--no-log)
            NO_LOG=true
            shift
            ;;
        -c|--cleanup)
            CLEANUP=true
            shift
            ;;
        -l|--list)
            LIST_LOGS=true
            shift
            ;;
        -v|--view)
            VIEW_LOG=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to strip ANSI color codes for clean log output
strip_colors() {
    sed 's/\x1b\[[0-9;]*m//g'
}

# Function to ensure logs directory exists
ensure_logs_dir() {
    if [ ! -d "$LOGS_DIR" ]; then
        mkdir -p "$LOGS_DIR"
        echo "Created logs directory: $LOGS_DIR"
    fi
}

# Function to cleanup old logs
cleanup_logs() {
    ensure_logs_dir
    echo -e "${YELLOW}🧹 CLEANING UP OLD LOG FILES${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Find and remove files older than 7 days
    DELETED_COUNT=$(find "$LOGS_DIR" -name "infrastructure-overview-*.log" -type f -mtime +7 -delete -print | wc -l)

    if [ "$DELETED_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Deleted $DELETED_COUNT old log files (older than 7 days)${NC}"
    else
        echo -e "${CYAN}💡 No old log files found to delete${NC}"
    fi

    # Show remaining files
    echo ""
    list_logs
}

# Function to list recent logs
list_logs() {
    ensure_logs_dir
    echo -e "${YELLOW}📋 RECENT INFRASTRUCTURE LOG FILES${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if ls "$LOGS_DIR"/infrastructure-overview-*.log >/dev/null 2>&1; then
        echo -e "${BLUE}📁 Log Directory: ${NC}$LOGS_DIR"
        echo ""

        # List files with size and date, newest first
        ls -lt "$LOGS_DIR"/infrastructure-overview-*.log | head -10 | while read -r line; do
            filename=$(echo "$line" | awk '{print $NF}')
            filesize=$(echo "$line" | awk '{print $5}')
            filedate=$(echo "$line" | awk '{print $6, $7, $8}')
            basename_file=$(basename "$filename")

            echo -e "${GREEN}📄 ${basename_file}${NC}"
            echo -e "   📅 ${filedate} | 📊 ${filesize} bytes"
        done

        echo ""
        if [ -f "$LATEST_LOG" ]; then
            echo -e "${CYAN}🔗 Latest: $(readlink "$LATEST_LOG" 2>/dev/null || echo "latest-overview.log")${NC}"
        fi
    else
        echo -e "${RED}❌ No log files found in $LOGS_DIR${NC}"
        echo -e "${CYAN}💡 Run the script without --list to generate logs${NC}"
    fi
}

# Function to view latest log
view_log() {
    ensure_logs_dir
    if [ -f "$LATEST_LOG" ]; then
        echo -e "${YELLOW}📖 VIEWING LATEST INFRASTRUCTURE LOG${NC}"
        echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        cat "$LATEST_LOG"
    else
        echo -e "${RED}❌ No latest log file found${NC}"
        echo -e "${CYAN}💡 Run the script without --view to generate logs${NC}"
    fi
}

# Handle special commands
if [ "$CLEANUP" = true ]; then
    cleanup_logs
    exit 0
fi

if [ "$LIST_LOGS" = true ]; then
    list_logs
    exit 0
fi

if [ "$VIEW_LOG" = true ]; then
    view_log
    exit 0
fi

# Main script execution
main_content() {
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🌍 COMPLETE INFRASTRUCTURE STATUS               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Add metadata header
    echo "📊 INFRASTRUCTURE OVERVIEW REPORT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🕐 Generated: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "👤 User: $(whoami)"
    echo "💻 Host: $(hostname)"
    echo "📁 Working Directory: $(pwd)"
    echo "🔧 Script Version: v2.0 (Enhanced with Logging)"
    echo ""

    echo "🏗️  INFRASTRUCTURE LAYERS OVERVIEW"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show persistent layer
    echo "📊 PERSISTENT LAYER (Shared Infrastructure):"
    echo "   Website hosting, Database, IAM, SSL certificates"
    echo ""

    # Check if persistent script exists
    if [ -f "$SCRIPT_DIR/show-persistent-env.sh" ]; then
        "$SCRIPT_DIR/show-persistent-env.sh"
    else
        echo "❌ Error: show-persistent-env.sh not found in $SCRIPT_DIR"
        echo "💡 Make sure all scripts are in the same directory"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show application layer
    echo "🚀 APPLICATION LAYER (Blue-Green APIs):"
    echo "   Lambda functions, API Gateway, Monitoring"
    echo ""

    # Check if application script exists
    if [ -f "$SCRIPT_DIR/show-application-env.sh" ]; then
        "$SCRIPT_DIR/show-application-env.sh"
    else
        echo "❌ Error: show-application-env.sh not found in $SCRIPT_DIR"
        echo "💡 Make sure all scripts are in the same directory"
    fi

    echo ""
    echo "✅ Complete infrastructure overview finished!"
    echo "💡 Deploy workflow: Persistent → Application (Blue) → Application (Green)"
    echo ""
    echo "📁 Log saved to: $LOG_FILE"
    echo "🔗 Latest log: $LATEST_LOG"
}

# Execute main content with appropriate output handling
if [ "$NO_LOG" = true ]; then
    # Terminal only, with colors
    if [ "$QUIET" = false ]; then
        main_content | while IFS= read -r line; do
            echo -e "$line"
        done
    fi
else
    # Ensure logs directory exists
    ensure_logs_dir

    if [ "$QUIET" = true ]; then
        # Log only, no terminal output, strip colors
        main_content | strip_colors > "$LOG_FILE"
        # Create/update latest symlink
        ln -sf "$(basename "$LOG_FILE")" "$LATEST_LOG"
        echo "Log saved to: $LOG_FILE"
    else
        # Both terminal (with colors) and log (without colors)
        main_content | tee >(strip_colors > "$LOG_FILE") | while IFS= read -r line; do
            echo -e "$line"
        done
        # Create/update latest symlink
        ln -sf "$(basename "$LOG_FILE")" "$LATEST_LOG"
    fi
fi
