# Stack Multi-Agente Z.AI — OpenClaw + OpenCode + Memória em Git

Kit de instalação e operação de um sistema multi-agente que usa o **GLM Coding Plan da Z.AI (plano de entrada, ~US$ 18/mês)** como provedor de modelos, sem usar a API pay-per-token.

## Arquitetura

```
                 PLANO GLM CODING (Z.AI)  —  1 chave, 2 ferramentas oficiais
                              │
              ┌───────────────┴────────────────┐
              ▼                                ▼
        OPENCLAW                          OPENCODE
   (assistente principal,         developer_team: arquiteto, 2 devs,
    memória persistente,          revisor | science_team: coletor,
    ORQUESTRADOR-VALIDADOR        seletor, extrator, estatístico, redator)
              │                                │
              └────────────┬───────────────────┘
                           ▼
              MEMÓRIA PERSISTENTE (repo git ~/memoria)
        individual/<agente>.md  +  compartilhada/*.md
                           │
                    sync a cada 15 min
                    (systemd timer → GitHub privado)
```

**Divisão de papéis:**

| Camada | Ferramenta | Papel |
| --- | --- | --- |
| Cérebro | OpenClaw | Assistente do dia a dia, memória de longo prazo, **roteia entre os times**, valida a direção e re-despacha tarefas quando necessário |
| Mãos | OpenCode subagents | `developer_team` (código em enxame) e `science_team` (pesquisa, revisão sistemática, análise de dados) |
| Livro de registro | git + GitHub | Memória individual e compartilhada, versionada e sincronizada |

## Instalação em um comando

O instalador cuida de **tudo** — dependências (Node via nvm, OpenCode, OpenClaw), agentes das duas equipes em `~/.config/opencode/agents/`, workspace e skills do OpenClaw, memória em `~/memoria` (com repo privado no GitHub se o `gh` já estiver autenticado) e timer de sync de 15 min. No final, ele oferece para rodar os dois comandos da API key — que é a única configuração manual que sobra:

```bash
git clone https://github.com/G4lile00/multiagent.git
cd multiagent
bash scripts/install.sh
```

- `--yes` — não pergunta nada (aceita os padrões)
- `--sem-api` — instala tudo e pula o passo interativo da API key
- `MEMORIA_DIR=/outra/pasta bash scripts/install.sh` — memória em outro caminho
- Rodar de novo é seguro: ele nunca sobrescreve suas memórias nem suas edições (guarda `.bak` das configs que mudar).

## Requisitos

- Linux nativo (Ubuntu/Debian/Fedora ou similar), acesso ao terminal
- Node.js 20 ou superior
- git configurado (`git config --global user.name` / `user.email`)
- Conta GitHub (para o repositório de memória privado)
- Assinatura do GLM Coding Plan da Z.AI (a partir de US$ 18/mês)

## Roteiro rápido

| Passo | O que fazer | Detalhes em |
| --- | --- | --- |
| 1 | Criar conta Z.AI, assinar o Coding Plan e gerar a API Key | [docs/01-conta-zai.md](docs/01-conta-zai.md) |
| 2 | Clonar o repo e rodar `bash scripts/install.sh` — ele instala Node/OpenCode/OpenClaw, agentes, workspace, skills, memória e timer | [docs/02-instalacao.md](docs/02-instalacao.md) |
| 3 | Configurar a API key (o instalador oferece para rodar): `opencode auth login` + `openclaw onboard --auth-choice zai-coding-global` | [docs/03-conectar-zai.md](docs/03-conectar-zai.md) |
| 4 | (Opcional) Se o `gh` não estava autenticado, criar o repo privado da memória | [docs/06-memoria-git-github.md](docs/06-memoria-git-github.md) |
| 5 | Rodar o teste ponta a ponta | [Teste E2E](#teste-ponta-a-ponta) abaixo |

> Os guias docs/04 e docs/05 explicam o que o instalador colocou onde — úteis para personalizar agentes e workspace depois.

## Teste ponta a ponta

Depois de concluir os passos 1 a 5, valide a stack inteira com um único pedido:

```
1. Abra uma conversa com o OpenClaw (Control UI ou terminal).
2. Peça: "Crie um script Python que renomeia arquivos de uma pasta
   seguindo um padrão de data, com testes. Use o enxame."
3. O que deve acontecer:
   a. O OpenClaw valida o pedido e registra o objetivo na memória compartilhada.
   b. Ele dispara o agente arquiteto do OpenCode (via skill enxame-codigo).
   c. O arquiteto devolve o plano; o OpenClaw confere se o plano atende ao pedido.
   d. Os dois devs implementam em paralelo; o revisor valida.
   e. O OpenClaw confere o resultado final, corrige a rota se preciso,
      registra decisões em ~/memoria e reporta a você.
4. Confira: git log em ~/memoria deve mostrar o commit de sync.
```

## Estrutura do kit

```
zai-multiagent-stack/
├── README.md                  este guia
├── docs/                      guias detalhados por etapa (01 a 07)
├── opencode/
│   ├── opencode.json          config do projeto OpenCode (agente padrão)
│   ├── developer_team/        enxame de código: arquiteto, devs, revisor
│   └── science_team/          enxame científico (PRISMA): coletor, seletor,
│                              extrator, estatístico, redator + pesquisador
│                              e analista-dados + guia de APIs
├── openclaw/
│   ├── openclaw.ajustes.json  ajustes finais do ~/.openclaw/openclaw.json
│   ├── workspace/             AGENTS.md (com roteamento), SOUL.md, USER.md, TOOLS.md
│   └── skills/                enxame-codigo, revisao-sistematica, memoria-sync
├── memoria/                   estrutura do repositório de memória
│   ├── individual/            uma memória por agente
│   └── compartilhada/         decisões, descobertas, estado dos projetos
├── scripts/
│   ├── install.sh             INSTALADOR COMPLETO: deps, agentes, workspace,
│   │                          skills, memória, timer — sobra só a API key
│   ├── mem-sync.sh            sincronização da memória (lock + rebase + push)
│   └── enxame.sh              atalho para despachar tarefas ao enxame
└── systemd/
    ├── memoria-sync.service   unidade do timer de sincronização
    └── memoria-sync.timer     dispara a cada 15 minutos
```

## Onde editar o quê

| Quero mudar... | Edite |
| --- | --- |
| Personalidade do assistente principal | `openclaw/workspace/SOUL.md` |
| Regras de orquestração e validação do enxame | `openclaw/workspace/AGENTS.md` |
| Personalidade/método de um agente | `opencode/developer_team/<agente>.md` ou `opencode/science_team/<agente>.md` (o corpo do Markdown é o prompt) |
| Formato dos registros de memória | `memoria/README.md` (convenção) |
| Frequência de sync | `systemd/memoria-sync.timer` (campo `OnUnitActiveSec`) |
| Caminho da memória | variável `MEMORIA_DIR` em `scripts/mem-sync.sh` e `TOOLS.md` |

## Limites e custos

- O plano de entrada do Coding Plan tem cota que renova em janelas de 5 horas (+ janela semanal). Enxames consomem cota rápido: comece com tarefas pequenas e 2-3 agentes.
- OpenClaw é atendido pela Z.ai em regime *best-effort* (pode sofrer limites temporários em horários de pico). O OpenCode, como ferramenta de código, tem prioridade.
- Nenhum dos dois usa a API pay-per-token: tudo consome a cota do plano.

## Solução de problemas

Veja [docs/07-troubleshooting.md](docs/07-troubleshooting.md).
