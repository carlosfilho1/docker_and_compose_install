#!/bin/bash

# Script para instalar Docker e Docker Compose v2
set -e

COMPOSE_VERSION="v2.36.1"
INSTALL_DIR="$HOME/.docker/cli-plugins"
PLUGIN_PATH="$INSTALL_DIR/docker-compose"

echo "🚀 Iniciando instalação do Docker e Docker Compose v2..."

# ─────────────────────────────────────────────────────────────
# Instalar Docker se não estiver presente
# ─────────────────────────────────────────────────────────────
if ! command -v docker &> /dev/null; then
    echo "📦 Docker não encontrado. Instalando Docker Engine (última versão estável)..."

    # Remove versões antigas
    sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

    # Atualiza pacotes e instala dependências
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Adiciona chave GPG oficial do Docker
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Adiciona repositório oficial Docker
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker compose-plugin

    echo "✅ Docker instalado com sucesso."
else
    echo "✅ Docker já está instalado."
fi

# ─────────────────────────────────────────────────────────────
# Remover docker-compose (v1), se existir
# ─────────────────────────────────────────────────────────────
if command -v docker-compose &> /dev/null; then
    echo "🧹 Removendo docker compose (v1) obsoleto..."

    DC_PATH=$(command -v docker compose)
    sudo rm -f "$DC_PATH"

    echo "✅ docker compose (v1) removido: $DC_PATH"
else
    echo "✅ docker compose (v1) não está instalado. Nenhuma ação necessária."
fi


# ─────────────────────────────────────────────────────────────
# Instalar Docker Compose v2 (plugin CLI)
# ─────────────────────────────────────────────────────────────
echo "⬇️ Baixando Docker Compose $COMPOSE_VERSION..."

mkdir -p "$INSTALL_DIR"
curl -SL "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-linux-x86_64" -o "$PLUGIN_PATH"
chmod +x "$PLUGIN_PATH"

echo "✅ Docker Compose v2 instalado com sucesso!"

echo "🛠️ Configurando permissões do Docker..."
sudo groupadd docker || true
sudo usermod -aG docker "$USER" || true
sudo chown "$USER":"$USER" "$INSTALL_DIR" || true
sudo chmod 755 "$INSTALL_DIR" || true
sudo chown "$USER":"$USER" "$PLUGIN_PATH" || true
sudo chmod 755 "$PLUGIN_PATH" || true
echo "✅ Permissões do Docker configuradas com sucesso!"

echo
echo "📦 Versões instaladas:"
docker --version
docker compose version