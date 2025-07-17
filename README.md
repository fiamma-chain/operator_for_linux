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

#### Option 1: Plaintext Private Keys (for testing)
Make sure to update these required private keys:
```
# ⚠️  WARNING: Replace with your REAL private keys, these are just examples!
BITVM_BRIDGE_OPERATOR_AUTH_SK=L1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12
BITVM_BRIDGE_OPERATOR_PEGIN_SK=L2234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef23
BITVM_BRIDGE_OPERATOR_PEGOUT_SK=L3234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef34
```

#### Option 2: GPG Encrypted Private Keys (recommended for production)
For enhanced security, you can use GPG-encrypted private keys:

1. **Create plaintext keys file**:
   ```bash
   # ⚠️  WARNING: Replace with your REAL private keys!
   cat > keys_input.env << EOF
   BITVM_BRIDGE_OPERATOR_AUTH_SK=L1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12
   BITVM_BRIDGE_OPERATOR_PEGIN_SK=L2234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef23
   BITVM_BRIDGE_OPERATOR_PEGOUT_SK=L3234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef34
   EOF
   ```

2. **Encrypt the keys using bcli**:
   ```bash
   ./bcli encode -i keys_input.env -o .env
   # Enter encryption password when prompted
   ```

3. **Enable GPG mode in .env**:
   ```bash
   echo "BITVM_BRIDGE_USE_GPG_KEYS=1" >> .env
   ```

4. **Clean up plaintext file**:
   ```bash
   rm keys_input.env
   ```

**Note**: When using GPG encrypted keys, the operator will prompt for the decryption password during startup.

These private keys are essential for the Operator to function correctly and should not be the same.

### Step 4: Start the Operator

The startup method depends on your private key configuration:

#### For Plaintext Private Keys (systemd service)

Run the start script to set up and start the Operator as a system service:

```bash
./start_operator.sh
```

This script will:
- Create a systemd service for the Operator
- Configure it to run in the current directory
- Start the service and verify it's running
- Set up appropriate logs

#### For GPG Encrypted Private Keys (manual startup)

**Important**: GPG mode requires interactive password input, so systemctl/systemd service mode is **not supported**. You must start the operator manually.

**Option 1: Foreground (recommended for testing)**
```bash
# Set config path and start operator
export FIAMMA_MONO_CONFIG_PATH=./
./fiamma-operator
# Enter GPG password when prompted: 🔐 Enter GPG decryption password:
```

**Option 2: Background with nohup**
```bash
# Set config path
export FIAMMA_MONO_CONFIG_PATH=./

# Start in foreground first to enter password
./fiamma-operator
# After successful startup and password entry, you can:
# 1. Stop the process (Ctrl+C)
# 2. Restart with nohup for background operation

# For background operation (after initial password setup):
nohup env FIAMMA_MONO_CONFIG_PATH=./ ./fiamma-operator > .logs/operator.log 2>&1 &
echo $! > .logs/operator.pid  # Save process ID
```

**Option 3: Using screen/tmux (recommended for production)**
```bash
# Install screen if not available
sudo apt-get install screen

# Start a screen session
screen -S fiamma-operator

# Inside screen, set config path and start the operator
export FIAMMA_MONO_CONFIG_PATH=./
./fiamma-operator
# Enter password when prompted

# Detach from screen: Ctrl+A, then D
# To reattach: screen -r fiamma-operator
```

**Option 4: Using the management script (easiest)**
We provide a helper script to simplify GPG mode management:
```bash
# Make script executable (first time only)
chmod +x manage_operator_gpg.sh

# Start operator (will prompt for GPG password)
./manage_operator_gpg.sh start

# Check status
./manage_operator_gpg.sh status

# View logs
./manage_operator_gpg.sh logs

# Stop operator
./manage_operator_gpg.sh stop

# Get help
./manage_operator_gpg.sh
```

## Managing the Operator

The management commands depend on how you started the operator:

### For Systemd Service (Plaintext Keys)

#### View Status
```bash
sudo systemctl status fiamma-operator
```

#### View Logs
```bash
tail -f .logs/bitvm-operator/bitvm-operator.$(date +%Y-%m-%d).log
```

#### Restart the Service
```bash
sudo systemctl restart fiamma-operator
```

#### Stop the Service
```bash
sudo systemctl stop fiamma-operator
```

### For Manual Startup (GPG Encrypted Keys)

#### Using the Management Script (Recommended)
```bash
# Check status
./manage_operator_gpg.sh status

# View logs
./manage_operator_gpg.sh logs

# Stop operator
./manage_operator_gpg.sh stop

# Restart operator (requires password re-entry)
./manage_operator_gpg.sh restart
```

#### Manual Commands
```bash
# Check if process is running
ps aux | grep fiamma-operator | grep -v grep

# Or using saved PID file (if using nohup method)
if [ -f .logs/operator.pid ]; then
    pid=$(cat .logs/operator.pid)
    if ps -p $pid > /dev/null; then
        echo "Operator is running (PID: $pid)"
    else
        echo "Operator is not running"
    fi
fi
```

#### View Logs
```bash
# For nohup method
tail -f .logs/operator.log

# For screen/tmux method
tail -f .logs/bitvm-operator/bitvm-operator.$(date +%Y-%m-%d).log

# Or attach to screen session
screen -r fiamma-operator
```

#### Stop the Operator
```bash
# Method 1: Using saved PID
if [ -f .logs/operator.pid ]; then
    kill $(cat .logs/operator.pid)
    rm .logs/operator.pid
fi

# Method 2: Find and kill process
pkill -f fiamma-operator

# Method 3: For screen session
screen -r fiamma-operator
# Then Ctrl+C to stop, then 'exit' to close session
```

#### Restart the Operator (GPG Mode)
```bash
# 1. Stop the current process
pkill -f fiamma-operator

# 2. Wait a moment
sleep 2

# 3. Set config path and start again (will prompt for password)
export FIAMMA_MONO_CONFIG_PATH=./
./fiamma-operator
# Or use screen/nohup as described in Step 4
```

**Note**: For GPG mode, each restart requires re-entering the decryption password.

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

### GPG-Related Issues

If you're using GPG encrypted private keys:

5. **systemctl doesn't work with GPG mode**:
   ```
   Error: Service fails to start or operator doesn't respond
   ```
   **Solution**: GPG mode requires interactive password input. You **cannot** use systemctl:
   ```bash
   # ❌ Don't use this with GPG mode
   sudo systemctl start fiamma-operator
   
   # ✅ Use manual startup instead
   ./fiamma-operator
   ```

6. **GPG not found error**:
   ```bash
   # Install GPG if not available
   sudo apt-get update && sudo apt-get install gnupg
   ```

7. **Incorrect GPG password**:
   - Verify you're entering the same password used during encryption
   - The password prompt will show: `🔐 Enter GPG decryption password:`
   - Password is hidden (no characters shown while typing)

8. **GPG decryption fails**:
   ```bash
   # Test GPG decryption manually
   echo "your_encrypted_base64_string" | base64 -d | gpg --decrypt --pinentry-mode loopback --batch --quiet
   ```

9. **Re-encrypt keys if needed**:
   ```bash
   # If you need to change the encryption password
   ./bcli encode -i your_plaintext_keys.env -o .env
   # Then ensure BITVM_BRIDGE_USE_GPG_KEYS=1 is set
   ```

10. **Process management in GPG mode**:
    ```bash
    # Check if operator is running
    ps aux | grep fiamma-operator | grep -v grep
    
    # Stop operator
    pkill -f fiamma-operator
    
    # For background operation, use screen
    screen -S fiamma-operator
    ./fiamma-operator  # Enter password
    # Ctrl+A, D to detach
    ```
