# Fiamma Operator for Linux

This guide will help you set up and run the Fiamma Operator on Linux systems. The process involves four simple steps:

## Setup Process

### Step 1: Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/fiamma-chain/operator_for_linux.git
cd operator_for_linux
```

### Step 2: Prepare the Environment

Run the setup script to install all dependencies and prepare your environment:

```bash
./setup.sh
```

**Important:** After the first execution of `setup.sh`, you need to enable the Rust environment variables:

```bash
source "$HOME/.cargo/env"
```

Alternatively, you can restart your terminal or run:

```bash
source ~/.bashrc
# or if you're using zsh:
source ~/.zshrc
```

This script will:
- Install required packages (build-essential, gcc, g++, libssl-dev)
- Install and configure PostgreSQL
- Install Docker and Docker Compose (if not already installed)
- Install Rust and SQLx CLI
- Create a default .env file from .env_example
- Start database and Redis containers
- Set execute permissions on scripts

Next, run database migrations to set up the required database schema:

```bash
cd dal && cp .env.example .env && sqlx migrate run && cd ..
```

### Step 3: Configure Environment Variables

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

#### Sidechain RPC Configuration

Add the following sidechain RPC URLs to your `.env` file to enable cross-chain operations:

```bash
## BSC (Binance Smart Chain)
BITVM_BRIDGE_BSC_RPC_URL=https://bsc-testnet.bnbchain.org

## PHAROS
BITVM_BRIDGE_PHAROS_RPC_URL=https://testnet.dplabs-internal.com

## Core
BITVM_BRIDGE_CORE_RPC_URL=https://rpc.test2.btcs.network
```

These URLs configure the operator to connect to various blockchain networks supported by the Fiamma bridge.

### Step 4: Start the Operator

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

## Upgrading the Operator

To upgrade your Fiamma Operator to the latest version, follow these steps:

### Step 1: Verify Database Status
Ensure the database Docker container is running:
```bash
sudo docker ps | grep postgres
```

### Step 2: Pull Latest Updates
Pull the latest code from the repository:
```bash
git pull
```

### Step 3: Update Database Schema
Run database migrations to apply any schema changes:
```bash
cd dal && sqlx migrate run && cd ..
```

### Step 4: Restart the Operator Service
Restart the Fiamma Operator service to apply updates:
```bash
sudo systemctl restart fiamma-operator
```

### Step 5: Verify Upgrade
Check that the operator is running correctly after the upgrade:
```bash
sudo systemctl status fiamma-operator
```

**Note**: Always backup your data before performing upgrades, especially in production environments.

## Troubleshooting

If you encounter issues:

1. Verify the database and Redis are running:
   ```bash
   sudo docker ps | grep postgres
   sudo docker ps | grep redis
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
