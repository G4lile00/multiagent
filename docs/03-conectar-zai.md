# 03 — Conectar OpenCode e OpenClaw à Z.AI

## 1. OpenCode

O OpenCode tem autenticação nativa com o Coding Plan:

```bash
opencode auth login
```

1. Na lista de provedores, escolha **Z.AI**.
2. Quando perguntar o tipo de acesso, escolha **Z.AI Coding Plan** (não a API padrão).
3. Cole a sua API Key do Coding Plan.
4. Abra o OpenCode num projeto e rode `/models` para conferir se os modelos GLM aparecem (ex.: `glm-5.3`). Selecione um GLM como padrão.

Se precisar refazer ou trocar a chave: `opencode auth logout` e repita, ou edite o arquivo de credenciais que o próprio comando indica.

## 2. OpenClaw

O OpenClaw tem uma opção de onboarding dedicada ao Coding Plan:

```bash
openclaw onboard --auth-choice zai-coding-global
```

O que isso faz:

- Detecta a chave e configura o provider `zai` apontando para `https://api.z.ai/api/coding/paas/v4`
- Define o modelo padrão GLM (ex.: `glm-5.3`)

Depois, confirme que o modelo está visível:

```bash
openclaw models list --all --provider zai
```

E que o modelo ativo é o GLM:

```bash
openclaw config get agents.defaults.model
```

Se precisar fixar manualmente, veja o modelo em `openclaw/openclaw.ajustes.json` deste kit.

## 3. Teste rápido de cada ferramenta

```bash
# OpenCode: rode dentro de uma pasta qualquer
cd /tmp && mkdir -p teste-opencode && cd teste-opencode
echo 'print("ola")' > t.py
opencode run "explique o que o arquivo t.py faz em uma frase"
```

```bash
# OpenClaw: converse pela interface/terminal e peça, por exemplo:
# "responda com uma frase: qual sua versão de modelo?"
```

Se ambos responderem com o GLM, a conexão está feita.

## 4. Referência de endpoints (consulta)

| Protocolo | URL |
| --- | --- |
| Anthropic-compatível | `https://api.z.ai/api/anthropic` |
| OpenAI-compatível (coding) | `https://api.z.ai/api/coding/paas/v4` |

Erros típicos: `1302` = cota/limite do plano atingido (aguarde a janela de renovação); `1305`/`429` = serviço sobrecarregado (aguarde e repita).

Próximo passo: [04-enxame-opencode.md](04-enxame-opencode.md)
