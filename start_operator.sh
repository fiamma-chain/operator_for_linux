#!/bin/bash

# Fiamma Operator Systemd Service Script
echo "==== Starting Fiamma Operator as a systemd service ===="

SERVICE_NAME="fiamma-operator"
SYSTEMD_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

# Get current directory (project path)
PROJECT_DIR=$(pwd)
LOG_DIR="$PROJECT_DIR/.logs/bitvm-operator"
PARENT_DIR=$(cd "$PROJECT_DIR/.." && pwd)

# Check if systemd is available
if ! pidof systemd > /dev/null; then
  echo "Error: systemd is not running or not available on this system."
  exit 1
fi

# Create systemd service unit file (if it doesn't exist)
if [ ! -f "$SYSTEMD_PATH" ]; then
  echo "Creating systemd service file at $SYSTEMD_PATH"
  sudo tee "$SYSTEMD_PATH" > /dev/null <<EOF
[Unit]
Description=Fiamma Operator Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/fiamma-operator
Environment=FIAMMA_MONO_CONFIG_PATH=$PARENT_DIR/operator_for_linux
Restart=on-failure
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable $SERVICE_NAME
fi

# Start the service
sudo systemctl restart $SERVICE_NAME
sleep 8

# Check service status
sudo systemctl status $SERVICE_NAME --no-pager
if systemctl is-active --quiet $SERVICE_NAME; then
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
  echo "==== Fiamma Operator systemd service is running ===="
  echo "To view logs: tail -f $LOG_DIR/bitvm-operator.$(date +%Y-%m-%d-%H).log"
else
  echo "Error: Fiamma Operator systemd service failed to start."
  exit 1
fi