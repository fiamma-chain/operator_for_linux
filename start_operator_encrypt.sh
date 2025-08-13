#!/usr/bin/env bash
set -euo pipefail

echo "==== Starting Fiamma Operator as a user systemd service (GPG cache) ===="

SERVICE_NAME="fiamma-operator"
UNIT_DIR="$HOME/.config/systemd/user"
UNIT_PATH="$UNIT_DIR/${SERVICE_NAME}.service"

# Get current directory (project path)
PROJECT_DIR="$(pwd)"
LOG_DIR="$PROJECT_DIR/.logs/bitvm-operator"
PARENT_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

# Ensure user systemd directory exists
mkdir -p "$UNIT_DIR"

# Create user systemd service unit file (if it doesn't exist)
if [ ! -f "$UNIT_PATH" ]; then
  echo "Creating user systemd service file at $UNIT_PATH"
  cat > "$UNIT_PATH" <<EOF
[Unit]
Description=Fiamma Operator Service (User)
After=default.target

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/fiamma-operator
Environment=FIAMMA_MONO_CONFIG_PATH=$PARENT_DIR/operator_for_linux
Environment=RUST_MIN_STACK=16777216
Environment=GNUPGHOME=$HOME/.gnupg
Restart=always
RestartSec=15
StartLimitIntervalSec=0
StartLimitBurst=0
LimitSTACK=infinity

[Install]
WantedBy=default.target
EOF
fi

# Hint if linger is disabled (no sudo in this script)
if command -v loginctl >/dev/null 2>&1; then
  if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
    echo "⚠️  User lingering is disabled. To auto-start after reboot, run:"
    echo "   sudo loginctl enable-linger $USER"
  fi
fi

# Start the user service
systemctl --user daemon-reload
systemctl --user enable "$SERVICE_NAME"
systemctl --user restart "$SERVICE_NAME"

sleep 8
systemctl --user status "$SERVICE_NAME" --no-pager || true

if systemctl --user is-active --quiet "$SERVICE_NAME"; then
  echo ""
  echo "  _____ _                                "
  echo " |  ___(_) __ _ _ __ ___  _ __ ___   __ _ "
  echo " | |_  | |/ _\` | '_ \` _ \| '_ \` _ \ / _\` |"
  echo " |  _| | | (_| | | | | | | | | | | | (_| |"
  echo " |_|   |_|\__,_|_| |_| |_|_| |_| |_|\__,_|"
  echo "                                        "
  echo "   ___                       _             "
  echo "  / _ \ _ __   ___ _ __ __ _| |_ ___  _ __ "
  echo " | | | | '_ \ / _ \ '__/ _\` | __/ _ \| '__|"
  echo " | |_| | |_) |  __/ | | (_| | || (_) | |   "
  echo "  \___/| .__/ \___|_|  \__,_|\__\___/|_|   "
  echo "       |_|                                "
  echo ""
  echo "==== Fiamma Operator user systemd service is running ===="
  echo "To view logs: tail -f $LOG_DIR/bitvm-operator.$(date +%Y-%m-%d-%H).log"
else
  echo "Error: Fiamma Operator user systemd service failed to start."
  exit 1
fi

