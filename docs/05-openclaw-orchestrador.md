# 05 — OpenClaw como assistente, orquestrador e validador

## 1. O papel do OpenClaw nesta stack

O OpenClaw é o **assistente principal** (conversa, rotina, lembretes) e o **orquestrador-validador** dos enxames: ele decide qual time acionar (código ou ciência), confere se o trabalho está na direção certa, corrige a rota e registra tudo na memória.

## 2. Instalar o workspace do kit

O workspace do OpenClaw guarda os arquivos que definem o agente. Localize o workspace atual:

```bash
openclaw config get agents.defaults.workspace
```

O padrão costuma ser `~/.openclaw/workspace` (ou `~/openclaw`). Depois:

```bash
WS=$(openclaw config get agents.defaults.workspace | tr -d '"')
cp /caminho/do/kit/openclaw/workspace/AGENTS.md  "$WS/AGENTS.md"
cp /caminho/do/kit/openclaw/workspace/SOUL.md    "$WS/SOUL.md"
cp /caminho/do/kit/openclaw/workspace/USER.md    "$WS/USER.md"
cp /caminho/do/kit/openclaw/workspace/TOOLS.md   "$WS/TOOLS.md"
```

O que cada arquivo faz:

| Arquivo | Função |
| --- | --- |
| `AGENTS.md` | Regras de operação: memória, ROTEAMENTO entre os times, protocolo de validação |
| `SOUL.md` | Personalidade: cético construtivo, direto, verificante |
| `USER.md` | Fatos sobre você (preencha com nome, projetos, preferências) |
| `TOOLS.md` | Documentação do ambiente: caminhos, binários, como rotear cada time |

Edite à vontade — são Markdown puro. Em especial, **preencha o USER.md** e ajuste o SOUL.md ao seu gosto.

## 3. Instalar as skills

```bash
WS=$(openclaw config get agents.defaults.workspace | tr -d '"')
cp -r /caminho/do/kit/openclaw/skills/enxame-codigo        "$WS/skills/"
cp -r /caminho/do/kit/openclaw/skills/revisao-sistematica  "$WS/skills/"
cp -r /caminho/do/kit/openclaw/skills/memoria-sync         "$WS/skills/"
openclaw skills check
```

- **enxame-codigo**: roteia tarefas de código ao `developer_team` via `opencode run --agent developer_team/...`, com protocolo de validação (plano do arquiteto -> conferência -> devs -> revisor -> verificação final) e limite de iterações.
- **revisao-sistematica**: roteia revisões de literatura ao `science_team` — pipeline PRISMA completo (coleta -> dupla triagem -> extração -> meta-análise com imprecisão GRADE -> redação), com estado registrado em `estado-revisao.md`.
- **memoria-sync**: ensina a rodar `scripts/mem-sync.sh` sob demanda (além do timer de 15 min).

Instale os scripts em `~/bin` (ou ajuste os caminhos no TOOLS.md):

```bash
mkdir -p ~/bin
cp /caminho/do/kit/scripts/enxame.sh   ~/bin/
cp /caminho/do/kit/scripts/mem-sync.sh ~/bin/
chmod +x ~/bin/enxame.sh ~/bin/mem-sync.sh
```

## 4. Ajustes finais no openclaw.json

Veja `openclaw/openclaw.ajustes.json` — são sobreposições opcionais (modelo padrão etc.). Aplique com cuidado, conferindo a sintaxe:

```bash
openclaw doctor
```

O doctor valida o arquivo de configuração e avisa sobre campos inválidos na sua versão.

## 5. Protocolo de validação (resumo do que está no AGENTS.md)

1. **Roteamento**: código -> `developer_team` (skill `enxame-codigo`); literatura/revisão -> `science_team` (skill `revisao-sistematica`). Sempre com o ID completo `time/agente`.
2. **Clareza**: pedido ambíguo -> pergunta antes de agir
3. **Contexto**: lê `estado-projetos.md` (e `estado-revisao.md`) e memória individual antes de decidir
4. **Plano**: pede plano ao time e confere contra o objetivo original
5. **Direção**: se o plano/resultado desviar, corrige e re-despacha (limite padrão: 3 iterações)
6. **Verificação**: exige validação (revisor no código; conferência de contagens e números na ciência) antes de declarar pronto
7. **Registro**: grava decisões e resultado na memória; roda o sync
8. **Relato**: resume para você o que foi feito, desvios e pendências

## 6. Teste

Converse com o OpenClaw e peça: (a) uma tarefa de código pequena "usando o enxame" — ele deve rotear ao developer_team; (b) "faça uma revisão sistemática de X" — ele deve fechar critérios PICO com você antes de rotear ao science_team.
