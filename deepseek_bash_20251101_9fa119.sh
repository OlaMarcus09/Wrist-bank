cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Wrist Bank Development",
  "image": "mcr.microsoft.com/devcontainers/typescript-node:18",
  "features": {
    "ghcr.io/devcontainers/features/rust:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "move.move-analyzer"
      ]
    }
  },
  "postCreateCommand": "curl -fsSL https://github.com/MystenLabs/sui/releases/download/mainnet-v1.35.0/sui-mainnet-v1.35.0-ubuntu-x86_64.tgz | tar -xzf - && sudo mv sui-mainnet-v1.35.0-ubuntu-x86_64/bin/sui /usr/local/bin/ && npm install",
  "forwardPorts": [3000]
}
EOF