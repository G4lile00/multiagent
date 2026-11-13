# 01 — Conta Z.AI, assinatura e API Key

## 1. Criar a conta

1. Acesse **https://z.ai** e clique em *Sign up* (ou vá direto à plataforma em https://platform.z.ai).
2. Cadastre-se com e-mail ou conta Google/GitHub.
3. Confirme o e-mail.

## 2. Assinar o GLM Coding Plan

1. Na plataforma, navegue até a seção **GLM Coding Plan**.
2. Escolha o plano de entrada (o mais barato, na faixa de **US$ 18/mês**). Não precisa de plano superior para esta stack.
3. Pague com cartão. A cota começa a valer imediatamente.

Importante: o Coding Plan **não é** a API convencional. É uma assinatura com cota para ferramentas de agente oficiais (OpenCode, OpenClaw, Claude Code etc.). Não gera créditos pay-per-token.

## 3. Gerar a API Key do Coding Plan

1. Na plataforma, entre em **Personal Coding Plan > Plan Overview** (chaves do Coding Plan ficam separadas das chaves da API padrão).
2. Clique em **Create API Key**, dê um nome (ex.: `stack-multiagente`) e copie a chave.
3. Guarde num cofre de senhas. **Nunca** coloque a chave em arquivos versionados.

Formato esperado: algo como `xxxxxxxx.xxxxxxxxxxxxxxxx` (a chave é usada como token de autenticação nas ferramentas).

## 4. O que esta chave habilita

| Ferramenta deste kit | Endpoint que ela usará |
| --- | --- |
| OpenCode | configurado pelo próprio `opencode auth login` (opção *Z.AI Coding Plan*) |
| OpenClaw | `https://api.z.ai/api/coding/paas/v4` (opção `zai-coding-global` no onboarding) |

Referência dos endpoints do plano, para consulta:

- Anthropic-compatível: `https://api.z.ai/api/anthropic`
- OpenAI-compatível (coding): `https://api.z.ai/api/coding/paas/v4`

## 5. Checagem

Antes de seguir para a instalação, confirme:

- [ ] Conta criada e e-mail confirmado
- [ ] Plano Coding assinado (status ativo na página do plano)
- [ ] API Key copiada e guardada em local seguro

Próximo passo: [02-instalacao.md](02-instalacao.md)
