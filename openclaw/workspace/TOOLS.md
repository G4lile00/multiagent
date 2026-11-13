# Ambiente e ferramentas

Documentação do ambiente desta máquina. Mantenha atualizado.

## Binários principais

| Binário | Uso | Observação |
| --- | --- | --- |
| `opencode` | enxames do OpenCode (times de código e ciência) | autenticado no Z.AI Coding Plan via `opencode auth login` |
| `git` | memória e projetos | |
| `gh` | operações GitHub (se instalado) | |
| `node` / `npm` | runtime das ferramentas | |

## Caminhos importantes

| Caminho | O que é |
| --- | --- |
| `$HOME/memoria` | repositório da memória persistente (este é o padrão do kit; confirme com o usuário) |
| `$HOME/memoria/compartilhada/estado-projetos.md` | estado vivo dos projetos — leitura obrigatória antes de despachar tarefas |
| `$HOME/memoria/compartilhada/estado-revisao.md` | contagens PRISMA e fase atual de revisões sistemáticas |
| `$HOME/memoria/individual/` | memórias individuais por agente |
| `$HOME/bin/enxame.sh` | atalho: `enxame.sh <team/agente ou nome> "<tarefa>" [dir]` |
| `$HOME/bin/mem-sync.sh` | sincronização da memória (com lock; seguro rodar a qualquer momento) |
| `$HOME/.openclaw/openclaw.json` | configuração do gateway |

## Como despachar aos enxames

Roteamento: código -> `developer_team` (skill `enxame-codigo`); ciência/revisão sistemática -> `science_team` (skill `revisao-sistematica`). Os agentes vivem em pastas separadas e são invocados pelo ID completo `<time>/<agente>`.

Preferência, nesta ordem:

1. Skill do time correto (`enxame-codigo` ou `revisao-sistematica`) — contêm o protocolo completo.
2. Direto: `opencode run --agent developer_team/arquiteto "<objetivo + critérios de aceite + restrições>"` (time científico: `--agent science_team/coletor-fontes` etc.) executado dentro do diretório do projeto.
3. Atalho: `$HOME/bin/enxame.sh developer_team/arquiteto "<tarefa>" /caminho/do/projeto`.

## Sincronização da memória

- Automática: timer systemd a cada 15 minutos (`memoria-sync.timer`).
- Sob demanda: `$HOME/bin/mem-sync.sh` (use após escritas importantes quando não puder esperar o timer).
- O script usa lock e `pull --rebase --autostash`: nunca force `push` manual fora dele.

## Limitações conhecidas

- Cota do GLM Coding Plan renova em janelas de 5h (+ semanal); em erro 1302, aguarde.
- OpenClaw é atendido em regime best-effort pela Z.ai; picos podem limitar temporariamente.
