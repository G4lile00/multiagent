# 04 — Os enxames no OpenCode (developer_team e science_team)

## 1. Como os enxames funcionam

Cada agente é um arquivo Markdown em `.opencode/agents/` dentro do projeto. O **frontmatter** define o comportamento; o **corpo** do arquivo é o prompt de sistema (a personalidade + método de trabalho).

- `mode: primary` — pode conduzir a sessão principal
- `mode: subagent` — só roda em sessão-filha, chamado pelo agente principal (fresh context)
- `mode: all` — ambos

Agentes em subpastas recebem o caminho como parte do ID: `.opencode/agents/developer_team/arquiteto.md` vira o agente **`developer_team/arquiteto`**. É assim que o kit separa os times — e o OpenClaw roteia por esse prefixo.

O agente primário delega via tool `subagent` (basta pedir: "use o revisor para revisar as mudanças").

## 2. Os dois times do kit

```
opencode/
├── opencode.json            default_agent: developer_team/arquiteto
├── developer_team/          ENXAME DE CÓDIGO
│   ├── arquiteto.md         (all)      planeja, divide, coordena
│   ├── dev-backend.md       (subagent) lógica/serviços/testes
│   ├── dev-frontend.md      (subagent) interface/UX/CLI
│   └── revisor.md           (subagent) revisa diff, roda testes, não edita
└── science_team/            ENXAME CIENTÍFICO (PRISMA)
    ├── coletor-fontes.md    (all)      buscas reprodutíveis em APIs (PubMed, OpenAlex...)
    ├── seletor.md           (subagent) triagem cega por critérios
    ├── extrator.md          (subagent) dados dos estudos -> CSV citando seção/página
    ├── estatistico.md       (all)      meta-análise com código, I², imprecisão GRADE
    ├── redator.md           (subagent) revisão PRISMA 2020
    ├── pesquisador.md       (all)      pesquisa geral (persona Marina Duarte)
    ├── analista-dados.md    (all)      análise de datasets
    └── README.md            guia de APIs científicas para os agentes
```

## 3. Instalar os agentes

**Por projeto (recomendado)** — na raiz do projeto de trabalho:

```bash
mkdir -p .opencode/agents
cp -r /caminho/do/kit/opencode/developer_team .opencode/agents/
cp -r /caminho/do/kit/opencode/science_team   .opencode/agents/
cp /caminho/do/kit/opencode/opencode.json .
```

Pode instalar os dois times em todo projeto, ou só o que o projeto usa. Em um projeto de código, por exemplo, copie apenas `developer_team`; num projeto de revisão, apenas `science_team`.

**Global** (vale para todo projeto): copie os times para `~/.config/opencode/agents/`.

> Nota: em versões antigas do OpenCode a pasta de projeto era `.opencode/agent/` (singular). Se os agentes não aparecerem, copie para as duas e confira com `/agents`.

## 4. Conferir se carregou

```bash
opencode
# no TUI, rode: /agents
```

Os agentes devem aparecer com o prefixo do time (`developer_team/arquiteto`, `science_team/estatistico`...).

## 5. Como usar

**Time de código** — converse com o arquiteto, que coordena os subagentes:

```bash
opencode run --agent developer_team/arquiteto "implemente <descrição>"
```

**Time científico** — os papéis se chamam em sequência (o OpenClaw orquestra via skill `revisao-sistematica`), mas cada um roda direto também:

```bash
opencode run --agent science_team/coletor-fontes "<pergunta PICO>. Bases: PubMed, OpenAlex. Período: 2015-2026."
opencode run --agent science_team/estatistico "meta-análise dos dados em extracao/dados.csv"
opencode run --agent science_team/pesquisador "levantar as 3 alternativas mais citadas para X"
```

O atalho `$HOME/bin/enxame.sh` aceita nome curto ou ID completo (ex.: `enxame.sh estatistico "..."` resolve para `science_team/estatistico`).

## 6. Regras do kit embutidas nos agentes

Todos os agentes já vêm com instruções para:

- Ler `~/memoria/compartilhada/estado-projetos.md` (e `estado-revisao.md`, no time científico) antes de começar
- Registrar o que produzem em `~/memoria/individual/` no formato da convenção (ver `memoria/README.md`)
- Não sincronizar o git da memória diretamente (o timer de 15 min cuida disso)
- No time científico: números só via código executado, fontes sempre registradas

Para ajustar a persona/método de cada agente, edite o corpo do `.md` — é só texto.
