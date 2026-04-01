# ImpulsoCore - TO-DO: Remontagem da Infraestrutura na Contabo

3x nginx - um por chat da impulso core e outro para o site 

e ngix serve para n8n(com certificado)

iara.n8n

CloudFlare WAF nginx


E alguns docker vao se conversar via Link do nginx de dominio(isso é evidenciado vendo os docker.ymls)

iara.impulsocore.com (N8N)
chat.impulsocore.com (ImpulsoHub Chatwoot)
impulsocore.com (Site)

map $http_upgrade $connection_upgrade { default upgrade; '' close; }
limit_req_zone $binary_remote_addr zone=req_zone:10m rate=10r/s;

server {
  server_name chat.impulsocore.com.br;
  server_tokens off;
  underscores_in_headers on;

  location /cable {
    proxy_pass_header Authorization;
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_http_version 1.1;
    proxy_read_timeout 36000s;
    proxy_buffering off;
  }

  location / {
    proxy_set_header Authorization $http_authorization;
    proxy_pass_request_headers on; 
    proxy_pass_header Authorization;
    limit_req zone=req_zone burst=20 nodelay;
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_http_version 1.1;
    proxy_buffering off;
    client_max_body_size 0;
    proxy_read_timeout 36000s;
  }

  location /.well-known { root /var/www/ssl-proof/chatwoot; }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/chat.impulsocore.com.br/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/chat.impulsocore.com.br/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}


server {
    if ($host = chat.impulsocore.com.br) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  server_name chat.impulsocore.com.br;
  listen 80;
    return 404; # managed by Certbot


}



server {
  server_name impulsocore.com.br www.impulsocore.com.br;
  server_tokens off;
  root /var/www/landing;
  index index.html;
  location / { try_files $uri $uri/ =404; }
  location /.well-known { root /var/www/ssl-proof/chatwoot; }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/impulsocore.com.br/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/impulsocore.com.br/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = www.impulsocore.com.br) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


  server_name impulsocore.com.br www.impulsocore.com.br;
  listen 80;
    return 404; # managed by Certbot


}


Cloudflare(precisa trocar o ip aqui na cloud flare, usando os ips da mquina nova da Contabo)
| Type | Name              | Content        | Proxy status | TTL  | Actions |
|------|-------------------|----------------|--------------|------|---------|
| A    | chat              | 38.242.214.250 | DNS only     | Auto | Edit    |
| A    | chatold           | 52.72.215.146  | DNS only     | Auto | Edit    |
| A    | iara              | 38.242.214.250 | DNS only     | Auto | Edit    |
| A    | impulsocore.com.br| 38.242.214.250 | DNS only     | Auto | Edit    |
| A    | www               | 38.242.214.250 | DNS only     | Auto | Edit    |

https://dash.cloudflare.com/d2fa7dd43ecb07282cf8a1e0f060b4b7/impulsocore.com.br/dns/records

Login:
coreimpulso@gmail.com
2025_Mat_Senior



## Visão Geral do Projeto
**IARA** é um chatbot SDR (Sales Development Representative) para WhatsApp do Grupo VOCÊ, usando:
- Evolution API para integração WhatsApp Business
- N8N para orquestração de workflows/LangChain agents
- Chatwoot como CRM/visor de conversas
- PostgreSQL + pgvector para RAG
- LiteLLM como proxy para OpenRouter (Mistral)
- RabbitMQ + Redis para filas e caching

---

## TO-DOs

### FASE 1: Preparação da VM Contabo

- [ ] **1.1** Comprar VM na Contabo (Ubuntu 22.04/24.04)
- [ ] **1.2** Configurar DNS no Registro.br: `chat.impulsocore.com.br` e `iara.impulsocore.com.br` → IP da VM
- [ ] **1.3** Executar `01-setup-vm.sh` na VM (Docker, Docker Compose, UFW, rede `impulso-net`)
- [ ] **1.4** Verificar se domínio expira em 02/06/2026 - **RENOVAR**

### FASE 2: Infraestrutura Base (Databases)

- [ ] **2.1** Subir IARA_Infra (docker-compose):
  - Postgres pgvector (porta 5436) - banco `iara_infra`
  - RedisN (porta 6383)
  - RabbitMQ (portas 5672, 15672)
- [ ] **2.2** Executar `Script Banco Postgres.sql` no Postgres pgvector (porta 5436)
  - Credenciais: `impulso_hub` / `impulso_hub`
  - Criar tabelas: empresa, usuario, agente, documents, leads, mensagens, historico_mensagens, etc.

### FASE 3: Serviços Orbitais (APIs)

- [ ] **3.1** Subir IARA_LiteLLM (porta 4000)
  - Configurar `OPENROUTER_API_KEY` em `config.yaml`
  - Modelo: `mistralai/mistral-small-3.2-24b-instruct`
  - Dashboard de custos em `/ollama`

- [ ] **3.2** Subir IARA_Evolution (porta 8080)
  - Configurar `.env`: `SERVER_URL=http://iara.impulsocore.com.br:8080`
  - API Key autenticação: `AHAIKD@O99834`
  - Conectar WhatsApp (criar instâncias e escanear QR code)

### FASE 4: Chatwoot

- [ ] **4.1** Subir IARA_ChatWhoot (porta 3000 internally)
  - Verificar `SECRET_KEY_BASE` no `.env`
  - Verificar `FRONTEND_URL=https://chat.impulsocore.com.br`
  - Na primeira execução: rodar migrations `rails db:chatwoot_prepare`
  - Configurar SMTP Gmail em `.env`
  - Criar conta admin inicial

- [ ] **4.2** Configurar Chatwoot:
  - Criar Inbox para WhatsApp
  - Criar times/departamentos para escalação humana
  - Integrar com Evolution API (webhook)

### FASE 5: Automação N8N

- [ ] **5.1** Subir IARA_N8N Principal (porta 5678)
  - `WEBHOOK_URL: https://iara.impulsocore.com.br/n8n/`
  - Importar workflows em ordem:
    1. `00. Configurações.json`
    2. `My Sub-Workflow 1.json`
    3. `IARA_01_Rabbit_PRD.json`
    4. `IARA_02_Flow_PRD.json`
    5. `IARA_03_Message_PRD.json`
    6. `IARA_05_Mensagem_Agente.json`
    7. `IARA_06_Agente_e_Ferramentas.json`
    8. `IARA_07.json`
  - Configurar Credentials (Postgres, Chatwoot API, Evolution API, LiteLLM)

- [ ] **5.2** Subir IARA_N8N_Siamesa (porta 5679)
  - `WEBHOOK_URL: https://iara.impulsocore.com.br/n8n_2/`
  - Importar workflows auxiliares:
    - `09. Desmarcar e enviar alerta.json`
    - `11. Agente de Lembretes de Agendamento.json`
    - `iara_long_memory.json`
    - Disparadores de campanha

### FASE 6: Configurações Finais e Integração

- [ ] **6.1** Configurar Proxy Reverso (Nginx/Caddy)
  - SSL para `chat.impulsocore.com.br` e `iara.impulsocore.com.br`
  - Redirecionar portas 443 → serviços internos

- [ ] **6.2** Integrar Evolution API → N8N → Chatwoot
  - Webhook da Evolution: `/webhook/chatwoot` → N8N
  - N8N envia para Evolution `/message/sendText`

- [ ] **6.3** Testar fluxo completo:
  - Enviar mensagem WhatsApp → Evolution → N8N → IARA → resposta

### FASE 7: WhatsApp Business

- [ ] **7.1** Configurar Conta WhatsApp Business na Meta
- [ ] **7.2** Conectar número à Evolution API
- [ ] **7.3** Configurar webhook na Meta Developers

---

## Referências

### Scripts
- `01-setup-vm.sh` - Setup inicial da VM
- `02-start-services.sh` - Orquestração de containers

### Docker Compose
- `Sistemas Impulso/Dockers Scripts/IARA_Infra/docker-compose.yml`
- `Sistemas Impulso/Dockers Scripts/IARA_LiteLLM/docker-compose.yml`
- `Sistemas Impulso/Dockers Scripts/IARA_Evolution/docker-compose.yml`
- `Sistemas Impulso/Dockers Scripts/IARA_ChatWhoot/docker-compose.yaml`
- `Sistemas Impulso/Dockers Scripts/IARA_N8N/docker-compose.yml`
- `Sistemas Impulso/Dockers Scripts/IARA_N8N_Siamesa/docker-compose.yml`
- `Sistemas Impulso/Dockers Scripts/IARA_Portainer/docker-compose.yml`

### Backups N8N
- `Impulso_Docs/backups/IARA_01_Rabbit_PRD.json` - RabbitMQ ingestion
- `Impulso_Docs/backups/IARA_02_Flow_PRD.json` - Fluxo principal
- `Impulso_Docs/backups/IARA_06_Agente_e_Ferramentas.json` - Core IA (LangChain)
- `Impulso_Docs/backups/IARA_07.json` - Humanizador

### Documentação
- `Impulso_Arquitetura_e_Documentacao_Completa.md`
- `Impulso_Docs/pages/IARA Prompt.md` - Prompt da IARA

---

## Credenciais (a configurar na nova VM)

| Serviço | Credencial |
|---------|------------|
| Postgres IARA_Infra | `impulso_hub` / `impulso_hub` (porta 5436) |
| RabbitMQ | `impulso_hub` / `impulso_hub` (porta 5672) |
| Redis IARA_Infra | `123456` (porta 6383) |
| LiteLLM | Master Key: `sk-1234` |
| OpenRouter | API Key já configurada no config.yaml |
| Evolution API | API Key: `AHAIKD@O99834` |
| Chatwoot Redis | `2025_Mat_Senior` |
| Chatwoot Postgres | `chatwoot_postgres` / `2025_Mat_Senior` |
| Chatwoot SMTP | `coreimpulso@gmail.com` / `kkvkwwdyzhqalxhw` |
