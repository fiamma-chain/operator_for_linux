#!/bin/bash

# Environment preparation script

echo "🚀 ==== Starting Environment Preparation ===="

# Exit on error
set -e

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install development essentials (including C compiler)
echo "🔨 Installing development essentials..."
sudo apt install -y build-essential gcc g++ pkg-config libssl-dev

# Install PostgreSQL
echo "🐘 Installing PostgreSQL..."
if ! command -v psql &> /dev/null; then
    sudo apt install -y postgresql 
fi
echo "✅ PostgreSQL installed."    


# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Add the current user to the docker group
    sudo groupadd docker 2>/dev/null || true
    sudo usermod -aG docker $USER
    echo "✅ Added user to docker group. You may need to log out and back in for changes to take effect."
    
    # Configure Docker to start on boot
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "✅ Docker installed. You may need to log out and back in for group changes to take effect."
else
    echo "✅ Docker is already installed."
fi


# Install Rust (if not already installed)
if ! command -v rustc &> /dev/null; then
    echo "🦀 Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo "🦀 Rust is already installed, updating to latest version..."
    rustup update
fi

# Install SQLx CLI
echo "🔧 Installing SQLx CLI..."
cargo install sqlx-cli
source "$HOME/.cargo/env"
echo "✅ SQLx CLI installed."

# Detect shell and add cargo env to shell rc file
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

if ! grep -q 'source \$HOME/.cargo/env' "$SHELL_RC"; then
    echo "📦 Adding 'source \$HOME/.cargo/env' to $SHELL_RC..."
    echo 'source $HOME/.cargo/env' >> "$SHELL_RC"
fi

# Ensure all scripts have execute permissions
echo "🔐 Setting script execute permissions..."
chmod +x "$SCRIPT_DIR"/*.sh
echo "✅ Execute permissions set."

# Create .env file (if it doesn't exist)
if [ ! -f "$SCRIPT_DIR/.env" ] && [ -f "$SCRIPT_DIR/.env_example" ]; then
    echo "📄 Creating .env file from .env_example..."
    cp "$SCRIPT_DIR/.env_example" "$SCRIPT_DIR/.env"
    echo "✅ .env file created. Please edit the .env file if needed."
else
    echo "✅ .env file already exists."
fi

# Try to start the database
echo "🛢️ Attempting to start the database..."
cd "$SCRIPT_DIR"
sg docker -c "./start_db.sh" || {
    echo "⚠️ Note: Database startup may require configuration. Please check for errors and resolve manually."
}

# Try to start Redis
echo "🔄 Attempting to start Redis..."
cd "$SCRIPT_DIR"
sg docker -c "./start_redis.sh" || {
    echo "⚠️ Note: Redis startup may require configuration. Please check for errors and resolve manually."
}

echo "🎉 ==== Environment Preparation Complete ===="
echo "📋 If you encounter any issues, check the status of related services and logs:"
echo "🐘 PostgreSQL status: sudo docker ps | grep postgres"
echo "🔄 Redis status: sudo docker ps | grep redis"
echo ""
echo "▶️ Next, you can try running:"
echo "./start_operator.sh"
