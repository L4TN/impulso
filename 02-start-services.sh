#!/bin/bash

# ==============================================================================
# ImpulsoCore - Script de Orquestração de Containers
# Este script inicia os containers na ordem correta de dependência
# ==============================================================================

set -e
echo "🚀 Iniciando os serviços da ImpulsoCore..."

# O diretório base deve ser aquele onde a pasta "Sistemas Impulso" está clonada
BASE_DIR="$(pwd)/Sistemas Impulso/Dockers Scripts"

if [ ! -d "$BASE_DIR" ]; then
    echo "❌ Erro: Diretório base '$BASE_DIR' não encontrado."
    echo "Certifique-se de executar este script na raiz do repositório."
    exit 1
fi

echo "1️⃣  Subindo Portainer (Gerenciamento Docker)..."
cd "$BASE_DIR/IARA_Portainer"
docker compose up -d

echo "2️⃣  Subindo Infraestrutura Base (Postgres, Redis, RabbitMQ)..."
cd "$BASE_DIR/IARA_Infra"
docker compose up -d

# Aguardar o Postgres inicializar para não quebrar dependências
echo "⏳ Aguardando 15s para a inicialização do Banco de Dados..."
sleep 15

echo "3️⃣  Subindo Evolution API (Engine do WhatsApp)..."
cd "$BASE_DIR/IARA_Evolution"
docker compose up -d

echo "4️⃣  Subindo Proxy LiteLLM..."
cd "$BASE_DIR/IARA_LiteLLM"
docker compose up -d

echo "5️⃣  Subindo Chatwoot (Impulso Hub)..."
cd "$BASE_DIR/IARA_ChatWhoot"
# Se for a primeira vez rodando o Chatwoot, lembre-se que é necessário rodar as migrations.
# Descomente a linha abaixo na PRIMEIRA execução na VM nova:
# docker compose run --rm rails bundle exec rails db:chatwoot_prepare
docker compose up -d

echo "6️⃣  Subindo N8N Principal (Porta 5678)..."
cd "$BASE_DIR/IARA_N8N"
docker compose up -d

echo "7️⃣  Subindo N8N Siamesa (Porta 5679)..."
cd "$BASE_DIR/IARA_N8N_Siamesa"
docker compose up -d

echo "=============================================================================="
echo "🎉 Todos os serviços foram iniciados!"
echo "Use 'docker ps' para conferir os containers rodando."
echo "Acesse o Portainer em: http://SEU_IP:9000 para acompanhar os logs."
echo "=============================================================================="
