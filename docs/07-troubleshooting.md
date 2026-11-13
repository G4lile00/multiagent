# 07 — Troubleshooting

## Modelos / Z.AI

**OpenCode não mostra modelos GLM em /models**
Rode `opencode auth login` de novo e confirme que escolheu *Z.AI Coding Plan* (não a API padrão). Depois feche e reabra o TUI.

**OpenClaw responde que não tem modelo / erro de provider**
Confirme `openclaw models list --all --provider zai`. Se vazio, refaça `openclaw onboard --auth-choice zai-coding-global`. Rode `openclaw doctor` para validar o config.

**Erro 1302** — cota do plano atingida na janela atual. Aguarde a renovação (janelas de 5h + semanal) ou reduza paralelismo do enxame.
**Erro 1305 / 429** — serviço sobrecarregado (mais comum no início da tarde de Cingapura). Aguarde e repita.

**Cota queima rápido**
Enxame = várias sessões GLM em paralelo. Reduza para 1 dev, use `glm-5.3` só no arquiteto/revisor e modelos menores nos devs (veja `/models`).

## Enxame OpenCode

**Agentes não aparecem em /agents**
Verifique a pasta: `.opencode/agents/` (plural, nas versões ativas; `.opencode/agent/` singular em versões antigas). Frontmatter precisa de `---` nas duas extremidades e YAML válido.

**Agente do time não é encontrado ("unknown agent: developer_team/arquiteto")**
Os times precisam estar em subpastas dentro de `agents/`: `.opencode/agents/developer_team/arquiteto.md`. Confira o ID completo em `/agents` e despache com o prefixo (`developer_team/...` ou `science_team/...`).

**Delegação entre agentes não acontece**
Confirme que o agente coordenador está em `mode: all` ou `primary` e os trabalhadores em `subagent`. Peça explicitamente: "use o subagente dev-backend para...".

**Subagente trava / contexto grande**
Subagentes começam com contexto fresco por design. Se a tarefa é enorme, divida em duas chamadas com escopo menor.

## Memória

**Timer não dispara**
`systemctl --user list-timers | grep memoria`; se vazio, rode `daemon-reload` e `enable --now` de novo. Em servidores sem sessão gráfica, garanta `loginctl enable-linger $USER` para o timer de usuário rodar sem login ativo.

**"failed to push" no sync**
Provável autenticação GitHub (docs/02, passo 2). Teste `git -C ~/memoria push` manualmente.

**Conflito de rebase recorrente**
Duas máquinas escrevendo no mesmo arquivo. Preferencialmente distribua: memória individual separada por agente e por máquina (`individual/<agente>-<maquina>.md`).

**Arquivo da memória ficou enorme**
A memória é curadoria, não log: sumarize periodicamente entradas antigas em resumos e apague o detalhe (o histórico fica no git).

## OpenClaw

**Skill não é reconhecida**
`openclaw skills check` mostra o motivo (caminho, frontmatter, pré-requisito `requires.bins` — ex.: binário `opencode` não está no PATH do usuário que roda o gateway).

**Workspace editado mas comportamento não muda**
Confirme que editou o arquivo no workspace ativo: `openclaw config get agents.defaults.workspace`. Reinicie a sessão do agente (contexto novo) após editar.

**Gateway fora do ar**
`openclaw gateway status` (ou rode `openclaw gateway` em outro terminal) e `openclaw doctor`.
