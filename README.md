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

## Start with GPG-encrypted private keys (via gpg-agent cache)

This section adds a GPG-encrypted workflow without changing the original plaintext flow. You can keep using the original flow, or switch to encrypted keys with gpg-agent caching for systemd auto-restarts.

### Step A: Generate encrypted keys with bcli

1) Prepare a temporary plaintext file (do not keep it after encoding):

```bash
cat > /tmp/keys.env <<'EOF'
BITVM_BRIDGE_OPERATOR_AUTH_SK="your_auth_wif"
BITVM_BRIDGE_OPERATOR_PEGIN_SK="your_pegin_wif"
BITVM_BRIDGE_OPERATOR_PEGOUT_SK="your_pegout_wif"
BITVM_BRIDGE_OPERATOR_ETH_SK="0xYourEvmPrivateKey"
EOF
chmod 600 /tmp/keys.env
```

**Important security notes about /tmp/keys.env**:
- This file contains plaintext private keys. Treat it as highly sensitive and only keep it for the briefest time needed to run the encoder.
- Prefer a throwaway file and remove it immediately after encoding using a secure delete, for example:
  - `shred -u /tmp/keys.env` (already shown below), or remove the file on a tmpfs (e.g., `/run` on many systems).
- Avoid opening this file in editors that create backup/swap files. The redirection shown above (`cat > file <<EOF`) prevents accidental editor backups.
- Ensure strict permissions (chmod 600) and do not commit this file to any repository or copy it into backups.
- If you use shell history, avoid pasting secrets directly on the command line; the here‑document block above is safer than inline echo.

2) Use the CLI encoder to symmetrically encrypt and output BASE64 ciphertexts:

```bash
# from repo root or ensure ./bcli exists in current dir
# optional: export BCLI_PASSWORD to avoid prompt
# export BCLI_PASSWORD='your-strong-passphrase'
./bcli encode -i /tmp/keys.env -o ./gpg.env.encode
```

3) Append the following flags to enable GPG + agent mode in your `.env`:

```bash
echo 'BITVM_BRIDGE_USE_GPG_KEYS=1' >> ./.env
echo 'BITVM_BRIDGE_USE_GPG_AGENT=1' >> ./.env
```

4) Copy the encrypted values into your project `.env` (replace the four keys):

```bash
sed -n 's/^\(BITVM_BRIDGE_OPERATOR_.*_SK\)=.*$/\1/p' ./gpg.env.encode | while read -r key; do
  val=$(grep "^$key=" ./gpg.env.encode | cut -d '"' -f2)
  # update .env in-place
  sed -i "s#^$key=.*#$key=\"$val\"#" ./.env
done
```

5) Remove the temporary plaintext file:

```bash
shred -u /tmp/keys.env
```

### Step B: Pre-warm gpg-agent cache once

Do this as the same user that will run the operator (e.g. `ubuntu`). The passphrase will be cached for half year depending on your `~/.gnupg/gpg-agent.conf`.

```bash
# Optional but recommended TTL settings in ~/.gnupg/gpg-agent.conf:
# default-cache-ttl 15552000
# max-cache-ttl 15552000
# pinentry-program /usr/bin/pinentry-curses

# If you changed gpg-agent.conf, reload the agent to apply settings
gpgconf --kill gpg-agent || true
gpg-connect-agent reloadagent /bye || true

# Ensure pinentry is available (Debian/Ubuntu)
# sudo apt-get install -y pinentry-curses

# Pre-warm MUST be done in a TTY with GPG_TTY set (interactive first)
export GPG_TTY=$(tty)
VAL=$(grep "^BITVM_BRIDGE_OPERATOR_AUTH_SK=" .env | cut -d '"' -f2)
printf "%s" "$VAL" | base64 -d | gpg --decrypt >/dev/null

# Verify non-interactive decryption works via gpg-agent cache
printf "%s" "$VAL" | base64 -d | gpg --decrypt --batch --quiet >/dev/null && echo OK || echo FAIL

# Warm up using one encrypted key from .env
VAL=$(grep "^BITVM_BRIDGE_OPERATOR_AUTH_SK=" .env | cut -d '"' -f2)
printf "%s" "$VAL" | base64 -d | gpg --decrypt >/dev/null
```

### Step C: Start with user-level systemd (uses your gpg-agent cache)

Use the provided helper to install and start a user-level unit so the service shares your gpg-agent environment (no sudo needed):

```bash
chmod +x ./start_operator_encrypt.sh
./start_operator_encrypt.sh
```

Notes:
- The original `./start_operator.sh` (system-level) remains unchanged and can still be used with plaintext keys.
- With the encrypted flow, user-level systemd is recommended so the process can access the user’s gpg-agent cache; crash/exit will auto-restart.
