*Tecnologias da Impulso:*
- *PostgresSQL* (do nosso lado, que quer repassar as regras, entidades e dados para o do chatwoot)
- *API WhatsApp Business* (configura o telefone da empresa/cliente nosso para receber as mensagens e encaminhar para o bot/IA);
- *Evolution* (responsável por fazer um plug-in play da API do WhatsApp Business com o N8N, tudo que passa de mensagens entre WhatsApp Business e o N8N, é sincronizado para o chatwoot);
- *N8N* (workflow responsável por receber(de um cliente do nosso cliente) e enviar as mensagens de respostas (nossa IA/bot);
- *chatwoot* (centralizador de mensagens mais amigável que o Evolution, onde é possível gerenciar as mensagens, tirar IA do chat, encerrar o chat, enviar msg pelo chat, redirecionar fila de atendimento, fluxo automático de atendimento por bot sem IA);
- *VM - Contaboo* (cloud, onde fica essas aplicações - cada uma em um container separado)
- *Domínio - Site*: https://www.impulsocore.com.br/
- *Domínio - chatwoot*: https://chat.impulsocore.com.br/
- *LiteLLM* (provedor de LLM com dashboard de custo),
- *Conta WhatsApp Meta Business* e *Meta Developers*: precisa criar.


*Tarefas que precisam ser repassadas - Thiago:*
- Site, onde está hospedado;
- Contas do WhatsApp Business;


*Tarefas a fazer:*
- Criar conta Business no Facebook;
- Criar conta no Instagram;
- Tráfego pago;
- Ver questão para abrir empresa/CNPJ para gerar NF;
- Rever a modelagem MER da aplicação referente ao PostgresSQL Interno X chatwoot;
- Desenhar diagrama de sequencia referente ao processo de envio e recebimento de mensagens na aplicação;
- Definir propostas, contratos e pacotes.


*Ajuste de disparador:*
- Anexos só funcionam quando tem extensão;
- Utilizar blob de armazenamento;
- Número banido ser identificado e sinalizado no Front-End;
- Remover datas de vigência do disparo;
- Ocultar AcountID da UI;
- Incluir botão de disparo imediato;
- Alterar o default de inserção de dados para .csv;
- Caracteres especiais não estão sendo enviados nas mensagens de disparo: Exemplo "Letícia";
- Aumentar o tamanho do campo de caixa de mensagem;


*Pontos a serem analisados e estudados*:
- Para disparos oficiais, o chatwoot já tem essa funcionalidade, precisa ser analisado;
- Verificar na doc e conhecimento geral de como reduzir custos de templates/mensagens no Whatsapp: Meta não é clara na documentação e diverge em muitos pontos, deve haver uma melhor forma para economizar tokens, uma das minhas ideias é o seguinte:
- -->Utilizar sempre  Whatsapp Cloud APIoficial  para Campanhas de Disparo
- -->Utilizar sempre Whatsapp Não Oficial para Bots de LLM Agentes de AI





pelo menos ainda temos o dominio
Aqui estão todas as informações extraídas da imagem: [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/15379889/e6ff5884-508f-4537-9dbe-c714d198a43d/image.jpg?AWSAccessKeyId=ASIA2F3EMEYEYPPFKCCI&Signature=TGrsRJ0NkmSV1J2PL542Y%2FpTX%2B4%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJGMEQCIAVjyPEW5ovGighqanGMAlPkQctdV3b6oYk8Pc07pnv1AiARCdC6tv76PkWE5UPe0WLixDbKJzcY5ZFDeV9B5Mp2syrzBAgrEAEaDDY5OTc1MzMwOTcwNSIMB2jnSb%2FzReYF6mcxKtAE2fBNMvMjpE6ThjTWsjY9TOw0s%2F5vdbh7tMrhJXCQVSQYD2oDEL7DhMMpUb%2BYNWT%2B%2BmA5vl3dLnxYre%2Fv%2FgyPQGkdUAaqwaoJQ%2B%2FICL7Di8BH%2B0C77T4ZHVPu9gcPXhV9U0%2BjMD%2F14zbImTCsaNCArcnzJiSHZIEwFEl6ky1kVMOCu3VkZrcA24MTn9brtrnbNH8%2BtE%2BL4f408JvglEBjx7KW6Hw5vV2%2BHGGzBtX2piIkimALS%2FxGUP0wLfbVvkSjf1pc%2Bc4bbB52Ain9OcnUCgL05p7n5y4CL5WqADa3wd4g5pbfB1RqwaKrGisn4Lk1Z8uvdRiMCIYEey%2BrX1sXGLF9Att2hFVJTRpU6%2B2wCaDhV2V3V%2B9c1cMQ470NR9f0tUlNL2eBKF%2BkAbaR2%2Fz2xwdYR%2BoRq9%2BRGEslNmlg7Op9F0pouy69Ztf3%2FjdajwcPW6CGbZkvz4YoJmwHrvMhFEYX6nIjaN9POzo9FtBc1zgBZhckToYWpd%2FqLFSCPuHdNMyhFa%2Bk1MnZhVuBqDVVaU8ebY7oCFNO4CN%2Bn6jq4dhYVktBFtlbXTdIonDiX5hE5xJGewTK5AkspexAyQmbpv%2BLk8t0%2F%2BGnss5w0t28%2B5Y4SY8XF%2F4uaTU4FDH1MP9PLYnkWKrfs5cntvbW4clXp6qP8fJacfF1PG%2FXxvphUBYpruqsABQInUrLxcH79eGoGkfqN7LkyK2Gxo%2B0%2FvKL7OKsESoUjBMEHS5JSAsce%2F6%2BPTnslxssUo28rRLbIKNnpaeGaXZ5yMw2FsyDsDispzD04qrOBjqZAcoE2ZJLO3OFtdE4Ogcimw4W65cNYE4Bs6DGj4%2BRo997NrIR7xI5yydudA0tv6Y7KHGVoeTQ8VgDEzWU979HKetm0WtTbWz3leRcjY6XZgSYhlKYm%2FBu3SJ2C7cMeh4J%2FNsH%2FW6zWCtVPyFgxr4j40MOdB%2BPD4ZDhoBCTlRlvvMaSWMylq2212wHYAzzy%2FEEjHQUHF%2Fv8ws8pA%3D%3D&Expires=1774893838)

## Painel Registro.br

### Dados do Usuário
| Campo | Valor |
|---|---|
| **Nome** | MATHEUS DIAS |
| **Código de usuário** | MASDI351 |
| **Data/Hora do acesso** | 26/03/2026 às 23:36:59 |

### Domínio Registrado
| Campo | Valor |
|---|---|
| **Domínio** | IMPULSOCORE.COM.BR |
| **Status** | ✅ Publicado |
| **Expiração** | 02/06/2026 |

### Observações

- O domínio está ativo e **publicado**, ou seja, está resolvendo normalmente na internet. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/15379889/e6ff5884-508f-4537-9dbe-c714d198a43d/image.jpg?AWSAccessKeyId=ASIA2F3EMEYEYPPFKCCI&Signature=TGrsRJ0NkmSV1J2PL542Y%2FpTX%2B4%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJGMEQCIAVjyPEW5ovGighqanGMAlPkQctdV3b6oYk8Pc07pnv1AiARCdC6tv76PkWE5UPe0WLixDbKJzcY5ZFDeV9B5Mp2syrzBAgrEAEaDDY5OTc1MzMwOTcwNSIMB2jnSb%2FzReYF6mcxKtAE2fBNMvMjpE6ThjTWsjY9TOw0s%2F5vdbh7tMrhJXCQVSQYD2oDEL7DhMMpUb%2BYNWT%2B%2BmA5vl3dLnxYre%2Fv%2FgyPQGkdUAaqwaoJQ%2B%2FICL7Di8BH%2B0C77T4ZHVPu9gcPXhV9U0%2BjMD%2F14zbImTCsaNCArcnzJiSHZIEwFEl6ky1kVMOCu3VkZrcA24MTn9brtrnbNH8%2BtE%2BL4f408JvglEBjx7KW6Hw5vV2%2BHGGzBtX2piIkimALS%2FxGUP0wLfbVvkSjf1pc%2Bc4bbB52Ain9OcnUCgL05p7n5y4CL5WqADa3wd4g5pbfB1RqwaKrGisn4Lk1Z8uvdRiMCIYEey%2BrX1sXGLF9Att2hFVJTRpU6%2B2wCaDhV2V3V%2B9c1cMQ470NR9f0tUlNL2eBKF%2BkAbaR2%2Fz2xwdYR%2BoRq9%2BRGEslNmlg7Op9F0pouy69Ztf3%2FjdajwcPW6CGbZkvz4YoJmwHrvMhFEYX6nIjaN9POzo9FtBc1zgBZhckToYWpd%2FqLFSCPuHdNMyhFa%2Bk1MnZhVuBqDVVaU8ebY7oCFNO4CN%2Bn6jq4dhYVktBFtlbXTdIonDiX5hE5xJGewTK5AkspexAyQmbpv%2BLk8t0%2F%2BGnss5w0t28%2B5Y4SY8XF%2F4uaTU4FDH1MP9PLYnkWKrfs5cntvbW4clXp6qP8fJacfF1PG%2FXxvphUBYpruqsABQInUrLxcH79eGoGkfqN7LkyK2Gxo%2B0%2FvKL7OKsESoUjBMEHS5JSAsce%2F6%2BPTnslxssUo28rRLbIKNnpaeGaXZ5yMw2FsyDsDispzD04qrOBjqZAcoE2ZJLO3OFtdE4Ogcimw4W65cNYE4Bs6DGj4%2BRo997NrIR7xI5yydudA0tv6Y7KHGVoeTQ8VgDEzWU979HKetm0WtTbWz3leRcjY6XZgSYhlKYm%2FBu3SJ2C7cMeh4J%2FNsH%2FW6zWCtVPyFgxr4j40MOdB%2BPD4ZDhoBCTlRlvvMaSWMylq2212wHYAzzy%2FEEjHQUHF%2Fv8ws8pA%3D%3D&Expires=1774893838)
- A expiração é em **02 de junho de 2026**, o que significa que você tem aproximadamente **2 meses** para renovar antes de expirar. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/15379889/e6ff5884-508f-4537-9dbe-c714d198a43d/image.jpg?AWSAccessKeyId=ASIA2F3EMEYEYPPFKCCI&Signature=TGrsRJ0NkmSV1J2PL542Y%2FpTX%2B4%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJGMEQCIAVjyPEW5ovGighqanGMAlPkQctdV3b6oYk8Pc07pnv1AiARCdC6tv76PkWE5UPe0WLixDbKJzcY5ZFDeV9B5Mp2syrzBAgrEAEaDDY5OTc1MzMwOTcwNSIMB2jnSb%2FzReYF6mcxKtAE2fBNMvMjpE6ThjTWsjY9TOw0s%2F5vdbh7tMrhJXCQVSQYD2oDEL7DhMMpUb%2BYNWT%2B%2BmA5vl3dLnxYre%2Fv%2FgyPQGkdUAaqwaoJQ%2B%2FICL7Di8BH%2B0C77T4ZHVPu9gcPXhV9U0%2BjMD%2F14zbImTCsaNCArcnzJiSHZIEwFEl6ky1kVMOCu3VkZrcA24MTn9brtrnbNH8%2BtE%2BL4f408JvglEBjx7KW6Hw5vV2%2BHGGzBtX2piIkimALS%2FxGUP0wLfbVvkSjf1pc%2Bc4bbB52Ain9OcnUCgL05p7n5y4CL5WqADa3wd4g5pbfB1RqwaKrGisn4Lk1Z8uvdRiMCIYEey%2BrX1sXGLF9Att2hFVJTRpU6%2B2wCaDhV2V3V%2B9c1cMQ470NR9f0tUlNL2eBKF%2BkAbaR2%2Fz2xwdYR%2BoRq9%2BRGEslNmlg7Op9F0pouy69Ztf3%2FjdajwcPW6CGbZkvz4YoJmwHrvMhFEYX6nIjaN9POzo9FtBc1zgBZhckToYWpd%2FqLFSCPuHdNMyhFa%2Bk1MnZhVuBqDVVaU8ebY7oCFNO4CN%2Bn6jq4dhYVktBFtlbXTdIonDiX5hE5xJGewTK5AkspexAyQmbpv%2BLk8t0%2F%2BGnss5w0t28%2B5Y4SY8XF%2F4uaTU4FDH1MP9PLYnkWKrfs5cntvbW4clXp6qP8fJacfF1PG%2FXxvphUBYpruqsABQInUrLxcH79eGoGkfqN7LkyK2Gxo%2B0%2FvKL7OKsESoUjBMEHS5JSAsce%2F6%2BPTnslxssUo28rRLbIKNnpaeGaXZ5yMw2FsyDsDispzD04qrOBjqZAcoE2ZJLO3OFtdE4Ogcimw4W65cNYE4Bs6DGj4%2BRo997NrIR7xI5yydudA0tv6Y7KHGVoeTQ8VgDEzWU979HKetm0WtTbWz3leRcjY6XZgSYhlKYm%2FBu3SJ2C7cMeh4J%2FNsH%2FW6zWCtVPyFgxr4j40MOdB%2BPD4ZDhoBCTlRlvvMaSWMylq2212wHYAzzy%2FEEjHQUHF%2Fv8ws8pA%3D%3D&Expires=1774893838)
- O painel é do **Registro.br**, gerenciado pelo NIC.br, órgão responsável pelo registro de domínios `.br` no Brasil. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/15379889/e6ff5884-508f-4537-9dbe-c714d198a43d/image.jpg?AWSAccessKeyId=ASIA2F3EMEYEYPPFKCCI&Signature=TGrsRJ0NkmSV1J2PL542Y%2FpTX%2B4%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJGMEQCIAVjyPEW5ovGighqanGMAlPkQctdV3b6oYk8Pc07pnv1AiARCdC6tv76PkWE5UPe0WLixDbKJzcY5ZFDeV9B5Mp2syrzBAgrEAEaDDY5OTc1MzMwOTcwNSIMB2jnSb%2FzReYF6mcxKtAE2fBNMvMjpE6ThjTWsjY9TOw0s%2F5vdbh7tMrhJXCQVSQYD2oDEL7DhMMpUb%2BYNWT%2B%2BmA5vl3dLnxYre%2Fv%2FgyPQGkdUAaqwaoJQ%2B%2FICL7Di8BH%2B0C77T4ZHVPu9gcPXhV9U0%2BjMD%2F14zbImTCsaNCArcnzJiSHZIEwFEl6ky1kVMOCu3VkZrcA24MTn9brtrnbNH8%2BtE%2BL4f408JvglEBjx7KW6Hw5vV2%2BHGGzBtX2piIkimALS%2FxGUP0wLfbVvkSjf1pc%2Bc4bbB52Ain9OcnUCgL05p7n5y4CL5WqADa3wd4g5pbfB1RqwaKrGisn4Lk1Z8uvdRiMCIYEey%2BrX1sXGLF9Att2hFVJTRpU6%2B2wCaDhV2V3V%2B9c1cMQ470NR9f0tUlNL2eBKF%2BkAbaR2%2Fz2xwdYR%2BoRq9%2BRGEslNmlg7Op9F0pouy69Ztf3%2FjdajwcPW6CGbZkvz4YoJmwHrvMhFEYX6nIjaN9POzo9FtBc1zgBZhckToYWpd%2FqLFSCPuHdNMyhFa%2Bk1MnZhVuBqDVVaU8ebY7oCFNO4CN%2Bn6jq4dhYVktBFtlbXTdIonDiX5hE5xJGewTK5AkspexAyQmbpv%2BLk8t0%2F%2BGnss5w0t28%2B5Y4SY8XF%2F4uaTU4FDH1MP9PLYnkWKrfs5cntvbW4clXp6qP8fJacfF1PG%2FXxvphUBYpruqsABQInUrLxcH79eGoGkfqN7LkyK2Gxo%2B0%2FvKL7OKsESoUjBMEHS5JSAsce%2F6%2BPTnslxssUo28rRLbIKNnpaeGaXZ5yMw2FsyDsDispzD04qrOBjqZAcoE2ZJLO3OFtdE4Ogcimw4W65cNYE4Bs6DGj4%2BRo997NrIR7xI5yydudA0tv6Y7KHGVoeTQ8VgDEzWU979HKetm0WtTbWz3leRcjY6XZgSYhlKYm%2FBu3SJ2C7cMeh4J%2FNsH%2FW6zWCtVPyFgxr4j40MOdB%2BPD4ZDhoBCTlRlvvMaSWMylq2212wHYAzzy%2FEEjHQUHF%2Fv8ws8pA%3D%3D&Expires=1774893838)
- Há apenas **1 domínio** vinculado a essa conta. [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/15379889/e6ff5884-508f-4537-9dbe-c714d198a43d/image.jpg?AWSAccessKeyId=ASIA2F3EMEYEYPPFKCCI&Signature=TGrsRJ0NkmSV1J2PL542Y%2FpTX%2B4%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEGIaCXVzLWVhc3QtMSJGMEQCIAVjyPEW5ovGighqanGMAlPkQctdV3b6oYk8Pc07pnv1AiARCdC6tv76PkWE5UPe0WLixDbKJzcY5ZFDeV9B5Mp2syrzBAgrEAEaDDY5OTc1MzMwOTcwNSIMB2jnSb%2FzReYF6mcxKtAE2fBNMvMjpE6ThjTWsjY9TOw0s%2F5vdbh7tMrhJXCQVSQYD2oDEL7DhMMpUb%2BYNWT%2B%2BmA5vl3dLnxYre%2Fv%2FgyPQGkdUAaqwaoJQ%2B%2FICL7Di8BH%2B0C77T4ZHVPu9gcPXhV9U0%2BjMD%2F14zbImTCsaNCArcnzJiSHZIEwFEl6ky1kVMOCu3VkZrcA24MTn9brtrnbNH8%2BtE%2BL4f408JvglEBjx7KW6Hw5vV2%2BHGGzBtX2piIkimALS%2FxGUP0wLfbVvkSjf1pc%2Bc4bbB52Ain9OcnUCgL05p7n5y4CL5WqADa3wd4g5pbfB1RqwaKrGisn4Lk1Z8uvdRiMCIYEey%2BrX1sXGLF9Att2hFVJTRpU6%2B2wCaDhV2V3V%2B9c1cMQ470NR9f0tUlNL2eBKF%2BkAbaR2%2Fz2xwdYR%2BoRq9%2BRGEslNmlg7Op9F0pouy69Ztf3%2FjdajwcPW6CGbZkvz4YoJmwHrvMhFEYX6nIjaN9POzo9FtBc1zgBZhckToYWpd%2FqLFSCPuHdNMyhFa%2Bk1MnZhVuBqDVVaU8ebY7oCFNO4CN%2Bn6jq4dhYVktBFtlbXTdIonDiX5hE5xJGewTK5AkspexAyQmbpv%2BLk8t0%2F%2BGnss5w0t28%2B5Y4SY8XF%2F4uaTU4FDH1MP9PLYnkWKrfs5cntvbW4clXp6qP8fJacfF1PG%2FXxvphUBYpruqsABQInUrLxcH79eGoGkfqN7LkyK2Gxo%2B0%2FvKL7OKsESoUjBMEHS5JSAsce%2F6%2BPTnslxssUo28rRLbIKNnpaeGaXZ5yMw2FsyDsDispzD04qrOBjqZAcoE2ZJLO3OFtdE4Ogcimw4W65cNYE4Bs6DGj4%2BRo997NrIR7xI5yydudA0tv6Y7KHGVoeTQ8VgDEzWU979HKetm0WtTbWz3leRcjY6XZgSYhlKYm%2FBu3SJ2C7cMeh4J%2FNsH%2FW6zWCtVPyFgxr4j40MOdB%2BPD4ZDhoBCTlRlvvMaSWMylq2212wHYAzzy%2FEEjHQUHF%2Fv8ws8pA%3D%3D&Expires=1774893838)

> ⚠️ **Atenção:** Como a expiração se aproxima (02/06/2026), vale verificar a renovação do domínio no painel do Registro.br para evitar perda do domínio.