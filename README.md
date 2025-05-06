# operator_for_linux

This project provides automated setup and startup for the Fiamma Operator as a systemd service on Linux systems.

## Prerequisites

### Install Docker
 
You can refer to the official Docker installation guide for your Linux distribution:

https://docs.docker.com/engine/install/ubuntu/

When you have installed Docker, you should follow the post-installation steps to make it work better:

https://docs.docker.com/engine/install/linux-postinstall/

### System Requirements

- Systemd (available on most modern Linux distributions)
- Sufficient permissions to create and manage systemd services (sudo access)

## Start the Operator

The operator can be started as a systemd service using the provided script:

```bash
./start_operator.sh
```

This script will:
1. Check if systemd is available on your system
2. Create a log directory at `.logs/bitvm-operator`
3. Create a systemd service unit file (if it doesn't exist)
4. Enable and start the service
5. Verify the service is running properly

## Configuration Options

### Modifying the Systemd Service

The systemd service created by the script has the following default configuration:

```
[Unit]
Description=Fiamma Operator Service
After=network.target

[Service]
Type=simple
WorkingDirectory=[current directory]
ExecStart=[current directory]/fiamma-operator
Environment=FIAMMA_MONO_CONFIG_PATH=[parent directory]/operator_for_linux
Restart=on-failure
StandardOutput=append:[log directory]/bitvm-operator.[date].log
StandardError=append:[log directory]/bitvm-operator.[date].log

[Install]
WantedBy=multi-user.target
```

To modify these settings, you can:

1. Edit the script before running it to change the service configuration
2. Manually edit the service file after creation at `/etc/systemd/system/fiamma-operator.service`

After any manual changes to the service file, run:

```bash
sudo systemctl daemon-reload
sudo systemctl restart fiamma-operator
```

### Environment Variables

The operator uses the following environment variables:

- `FIAMMA_MONO_CONFIG_PATH`: Set to the parent directory of the current working directory followed by `/operator_for_linux`

To change environment variables:

1. Edit the `start_operator.sh` script before running it
2. Or, edit the systemd service file directly and add/modify the Environment lines

### Log Configuration

Logs are stored in:
- `.logs/bitvm-operator/bitvm-operator.YYYY-MM-DD.log`

To view logs in real-time:

```bash
tail -f .logs/bitvm-operator/bitvm-operator.$(date +%Y-%m-%d).log
```

## Managing the Operator Service

### Service Status

```bash
sudo systemctl status fiamma-operator
```

### Restart Service

```bash
sudo systemctl restart fiamma-operator
```

### Stop Service

```bash
sudo systemctl stop fiamma-operator
```

### Enable/Disable Service at Boot

```bash
sudo systemctl enable fiamma-operator   # Start at boot
sudo systemctl disable fiamma-operator  # Don't start at boot
```

## Troubleshooting

If the operator fails to start:

1. Check systemd service status:
   ```bash
   sudo systemctl status fiamma-operator
   ```

2. Review the logs:
   ```bash
   tail -f .logs/bitvm-operator/bitvm-operator.$(date +%Y-%m-%d).log
   ```

3. Verify the executable permissions:
   ```bash
   chmod +x fiamma-operator
   ```

4. Ensure the working directory and environment variables are set correctly in the service file



