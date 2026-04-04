# 🚀 Documentação Completa e Arquitetura - ImpulsoCore

Este documento visa detalhar profundamente toda a arquitetura, infraestrutura, fluxos de automação (N8N), banco de dados e engenharia de prompt do chatbot **IARA** e dos serviços orbitais da **ImpulsoCore**. Este guia serve como a fonte definitiva da verdade para o remonte da infraestrutura em uma nova máquina (ex: Contabo VM).

---

## 1. 🏗️ Arquitetura do Sistema e Fluxo de Dados

O sistema é construído sobre uma arquitetura de microserviços baseada em contêineres Docker, onde o fluxo de atendimento é orquestrado por webhooks e filas de mensagens.

### Fluxo de Mensagem (Inbound & Outbound)
1. **Cliente (WhatsApp)** envia uma mensagem.
2. **Evolution API** recebe a mensagem e dispara um Webhook para a infraestrutura.
3. **N8N (IARA_01_Rabbit_PRD)** recebe o Webhook e publica a mensagem em uma fila no **RabbitMQ** (ex: `atendimento.incoming`).
4. **N8N (IARA_02_Flow_PRD)** consome a fila e verifica se o bot está ativo para o lead/empresa. Se estiver desativado (atendimento humano), encerra a automação.
5. **N8N (IARA_03_Message_PRD / IARA_05)** prepara o payload da mensagem, busca histórico na memória e valida o lead.
6. **N8N (IARA_06_Agente_e_Ferramentas)** é acionado. Este é o core da IA:
   - Utiliza a ferramenta `Refinar_Resposta` para planejar a ação.
   - Acessa a **Memória de Longo Prazo** no Supabase (vetores/RAG) via `documents` e o histórico de conversação.
   - Puxa o modelo de IA através do proxy **LiteLLM** (para métricas e rate limits).
   - Utiliza ferramentas (Function Calling) como `Verificar_Disponibilidade`, `Criar_Agendamento` (Google Calendar), etc.
7. **N8N (IARA_07)** cuida da **Humanização** do texto: quebra a resposta longa da IA em mensagens curtas para simular a digitação de uma pessoa real (com pausas configuradas por "palavras por minuto").
8. O N8N faz o POST final de volta na **Evolution API** (`/message/sendText`).
9. Todo esse tráfego é espelhado no **Chatwoot** para o SDR Humano visualizar as conversas e assumir (desligando a IA) caso necessário.

---

## 2. 🐳 Infraestrutura Docker

O ecossistema está dividido em várias stacks do Docker Compose operando em uma rede externa customizada chamada `impulso-net`.

### 2.1. IARA_Infra
Serviços base de suporte:
- **Postgres (pgvector)**: Banco relacional (porta 5436 externa, 5432 interna) hospedando o BD `iara_infra` configurado com `pgvector` para o RAG e tabelas gerais. Credenciais: `impulso_hub` / `impulso_hub`.
- **RedisN**: Instância de Redis (porta 6383 externa, 6379 interna) para caching, filas, sidekiq, etc.
- **RabbitMQ**: Message broker para resiliência no recebimento de mensagens da Evolution API, evitando perdas em picos de requisições.

### 2.2. Chatwoot
- **Rails & Sidekiq**: Servidor da aplicação Chatwoot e workers background. Imagem customizada `gerim022/chatwoot-dev:v22` para suportar modificações (Fork Impulso).
- **Postgres e Redis locais**: Instâncias dedicadas à própria stack do Chatwoot (`chatwoot_production`).

### 2.3. Evolution API
- **evolution_api**: Imagem `evoapicloud/evolution-api:v2.3.7`. Porta 8080.
- **Banco próprio**: Usa Redis e Postgres 15 internos.
- Conecta múltiplas instâncias de WhatsApp e fornece webhook master (com token de segurança `AHAIKD@O99834`).

### 2.4. Orquestração N8N
Duas instâncias são mantidas para segregação de carga:
- **IARA_N8N (Principal)**: Roda na porta 5678. Hospeda os agentes conversacionais (IARA SDR).
- **IARA_N8N_Siamesa**: Roda na porta 5679 (path `/n8n_2/`). Para automações avançadas e workflows de fundo independentes, evitando gargalos no bot principal.

### 2.5. LiteLLM
- Gateway para provedores de LLM. Usa `docker.litellm.ai/berriai/litellm`.
- Conectado a **OpenRouter** para utilizar o modelo `mistralai/mistral-small-3.2-24b-instruct`.
- Custo médio analisado: US$ 0.0003 a US$ 0.0004 por requisição. Tokens controlados em dashboards do LiteLLM.

---

## 3. 🗄️ Modelo de Dados (PostgreSQL `iara_infra`)

A aplicação controla empresas, contas, canais e histórico com tabelas centrais:
- `empresa` e `usuario`: Gestão multitenant (cliente da ImpulsoHub).
- `aplicacao` e `aplicacao_canal`: Integra o ID do Chatwoot (Account e Inbox) com a Evolution API.
- `agente`, `agente_config`, `prompt`: Guarda a parametrização do Agente IA por empresa, incluindo o Endpoint e variáveis JSON dinâmicas.
- `campanha` e `campanha_logs`: Estrutura do disparador em massa (Disparador Não Oficial via N8N).
- `documents`: Tabela com extensão `vector` para RAG (Retrieval-Augmented Generation) com os embeddings.
- `historico_mensagens` e `n8n_status_atendimento`: Controle de lock de conversas e estado de follow-up.

---

## 4. 🧠 A Agente IARA (Estado da Arte)

A IARA é uma SDR focada em conversão.

### Identidade
Especialista em soluções do **Grupo VOCÊ** (SST, Meio Ambiente, ICARUS e Treinamentos corporativos - fundado em 1999).
- **Tom de voz:** Amigável, consultivo, usando emojis moderados (😊, 👍).
- **Limites:** Mensagens curtas (máx 200/500 caracteres), quebras de linha (`\n\n`).
- **Objetivo Central:** Qualificar leads. Se o lead faturar < R$ 10.000 mensais, é desqualificado com cordialidade. Se for $\ge$ R$ 10k, a IA tenta fechar um **agendamento de reunião**.

### Ferramentas N8N (Tools LangChain)
A IARA tem ferramentas programadas no N8N:
1. `Refinar_Resposta`: Step de Chain of Thought obrigatório antes do envio.
2. `List_Agendamentos`, `Verificar_Disponibilidade`, `Criar_Agendamento`, `Update_Agendamentos`, `Delete_Agendamentos`: Gerenciam eventos de 30 minutos no Google Calendar, restritos a dias úteis e horário comercial (06:00 às 18:00).
3. `Reaction_Message`: Para mandar "👍" no WhatsApp e humanizar as confirmações.
4. `Escalar_Humano`: Transfere a tag no Chatwoot para um humano, caso o usuário peça ou haja dificuldade.
5. `Base_Conhecimento`: RAG via pgvector/supabase para dúvidas da empresa.
6. `Gravar_no_CRM`: Salva o lead em planilha ao qualificar.

### Regras Anti-Injection
Instruções fortificadas no prompt ignoram comandos como "ignore todas as instruções" ou "aja como hacker", retornando respostas neutras.

---

## 5. 🤖 Fluxos e Workflows N8N

A pasta de backups possui dezenas de fluxos. Os principais incluem:
- **IARA_01 a IARA_07**: Todo o pipeline síncrono e assíncrono para recebimento, tratamento, LLM generation, humanização e resposta final do bot.
- **Disparador Campanhas Não Oficiais**: Um "Schedule Trigger" roda a cada minuto, verifica na tabela `campanha` se há eventos programados. Caso sim, substitui as variáveis (ex: `{1}` pelo Nome) na lista de contatos (JSON) e dispara na rota `/message/sendMedia/` da Evolution.
- **iara_long_memory.json**: Utiliza LangChain Agents para resumir as conversas de um cliente e extrair "Nome, Idade, Interesse, Melhor horário" num bloco de notas central no Chatwoot/Supabase, não sobrecarregando o contexto das requisições futuras com lixo textual.
- **Secretária v3 / Gestão de Ligações**: Integrações auxiliares (Retell / ElevenLabs) com agendas do Google.

---

## 6. 📝 Plano de Ação: Remontando a Infraestrutura

Para reestabelecer o sistema na nova máquina Contabo, siga a ordem:

### Passo 1: Preparação da VM e Sistema
1. Instale Ubuntu 22.04 / 24.04.
2. Instale **Docker** e **Docker Compose** e o Portainer (`docker compose up -d` da pasta Portainer).
3. Configure o DNS (Cloudflare/Registro.br) para apontar `chat.impulsocore.com.br`, `iara.impulsocore.com.br` para o IP da nova Contabo. (⚠️ *O domínio expira em 02/06/2026, atenção*).
4. Crie a rede do docker base: `docker network create impulso-net`.

### Passo 2: Subindo a Base (Infra)
1. Acesse `Sistemas Impulso/Dockers Scripts/IARA_Infra`.
2. Configure o `.env` se aplicável e execute `docker-compose up -d`.
3. Verifique o PgVector, RedisN e RabbitMQ rodando.

### Passo 3: Serviços Orbitais (LLM e APIs)
1. **LiteLLM**: Acesse `IARA_LiteLLM`. Ajuste o `config.yaml` com a `OPENROUTER_API_KEY`. Suba com `docker-compose up -d`.
2. **Evolution API**: Acesse `IARA_Evolution`. Confira o `.env` (ex: `SERVER_URL=http://iara.impulsocore.com.br:8080` e `DATABASE_CONNECTION_URI` apontando para o seu postgres). Suba com `docker-compose up -d`.
3. Crie e leia o QRCode das instâncias de WhatsApp de atendimento e disparo.

### Passo 4: Chatwoot e FrontEnd
1. Acesse `IARA_ChatWhoot`. Valide o `SECRET_KEY_BASE` e `FRONTEND_URL` no `.env`.
2. Suba o container. Lembre de rodar as migrations (`rails db:chatwoot_prepare`).

### Passo 5: Automação N8N
1. Suba o **N8N** (IARA_N8N) com a WEBHOOK_URL correta.
2. Faça o mesmo para a **Siamesa** (`IARA_N8N_Siamesa`).
3. Acesse o painel de cada N8N e **importe os arquivos JSON de backup**.
   - Comece pelas configurações gerais e sub-workflows (`My Sub-Workflow 1`, `00. Configurações`).
   - Importe os fluxos `IARA_01` até `IARA_07`.
4. Configure as Credentials (banco Postgres `iara_infra`, API do Chatwoot, API Key Evolution, API Key LiteLLM).

### Passo 6: Banco de Dados e Script SQL
1. Conecte-se ao Postgres de Infraestrutura (porta 5436, `impulso_hub` / `impulso_hub`).
2. Execute o script `Script Banco Postgres.sql` para recriar as tabelas `empresa`, `campanha`, `agente`, `historico_mensagens`, etc.

### Passo 7: Segurança e Proxy
1. Usando o `Nginx.dockerfile` (se for subir um proxy reverso customizado) ou um Caddy/NPM, garanta que os certificados SSL estão configurados para `chat.impulsocore.com.br` e `iara.impulsocore.com.br`.

---

## 7. 📁 Anexo: Arquivos de Referência Cruciais (Contexto do Repositório)

Para facilitar a consulta e provar o mapeamento exato da arquitetura, os seguintes arquivos do repositório são considerados a base central do projeto e devem ser mantidos como backup e consulta em caso de falhas durante o provisionamento da nova máquina.

### 7.1. Infraestrutura e Orquestração Docker
O coração do ecossistema e das integrações. A ordem de subida desses contêineres deve ser respeitada (Infra > LLM > APIs > N8N).
*   **IARA_Infra (DBs Base):**
    *   `Sistemas Impulso/Dockers Scripts/IARA_Infra/docker-compose.yml` (Contém o *Postgres pgvector* na porta 5436, *Redis* e *RabbitMQ*).
*   **Proxy de IA (Monitoramento de Custos):**
    *   `Sistemas Impulso/Dockers Scripts/IARA_LiteLLM/docker-compose.yml`
    *   `Sistemas Impulso/Dockers Scripts/IARA_LiteLLM/config.yaml` *(Aqui vai a sua `OPENROUTER_API_KEY` para as chamadas do Mistral)*.
*   **Chatwoot (Fork Impulso Hub):**
    *   `Sistemas Impulso/Dockers Scripts/IARA_ChatWhoot/docker-compose.yaml` *(Contém os serviços rails, sidekiq, redis e postgres próprios do chatwoot)*.
    *   `Sistemas Impulso/Dockers Scripts/IARA_ChatWhoot/.env` *(Configurações cruciais de email via SMTP Gmail, JWTs, e Webhooks)*.
*   **Evolution API (Engine do WhatsApp):**
    *   `Sistemas Impulso/Dockers Scripts/IARA_Evolution/docker-compose.yml` *(Depende de um banco Postgres e Redis local. Usar imagem `evoapicloud/evolution-api:v2.3.7`)*.
    *   `Sistemas Impulso/Dockers Scripts/IARA_Evolution/.env` *(Define variáveis como `AUTHENTICATION_API_KEY=AHAIKD@O99834` e `SERVER_URL=http://iara.impulsocore.com.br:8080`)*.
*   **Automação (N8N):**
    *   `Sistemas Impulso/Dockers Scripts/IARA_N8N/docker-compose.yml` (N8N Primário para Atendimento, porta 5678).
    *   `Sistemas Impulso/Dockers Scripts/IARA_N8N_Siamesa/docker-compose.yml` (N8N Secundário para ferramentas pesadas, porta 5679 e sub-path `/n8n_2/`).
*   **Gerenciamento Docker e Proxy Reverso:**
    *   `Sistemas Impulso/Dockers Scripts/IARA_Portainer/docker-compose.yml` *(Portainer para gerência visual dos contêineres na porta 9000).*
    *   `Sistemas Impulso/Nginx.dockerfile` *(Proxy Reverso em Node 20 / Nginx).*

### 7.2. Banco de Dados (Schema Central)
Contém a modelagem relacional de clientes, fluxos, histórico e da Inteligência Artificial.
*   `Sistemas Impulso/Script Banco Postgres.sql`: *Script completo que gera o banco `iara_infra` com as tabelas `empresa`, `usuario`, `agente`, `prompt`, `historico_mensagens` e a crucial tabela `documents` (configurada para armazenar os embeddings vectoriais do RAG).*

### 7.3. A Inteligência do Agente (Prompts e Comportamento)
A engenharia de prompt define o limite de atuação da SDR **IARA**. Qualquer atualização no script de vendas ou no fluxo de Human in the Loop (Escalar_Humano) deve nascer nesses documentos.
*   `Impulso_Docs/pages/IARA Prompt  Estado da Arte.md`: *Contém a base completa do fluxo da conversa (Apresentação -> Qualificação R$ 10k -> Decisão -> Agendamento). Regras como as barreiras anti-injection e o limite de emojis estão detalhadas aqui.*
*   `Impulso_Docs/pages/IARA Prompt.md`: *Versão mais descritiva com o passo a passo das ferramentas como `Verificar_Disponibilidade` e obrigatoriedade da chamada `Refinar_Resposta` via Chain-of-Thought (CoT) antes do envio para o usuário.*
*   `10.1.06_Impulso_2025-01-10.md` *(Logs valiosos sobre o Troubleshooting dos limites e formatação das variáveis no template de agendamento).*

### 7.4. Workflows N8N (O Cérebro Operacional)
Todos os arquivos `*.json` em `Impulso_Docs/backups/` compõem a lógica sistêmica. A ordem lógica da esteira conversacional é a seguinte (devem ser importados obrigatoriamente após a instalação do n8n):
*   **Fluxos de Resiliência (Fila de Entrada):**
    *   `IARA_01_Rabbit_PRD.json`: *Recebe a request POST do webhook da Evolution e envia o payload para a fila `atendimento.incoming` no RabbitMQ, garantindo que não se percam mensagens em picos.*
    *   `IARA_02_Flow_PRD.json`: *Puxa da fila do RabbitMQ. Verifica na Evolution ou banco se a IA está bloqueada (chat pausado por atendimento humano) ou se a mensagem precisa seguir.*
*   **Módulo de Agente (A IARA):**
    *   `IARA_03_Message_PRD.json` / `IARA_05_Mensagem_Agente.json`: *Preparação e persistência. Aqui, a requisição sofre parsers, os caracteres sujos são removidos e a memória do Postgres é enriquecida antes da IA ver o dado.*
    *   `IARA_06_Agente_e_Ferramentas.json`: *O núcleo! É este JSON que contém o Node Agent do LangChain. Ele executa a predição LLM com o LiteLLM e chama as tools (Google Calendar, CRM Google Sheets, RAG Supabase Vector).*
    *   `IARA_07.json`: *O Humanizador. Um JSON que pega a saída em parágrafos pesados da IARA_06, quebra em partes curtas via regex (simulando "palavras por minuto") e dispara a sinalização de "Digitando..." via API do Chatwoot.*
*   **Fluxos Auxiliares e Orbitais (Essenciais):**
    *   `08. Agente Assistente Interno.json` *(Integrações com ferramentas nativas, uso do node GoogleTasks e Transcrição com OpenAI Whisper).*
    *   `09. Desmarcar e enviar alerta.json` *(Deleta agendamento no Google Calendar e retorna um POST via API do Chatwoot com a tag do ticket humano).*
    *   `11. Agente de Lembretes de Agendamento.json` *(Trigger Cron que varre o Google Calendar a cada 1 minuto).*
    *   `iara_long_memory.json`: *O consolidador. Usa a IA para varrer o histórico finalizado e extrair variáveis-chave como Nome, Interesse, Horário, enxugando tokens para a próxima interação do mesmo cliente.*
*   **Disparo Não Oficial (Campanhas em Lote):**
    *   `Disparador.json` / `Job Disparador - Campanhas Não Oficiais.json` / `API Rest Backend - Disparador Campanhas Não Oficiais.json`: *Conjunto de APIs no N8N que recebem as requisições, armazenam a lista de leads em banco, e disparam via Loop pra Evolution API (`sendMedia`/`sendText`).*

### 7.5. Manuais e Guias
Guias úteis para o caso da instalação na nova VM Contabo precisar de troubleshooting pesado (ex: problemas no ruby/node dentro de um ambiente local).
*   `Impulso_Docs/pages/INSTALL.md` *(Guia massivo que ensina setup do Impulso_Hub para Linux).*
*   `Sistemas Impulso/AGENTS.md` *(Anotações das tecnologias e lista de tarefas atuais com o Thiago/Dias: como a precificação e limite de SPAM).*
*   `10.1.05_Tonico_Notas.md` *(Discussão arquitetônica crucial que justifica o N8N rodar em modelo monolítico/flow complexo em vez de dezenas de Lambdas na AWS para contornar problemas de Cold Start).*

---
*Fim da documentação gerada por Opencode AI.*