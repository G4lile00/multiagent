# 06 — Memória persistente: git + GitHub + sync de 15 min

## 1. Conceito

A memória é um **repositório git próprio, privado no GitHub**, espelhado em `~/memoria`. Agentes leem e escrevem arquivos Markdown nele; um timer do systemd sincroniza com o GitHub a cada 15 minutos. Vantagens: histórico completo, auditoria, backup externo e acesso de qualquer máquina.

## 2. Criar o repositório

```bash
# com gh CLI autenticado (docs/02, passo 2)
gh repo create memoria-multiagente --private --clone
mv memoria-multiagente ~/memoria
```

Sem gh CLI: crie o repositório **privado** manualmente em github.com (nome: `memoria-multiagente`), depois:

```bash
git init ~/memoria && cd ~/memoria
git remote add origin git@github.com:SEU_USUARIO/memoria-multiagente.git
```

## 3. Instalar a estrutura do kit

```bash
cp -r /caminho/do/kit/memoria/. ~/memoria/
cd ~/memoria
git add -A && git commit -m "memoria: estrutura inicial"
git branch -M main
git push -u origin main
```

Estrutura:

```
~/memoria
├── README.md            convenção de registros (leia e ajuste)
├── individual/          uma memória por agente
│   ├── assistente-rotina.md   (OpenClaw)
│   ├── enxame.md              (arquiteto/devs/revisor)
│   ├── pesquisador.md
│   └── analista-dados.md
└── compartilhada/
    ├── decisoes.md            decisões tomadas e por quê
    ├── descobertas.md         achados de pesquisa e análise
    └── estado-projetos.md     estado vivo dos projetos (o "quadro do time")
```

## 4. Ativar o sync automático (systemd, sem sudo)

```bash
mkdir -p ~/.config/systemd/user
cp /caminho/do/kit/systemd/memoria-sync.service ~/.config/systemd/user/
cp /caminho/do/kit/systemd/memoria-sync.timer   ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now memoria-sync.timer
```

Conferir:

```bash
systemctl --user list-timers | grep memoria
journalctl --user -u memoria-sync.service -n 20
```

O timer dispara `scripts/mem-sync.sh` 3 minutos após o boot e a cada 15 minutos. O script usa `flock` (não sobrepõe syncs), `pull --rebase --autostash` (sobrevive a edits não commitados) e só faz commit quando há mudanças.

Para rodar na hora: `~/bin/mem-sync.sh` (ou peça ao OpenClaw pela skill memoria-sync).

## 5. Como os agentes usam a memória

Já configurado nos prompts dos agentes e no AGENTS.md do OpenClaw:

- **Leitura**: início de tarefa -> `estado-projetos.md` + memória individual do agente
- **Escrita**: fim de tarefa -> entrada no formato da convenção (ver `memoria/README.md`)
- **Regra de ouro**: memória registra decisão/resultado/aprendizado, não transcrição da conversa

## 6. Conflitos e recuperação

- O `pull --rebase --autostash` resolve a maioria dos casos sozinho.
- Se o sync falhar, o script **não** força nada: ele aborta o rebase e registra no journal. Resolva o conflito em `~/memoria` manualmente e rode `mem-sync.sh` de novo.
- Para restaurar algo apagado: `git log --oneline` + `git checkout <commit> -- <arquivo>` — todo o histórico está no GitHub.

## 7. Acessar de outra máquina

```bash
git clone git@github.com:SEU_USUARIO/memoria-multiagente.git ~/memoria
cp /caminho/do/kit/scripts/mem-sync.sh ~/bin/   # e ative o timer se quiser sync local também
```

Próximo passo: rode o [Teste ponta a ponta do README](../README.md#teste-ponta-a-ponta).
