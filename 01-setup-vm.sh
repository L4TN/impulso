#!/bin/bash

# ==============================================================================
# ImpulsoCore - Script de Instalação e Preparação da VM (Contabo)
# Este script prepara o Ubuntu 22.04/24.04 para rodar toda a infraestrutura
# ==============================================================================

set -e # Sai imediatamente se um comando falhar
echo "🚀 Iniciando preparação da VM para a Infraestrutura ImpulsoCore..."

# 1. Atualizar o sistema
echo "📦 Atualizando pacotes do SO..."
sudo apt-get update && sudo apt-get upgrade -y

# 2. Instalar dependências essenciais
echo "🛠️ Instalando ferramentas básicas..."
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common \
  git \
  build-essential \
  htop \
  ufw \
  jq \
  dos2unix \
  nano \
  wget

# 3. Instalar Docker e Docker Compose
if ! command -v docker &> /dev/null
then
    echo "🐳 Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
else
    echo "✅ Docker já está instalado."
fi

# Instalar Docker Compose (se o plugin não estiver presente)
if ! docker compose version &> /dev/null
then
    echo "🐳 Instalando Docker Compose..."
    sudo apt-get install docker-compose-plugin -y
else
    echo "✅ Docker Compose já está instalado."
fi

# 4. Habilitar Docker no boot e iniciar serviço
sudo systemctl enable docker
sudo systemctl start docker

# 5. Criar rede Docker customizada (impulso-net)
echo "🌐 Criando rede Docker interna 'impulso-net'..."
if ! docker network ls | grep -q "impulso-net"; then
    docker network create impulso-net
    echo "✅ Rede 'impulso-net' criada com sucesso."
else
    echo "✅ Rede 'impulso-net' já existe."
fi

# 6. Configurar Firewall (UFW) Básico
echo "🛡️ Configurando Firewall (UFW)..."
sudo ufw allow OpenSSH
# Portas HTTP e HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
# Porta Portainer
sudo ufw allow 9000/tcp
# Porta N8N Principal
sudo ufw allow 5678/tcp
# Porta N8N Siamesa
sudo ufw allow 5679/tcp
# Porta Evolution API
sudo ufw allow 8080/tcp
# Porta LiteLLM
sudo ufw allow 4000/tcp
# Nota: PostgreSQL (5436) e Redis não devem ser abertos ao público por segurança,
# a não ser que estritamente necessário para acesso externo. Se precisar, descomente abaixo:
# sudo ufw allow 5436/tcp 

echo "y" | sudo ufw enable
echo "✅ Firewall configurado."

# 7. Otimizações de SO para banco de dados e containers
echo "⚙️ Aplicando otimizações de sistema (sysctl)..."
sudo bash -c 'cat >> /etc/sysctl.conf <<EOF
# Otimizações ImpulsoCore
vm.overcommit_memory = 1
net.core.somaxconn = 1024
EOF'
sudo sysctl -p

echo "=============================================================================="
echo "🎉 Preparação da VM concluída com sucesso!"
echo "⚠️  ATENÇÃO: Você precisa sair (logout) e entrar (login) novamente para"
echo "    que as permissões do grupo Docker tenham efeito."
echo "=============================================================================="
echo "Próximo passo recomendado: Executar o script '02-start-services.sh'"
