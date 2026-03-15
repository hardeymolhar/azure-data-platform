#!/usr/bin/env bash
set -euo pipefail

echo "Installing required tools..."
sudo dnf install -y curl git

echo "Downloading .NET installer..."
curl -Ls https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
sudo chmod +x /tmp/dotnet-install.sh

echo "Installing .NET SDK (8.0)..."
sudo /tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/local/dotnet

echo "Adding .NET SDK to PATH permanently..."

sudo tee /etc/profile.d/dotnet.sh >/dev/null <<'EOF'
export DOTNET_ROOT=/usr/local/dotnet
export PATH=\$DOTNET_ROOT:\$PATH
EOF

sudo chmod 644 /etc/profile.d/dotnet.sh

# Load dotnet variables in current shell
source /etc/profile.d/dotnet.sh

echo "Cloning repository..."
sudo git clone https://github.com/hardeymolhar/azure-data-platform.git /home/app

echo "Changing ownership of /home/app to azureuser..."
sudo chown -R azureuser:azureuser /home/app

echo "Configuring Cosmos DB environment variables..."
sudo tee /etc/profile.d/cosmos.sh >/dev/null <<'EOF'
export COSMOS_ENDPOINT="${cosmos_endpoint}"
export COSMOS_KEY="${cosmos_key}"
EOF

sudo chmod 644 /etc/profile.d/cosmos.sh

# Load cosmos variables in current shell
source /etc/profile.d/cosmos.sh

echo "Running Cosmos SDK connection example..."
cd /home/app/terraform/cosmos-sdk/04-sdk-connect

dotnet restore
dotnet add package Microsoft.Azure.Cosmos --version 3.22.1
dotnet build
dotnet run

echo "Running Cosmos SDK transactional batch example..."
cd /home/app/terraform/cosmos-sdk/07-sdk-batch

dotnet restore
dotnet add package Microsoft.Azure.Cosmos --version 3.22.1
dotnet build
dotnet run

echo "Setup completed successfully."