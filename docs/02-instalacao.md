# 02 — Instalação (Linux nativo)

## 0. Caminho rápido (recomendado)

O instalador do kit faz **tudo** desta página automaticamente — Node.js via nvm, OpenCode, OpenClaw, agentes das duas equipes, workspace e skills do OpenClaw, memória em `~/memoria` e timer de sync. Só sobra configurar a API key (o próprio script oferece para rodar isso no final):

```bash
git clone https://github.com/G4lile00/multiagent.git
cd multiagent
bash scripts/install.sh          # interativo
# bash scripts/install.sh --yes  # sem perguntas (aceita os padrões)
```

As seções abaixo ficam para quem quer instalar manualmente ou entender o que o script faz.

## 1. Node.js 20+

Verifique a versão:

```bash
node -v
```

Se não tiver ou for anterior à 20, instale via nvm (recomendado, evita problemas de permissão com `npm -g`):

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
exec $SHELL
nvm install --lts
nvm use --lts
```

## 2. Git

```bash
sudo apt install git        # Debian/Ubuntu
# sudo dnf install git      # Fedora
git config --global user.name  "Seu Nome"
git config --global user.email "voce@exemplo.com"
```

Configure também a autenticação com o GitHub (uma das opções):

- **gh CLI (recomendado):** `sudo apt install gh && gh auth login`
- **SSH:** gere chave (`ssh-keygen -t ed25519`) e cadastre em github.com > Settings > SSH keys

## 3. OpenCode

```bash
npm install -g opencode-ai@latest
opencode --version
```

Alternativa por script:

```bash
curl -fsSL https://opencode.ai/install | bash
```

## 4. OpenClaw

```bash
npm install -g openclaw@latest
openclaw --version
```

Na primeira execução relevante, rode o assistente de diagnóstico:

```bash
openclaw doctor
```

Ele verifica Node, permissões e dependências, e cria a estrutura inicial (`~/.openclaw` e o workspace do agente).

## 5. Dependências opcionais

- `jq` (útil para scripts): `sudo apt install jq`
- `tmux` (para observar o enxame ao vivo): `sudo apt install tmux`

## 6. Checagem

```bash
node -v && git --version && opencode --version && openclaw --version
```

Todos os comandos devem responder sem erro. Próximo passo: [03-conectar-zai.md](03-conectar-zai.md)
