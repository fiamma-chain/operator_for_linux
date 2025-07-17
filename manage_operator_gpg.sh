#!/bin/bash

# Fiamma Operator Management Script for GPG Mode
# This script helps manage the operator when using GPG encrypted private keys

set -e

OPERATOR_NAME="fiamma-operator"
PID_FILE=".logs/operator.pid"
LOG_FILE=".logs/operator.log"
SCREEN_SESSION="fiamma-operator"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if operator is running
check_status() {
    if pgrep -f "$OPERATOR_NAME" > /dev/null; then
        local pid=$(pgrep -f "$OPERATOR_NAME")
        log_success "Operator is running (PID: $pid)"
        return 0
    else
        log_warning "Operator is not running"
        return 1
    fi
}

# Start operator in screen session
start_operator() {
    if check_status > /dev/null 2>&1; then
        log_warning "Operator is already running"
        return 1
    fi

    log_info "Starting operator in screen session..."
    log_info "Config path: FIAMMA_MONO_CONFIG_PATH=./"
    log_info "You will be prompted for GPG password"
    
    # Ensure logs directory exists
    mkdir -p .logs
    
    # Start screen session with operator
    screen -dmS "$SCREEN_SESSION" bash -c "export FIAMMA_MONO_CONFIG_PATH=./ && ./fiamma-operator 2>&1 | tee $LOG_FILE"
    
    # Wait a moment and check if it started
    sleep 2
    if check_status > /dev/null 2>&1; then
        log_success "Operator started in screen session: $SCREEN_SESSION"
        log_info "To view the session: screen -r $SCREEN_SESSION"
        log_info "To detach from session: Ctrl+A, then D"
        log_info "To view logs: tail -f $LOG_FILE"
    else
        log_error "Failed to start operator"
        return 1
    fi
}

# Stop operator
stop_operator() {
    if ! check_status > /dev/null 2>&1; then
        log_warning "Operator is not running"
        return 1
    fi

    log_info "Stopping operator..."
    
    # Kill the process
    pkill -f "$OPERATOR_NAME" || true
    
    # Kill screen session if exists
    screen -S "$SCREEN_SESSION" -X quit 2>/dev/null || true
    
    # Remove PID file if exists
    [ -f "$PID_FILE" ] && rm -f "$PID_FILE"
    
    # Wait and verify
    sleep 2
    if ! check_status > /dev/null 2>&1; then
        log_success "Operator stopped successfully"
    else
        log_error "Failed to stop operator"
        return 1
    fi
}

# Restart operator
restart_operator() {
    log_info "Restarting operator..."
    stop_operator
    sleep 2
    start_operator
}

# Attach to screen session
attach_session() {
    if ! screen -list | grep -q "$SCREEN_SESSION"; then
        log_error "No screen session found: $SCREEN_SESSION"
        return 1
    fi
    
    log_info "Attaching to screen session: $SCREEN_SESSION"
    screen -r "$SCREEN_SESSION"
}

# Show logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        log_info "Showing operator logs (Ctrl+C to exit):"
        tail -f "$LOG_FILE"
    else
        log_error "Log file not found: $LOG_FILE"
        return 1
    fi
}

# Show usage
show_usage() {
    echo "Fiamma Operator Management Script (GPG Mode)"
    echo ""
    echo "Usage: $0 {start|stop|restart|status|attach|logs}"
    echo ""
    echo "Commands:"
    echo "  start   - Start operator in screen session (will prompt for GPG password)"
    echo "  stop    - Stop operator and cleanup"
    echo "  restart - Stop and start operator (requires password re-entry)"
    echo "  status  - Check if operator is running"
    echo "  attach  - Attach to the screen session"
    echo "  logs    - Show live logs"
    echo ""
    echo "Note: This script is designed for GPG encrypted private keys mode."
    echo "For plaintext keys, use systemctl commands instead."
}

# Main script logic
case "$1" in
    start)
        start_operator
        ;;
    stop)
        stop_operator
        ;;
    restart)
        restart_operator
        ;;
    status)
        check_status
        ;;
    attach)
        attach_session
        ;;
    logs)
        show_logs
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

exit 0 