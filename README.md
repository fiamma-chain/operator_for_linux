# Fiamma Operator for Linux

This guide will help you set up and run the Fiamma Operator on Linux systems. The process involves three simple steps:

## Setup Process

### Step 1: Prepare the Environment

Run the setup script to install all dependencies and prepare your environment:

```bash
./setup.sh
```

This script will:
- Install required packages (build-essential, gcc, g++, libssl-dev)
- Install and configure PostgreSQL
- Install Docker and Docker Compose (if not already installed)
- Install Rust and SQLx CLI
- Create a default .env file from .env_example
- Start database and Redis containers
- Set execute permissions on scripts

### Step 2: Configure Environment Variables

Edit the `.env` file and set the following important keys:

```bash
vim .env
```

Make sure to update these required private keys:
```
BITVM_BRIDGE_OPERATOR_AUTH_SK=your_auth_private_key
BITVM_BRIDGE_OPERATOR_PEGIN_SK=your_pegin_private_key
BITVM_BRIDGE_OPERATOR_PEGOUT_SK=your_pegout_private_key
```

These private keys are essential for the Operator to function correctly and should not be the same.

### Step 3: Start the Operator

Run the start script to set up and start the Operator as a system service:

```bash
./start_operator.sh
```

This script will:
- Create a systemd service for the Operator
- Configure it to run in the current directory
- Start the service and verify it's running
- Set up appropriate logs

## Managing the Operator

### View Status
```bash
sudo systemctl status fiamma-operator
```

### View Logs
```bash
tail -f .logs/bitvm-operator/bitvm-operator.$(date +%Y-%m-%d).log
```

### Restart the Service
```bash
sudo systemctl restart fiamma-operator
```

### Stop the Service
```bash
sudo systemctl stop fiamma-operator
```

## Troubleshooting

If you encounter issues:

1. Verify the database and Redis are running:
   ```bash
   docker ps | grep postgres
   docker ps | grep redis
   ```

2. Check if the environment variables are set correctly in the `.env` file.

3. Ensure the operator binary has execute permissions:
   ```bash
   chmod +x fiamma-operator
   ```

4. Check the logs for specific errors:
   ```bash
   tail -f .logs/bitvm-operator/bitvm-operator.$(date +%Y-%m-%d).log
   ```
