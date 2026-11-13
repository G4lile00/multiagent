#!/usr/bin/env bash
# install.sh — instalador completo do kit multi-agente Z.AI
#
# Instala TUDO de uma vez, nesta ordem:
#   1. Dependências: git, Node.js 20 (via nvm), OpenCode e OpenClaw (via npm)
#   2. Scripts auxiliares em ~/bin (mem-sync.sh, enxame.sh) + PATH
#   3. Agentes OpenCode (developer_team + science_team) em ~/.config/opencode/agents/
#   4. Config do OpenCode (default_agent) em ~/.config/opencode/opencode.json
#   5. Workspace do OpenClaw (AGENTS/SOUL/USER/TOOLS.md) + skills + modelo padrão
#   6. Memória persistente em ~/memoria (git init) + repo privado no GitHub (se gh autenticado)
#   7. Timer systemd de sync a cada 15 min
#
# Único passo manual que sobra: configurar a API key (o script oferece
# para rodar `opencode auth login` e `openclaw onboard` no final).
#
# Uso:
#   bash scripts/install.sh            # interativo (pergunta onde pode decidir)
#   bash scripts/install.sh --yes      # não pergunta nada; aceita padrões
#   bash scripts/install.sh --sem-api  # idem, mas não oferece o passo da API key
#   MEMORIA_DIR=~/outra/pasta bash scripts/install.sh   # memória em outro caminho
set -euo pipefail

# ----------------------------------------------------------------------------
# Aparato: cores, log, argumentos
# ----------------------------------------------------------------------------
if [[ -t 1 ]]; then
  C_G="\033[1;32m"; C_Y="\033[1;33m"; C_R="\033[1;31m"; C_B="\033[1;36m"; C_0="\033[0m"
else
  C_G=""; C_Y=""; C_R=""; C_B=""; C_0=""
fi
ok()   { echo -e "${C_G}[ok]${C_0} $*"; }
info() { echo -e "${C_B}==> $*${C_0}"; }
warn() { echo -e "${C_Y}[aviso]${C_0} $*"; }
die()  { echo -e "${C_R}[erro]${C_0} $*" >&2; exit 1; }

YES=0
DO_API=1
for arg in "$@"; do
  case "$arg" in
    -y|--yes)     YES=1 ;;
    --sem-api)    YES=1; DO_API=0 ;;
    -h|--help)
      sed -n '2,26p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)
      die "argumento desconhecido: $arg (use --help)" ;;
  esac
done

ask() { # ask "<pergunta>" -> 0=sim
  if [[ $YES -eq 1 ]]; then return 0; fi
  local r
  read -r -p "$1 [S/n] " r </dev/tty || return 1
  [[ ! "$r" =~ ^[nN] ]]
}

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$HOME/bin"
MEMORIA_DIR="${MEMORIA_DIR:-$HOME/memoria}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
STAMP="$(date +%Y%m%d-%H%M%S)"

SUDO=""
if [[ "$(id -u)" -eq 0 ]]; then SUDO=""; 
elif command -v sudo >/dev/null 2>&1; then SUDO="sudo"; fi

echo "============================================================"
echo "  Kit multi-agente Z.AI  —  instalador completo"
echo "============================================================"
echo "  Kit:            $KIT_DIR"
echo "  Memória:        $MEMORIA_DIR"
echo "  Modo:           $([[ $YES -eq 1 ]] && echo 'não-interativo (--yes)' || echo 'interativo')"
echo "============================================================"
echo

# ----------------------------------------------------------------------------
# backup_file <destino> <novo-arquivo>: guarda .bak antes de sobrescrever
# ----------------------------------------------------------------------------
backup_file() {
  local dest="$1" new="$2"
  if [[ -f "$dest" ]] && ! cmp -s "$dest" "$new"; then
    cp "$dest" "$dest.bak.$STAMP"
    warn "backup: $(basename "$dest") -> $(basename "$dest").bak.$STAMP"
  fi
}

# install_tree <src> <dst>: copia árvore preservando subpastas, com backup
install_tree() {
  local src="$1" dst="$2" rel target f
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    target="$dst/$rel"
    mkdir -p "$(dirname "$target")"
    backup_file "$target" "$f"
    install -m 644 "$f" "$target"
  done < <(find "$src" -type f -print0)
}

have() { command -v "$1" >/dev/null 2>&1; }

# ----------------------------------------------------------------------------
# 1. Dependências
# ----------------------------------------------------------------------------
info "1/7 — Verificando e instalando dependências"

# --- git ---
if ! have git; then
  if have apt-get; then $SUDO apt-get update -y && $SUDO apt-get install -y git
  elif have dnf; then $SUDO dnf install -y git
  elif have pacman; then $SUDO pacman -Sy --noconfirm git
  else die "git não encontrado e sem gerenciador de pacotes conhecido. Instale o git e rode de novo."
  fi
fi
ok "git $(git --version | awk '{print $3}')"

# --- curl (necessário para o nvm) ---
if ! have curl; then
  if have apt-get; then $SUDO apt-get update -y && $SUDO apt-get install -y curl
  elif have dnf; then $SUDO dnf install -y curl
  elif have pacman; then $SUDO pacman -Sy --noconfirm curl
  fi
fi
have curl || die "curl é necessário para instalar o Node.js. Instale o curl e rode de novo."

# --- flock (util-linux, já vem na maioria das distros) ---
have flock || warn "flock não encontrado — o mem-sync.sh precisa dele (pacote util-linux)."

# --- Node.js 20 via nvm (instalação por usuário, sem sudo) ---
NEED_NODE=1
if have node; then
  NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  if [[ "$NODE_MAJOR" -ge 20 ]]; then
    ok "node $(node --version) (suficiente)"; NEED_NODE=0
  else
    warn "node $(node --version) é antigo; o kit exige Node 20+. Vou instalar via nvm."
  fi
fi
if [[ $NEED_NODE -eq 1 ]]; then
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    info "instalando nvm em $NVM_DIR ..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh -o /tmp/nvm-install.sh
    bash /tmp/nvm-install.sh >/dev/null
    rm -f /tmp/nvm-install.sh
  fi
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm install 20 >/dev/null
  nvm alias default 20 >/dev/null
  ok "node $(node --version) instalado via nvm"
fi
have npm || die "npm não encontrado após a instalação do Node."

# Torna node/npm visíveis mesmo se o script foi chamado fora do shell do nvm
if ! have node && [[ -s "$NVM_DIR/nvm.sh" ]]; then
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"; nvm use default >/dev/null
fi

# --- OpenCode e OpenClaw via npm ---
npm_install_global() { # $1 = pacote
  local pkg="$1" bin="$2"
  if have "$bin"; then
    ok "$bin já instalado ($(command -v "$bin"))"
    return 0
  fi
  info "instalando $pkg (npm global) ..."
  if ! npm install -g "$pkg@latest" >/dev/null 2>&1; then
    warn "npm global falhou (permissão?). Tentando com sudo ..."
    $SUDO npm install -g "$pkg@latest" >/dev/null
  fi
  have "$bin" || die "$pkg instalado mas o binário '$bin' não apareceu no PATH. Abra outro terminal e rode de novo."
  ok "$bin instalado"
}
npm_install_global "opencode-ai" "opencode"
npm_install_global "openclaw"    "openclaw"

# --- gh (opcional, para o repo de memória no GitHub) ---
HAVE_GH=0
if have gh; then HAVE_GH=1; ok "gh $(gh --version | head -1 | awk '{print $3}')"
else warn "gh (GitHub CLI) não instalado — o repo remoto da memória poderá ser criado depois (docs/06)."
fi

# ----------------------------------------------------------------------------
# 2. Scripts em ~/bin + PATH
# ----------------------------------------------------------------------------
info "2/7 — Instalando scripts auxiliares em ~/bin"
mkdir -p "$BIN_DIR"
install -m 755 "$KIT_DIR/scripts/mem-sync.sh" "$BIN_DIR/mem-sync.sh"
install -m 755 "$KIT_DIR/scripts/enxame.sh"   "$BIN_DIR/enxame.sh"
ok "mem-sync.sh e enxame.sh instalados"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    MARKER="# >>> kit-multiagente >>>"
    for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
      [[ -f "$RC" ]] || continue
      if ! grep -qF "$MARKER" "$RC"; then
        {
          echo ""
          echo "$MARKER"
          echo 'export PATH="$HOME/bin:$PATH"'
          echo "# <<< kit-multiagente <<<"
        } >> "$RC"
        ok "PATH atualizado em $RC (vale para novos terminais)"
      fi
    done
    warn "$BIN_DIR não está no PATH desta sessão: rode 'export PATH=\"\$HOME/bin:\$PATH\"' ou reabra o terminal."
    ;;
esac

# ----------------------------------------------------------------------------
# 3. Agentes OpenCode (global, preservando as pastas dos times)
# ----------------------------------------------------------------------------
info "3/7 — Instalando agentes OpenCode (developer_team + science_team)"
OC_AGENTS="$HOME/.config/opencode/agents"
install_tree "$KIT_DIR/opencode/developer_team" "$OC_AGENTS/developer_team"
install_tree "$KIT_DIR/opencode/science_team"   "$OC_AGENTS/science_team"
ok "agentes globais em $OC_AGENTS (IDs: developer_team/<agente>, science_team/<agente>)"

# --- config do OpenCode (default_agent) com merge sem quebrar o que existe ---
OC_CONFIG="$HOME/.config/opencode/opencode.json"
mkdir -p "$(dirname "$OC_CONFIG")"
[[ -s "$OC_CONFIG" ]] && ! grep -q '"default_agent": "developer_team/arquiteto"' "$OC_CONFIG" \
  && cp "$OC_CONFIG" "$OC_CONFIG.bak.$STAMP"   # guarda .bak só se for sobrescrever algo diferente
node -e '
  const fs = require("fs");
  const p = process.argv[1];
  let j = {};
  try { j = JSON.parse(fs.readFileSync(p, "utf8")); } catch (e) {}
  j["$schema"] = "https://opencode.ai/config.json";
  j.default_agent = "developer_team/arquiteto";
  fs.writeFileSync(p, JSON.stringify(j, null, 2) + "\n");
' "$OC_CONFIG"
ok "config OpenCode: default_agent = developer_team/arquiteto ($OC_CONFIG)"

# ----------------------------------------------------------------------------
# 4. Workspace do OpenClaw + skills + modelo padrão
# ----------------------------------------------------------------------------
info "4/7 — Instalando workspace e skills do OpenClaw"
WS=""
if have openclaw; then
  WS="$(openclaw config get agents.defaults.workspace 2>/dev/null | tr -d '"' || true)"
fi
WS="${WS:-$HOME/.openclaw/workspace}"
mkdir -p "$WS"
for f in AGENTS.md SOUL.md USER.md TOOLS.md; do
  backup_file "$WS/$f" "$KIT_DIR/openclaw/workspace/$f"
  install -m 644 "$KIT_DIR/openclaw/workspace/$f" "$WS/$f"
done
ok "workspace em $WS (AGENTS.md, SOUL.md, USER.md, TOOLS.md)"

install_tree "$KIT_DIR/openclaw/skills" "$WS/skills"
ok "skills instaladas: $(find "$WS/skills" -name SKILL.md | wc -l) (enxame-codigo, revisao-sistematica, memoria-sync)"

# Modelo padrão do gateway (não fatal: antes do onboarding o config pode nem existir)
if have openclaw && openclaw config set agents.defaults.model zai/glm-5.3 >/dev/null 2>&1; then
  ok "modelo padrão do OpenClaw: zai/glm-5.3"
else
  warn "não consegui gravar agents.defaults.model agora — o onboarding (passo da API key) cuida disso; confirme depois com:"
  warn "  openclaw config set agents.defaults.model zai/glm-5.3"
fi

# ----------------------------------------------------------------------------
# 5. Memória persistente (git) + repo privado no GitHub
# ----------------------------------------------------------------------------
info "5/7 — Instalando memória persistente em $MEMORIA_DIR"

# Identidade git: se o usuário não configurou, usa uma provisória LOCAL no repo
# de memória para o instalador não travar no commit.
GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
GIT_NAME="$(git config --global user.name  2>/dev/null || true)"
if [[ -z "$GIT_EMAIL" || -z "$GIT_NAME" ]]; then
  warn "git global sem user.name/user.email — usarei identidade provisória local na memória."
  warn "Configure de verdade depois:  git config --global user.name 'Seu Nome'  &&  git config --global user.email 'voce@email.com'"
fi
set_mem_identity() {
  if [[ -z "$(git -C "$MEMORIA_DIR" config user.email 2>/dev/null || true)" ]]; then
    git -C "$MEMORIA_DIR" config user.email "${GIT_EMAIL:-voce@local}"
    git -C "$MEMORIA_DIR" config user.name  "${GIT_NAME:-Voce}"
  fi
}

if [[ ! -d "$MEMORIA_DIR/.git" ]]; then
  mkdir -p "$MEMORIA_DIR"
  git init -b main "$MEMORIA_DIR" >/dev/null
  cp -r "$KIT_DIR/memoria/." "$MEMORIA_DIR/"
  set_mem_identity
  git -C "$MEMORIA_DIR" add -A
  git -C "$MEMORIA_DIR" commit -m "memoria: estrutura inicial do kit" >/dev/null
  ok "memória inicializada (individual/ + compartilhada/) e primeiro commit feito"
else
  # memória já existe: copia só o que falta, nunca sobrescreve
  COPIADOS=0
  while IFS= read -r -d '' f; do
    rel="${f#"$KIT_DIR/memoria/"}"
    if [[ ! -e "$MEMORIA_DIR/$rel" ]]; then
      mkdir -p "$(dirname "$MEMORIA_DIR/$rel")"
      cp "$f" "$MEMORIA_DIR/$rel"
      COPIADOS=$((COPIADOS + 1))
    fi
  done < <(find "$KIT_DIR/memoria" -type f -print0)
  set_mem_identity
  git -C "$MEMORIA_DIR" add -A
  git -C "$MEMORIA_DIR" commit -m "memoria: arquivos faltantes do kit ($COPIADOS)" >/dev/null 2>&1 || true
  ok "memória existente preservada ($COPIADOS arquivo(s) faltante(s) copiado(s))"
fi

# Repo remoto privado (só se gh estiver autenticado e não houver origin)
if [[ $HAVE_GH -eq 1 ]] && ! git -C "$MEMORIA_DIR" remote get-url origin >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    if ask "Criar repo PRIVADO 'memoria-multiagente' no GitHub e conectar a memória?"; then
      if gh repo create memoria-multiagente --private --source "$MEMORIA_DIR" --remote origin --push; then
        ok "repo privado criado e memória enviada"
      else
        warn "não consegui criar o repo (nome em uso? permissão?). Faça depois conforme docs/06."
      fi
    else
      info "repo remoto pulado — crie depois conforme docs/06-memoria-git-github.md"
    fi
  else
    warn "gh instalado mas não autenticado. Depois rode:  gh auth login"
    warn "e conecte a memória:  gh repo create memoria-multiagente --private --source $MEMORIA_DIR --remote origin --push"
  fi
fi

# ----------------------------------------------------------------------------
# 6. Timer systemd de sincronização (15 min)
# ----------------------------------------------------------------------------
info "6/7 — Ativando timer de sync da memória (15 min)"
if have systemctl && systemctl --user show-environment >/dev/null 2>&1; then
  UNIT_DIR="$HOME/.config/systemd/user"
  mkdir -p "$UNIT_DIR"
  install -m 644 "$KIT_DIR/systemd/memoria-sync.service" "$UNIT_DIR/"
  install -m 644 "$KIT_DIR/systemd/memoria-sync.timer"   "$UNIT_DIR/"
  systemctl --user daemon-reload
  systemctl --user enable --now memoria-sync.timer >/dev/null 2>&1 || true
  if systemctl --user is-active --quiet memoria-sync.timer; then
    ok "timer ativo: $(systemctl --user list-timers memoria-sync.timer --no-legend | awk '{print $1" "$2" "$3" ..."}')"
  else
    warn "timer instalado mas ainda não ativo (sessão sem systemd user?). Rodará ao logar."
  fi
  # Garante que o sync continue mesmo sem sessão aberta (servidor headless)
  $SUDO loginctl enable-linger "$USER" >/dev/null 2>&1 \
    && ok "linger ativado (sync funciona mesmo sem login ativo)" \
    || warn "não ativei linger (precisa de senha?): sudo loginctl enable-linger $USER"
else
  warn "systemd user indisponível (WSL sem systemd? container?). Ative o sync manual com cron:"
  warn "  crontab -e  ->  */15 * * * * $BIN_DIR/mem-sync.sh >> /tmp/mem-sync.log 2>&1"
fi

# ----------------------------------------------------------------------------
# 7. Verificação final + API key (única etapa manual que sobra)
# ----------------------------------------------------------------------------
info "7/7 — Verificação final"
FALHAS=0
for ag in "$OC_AGENTS/developer_team/arquiteto.md" \
          "$OC_AGENTS/science_team/coletor-fontes.md" \
          "$WS/AGENTS.md" "$WS/skills/enxame-codigo/SKILL.md" \
          "$MEMORIA_DIR/compartilhada/decisoes.md" "$BIN_DIR/mem-sync.sh"; do
  if [[ -f "$ag" ]]; then ok "  $(echo "$ag" | sed "s|^$HOME|~|")"; else echo -e "${C_R}[FALTA]${C_0} $ag"; FALHAS=1; fi
done
if [[ $FALHAS -ne 0 ]]; then die "algo faltou acima — rode o instalador de novo."; fi

echo
echo "============================================================"
echo "  Instalação concluída. Falta UMA coisa: a API key do Z.AI"
echo "============================================================"
echo "  1) opencode auth login   -> escolha Z.AI > Coding Plan e cole a chave"
echo "  2) openclaw onboard --auth-choice zai-coding-global"
echo
echo "  Depois valide com:  openclaw doctor"
echo "  Teste o enxame:     enxame.sh developer_team/arquiteto \"crie um hello world em Python com teste\""
echo "============================================================"

if [[ $DO_API -eq 1 ]]; then
  if ask "Configurar a chave Z.AI agora (abre os dois comandos interativos)?"; then
    info "Passo 1 de 2: opencode auth login (escolha Z.AI > Coding Plan)"
    opencode auth login || warn "opencode auth login falhou ou foi cancelado"
    info "Passo 2 de 2: onboarding do OpenClaw"
    openclaw onboard --auth-choice zai-coding-global || warn "onboard do OpenClaw falhou ou foi cancelado — rode depois"
    echo
    ok "Se ambos passaram, a stack está pronta. Valide com: openclaw doctor"
  else
    info "Sem problema — configure depois com os dois comandos do quadro acima."
  fi
fi
