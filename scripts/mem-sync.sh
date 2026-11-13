#!/usr/bin/env bash
# mem-sync.sh — sincroniza a memória persistente com o GitHub
# Uso: mem-sync.sh            (usa $MEMORIA_DIR ou $HOME/memoria)
# Seguro para rodar em paralelo: usa flock e rebase com autostash.
set -euo pipefail

MEMORIA_DIR="${MEMORIA_DIR:-$HOME/memoria}"

if [[ ! -d "$MEMORIA_DIR/.git" ]]; then
  echo "[mem-sync] ERRO: $MEMORIA_DIR não é um repositório git"
  exit 1
fi

LOCK="$MEMORIA_DIR/.sync.lock"
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "[mem-sync] outra sincronização em andamento; saindo"
  exit 0
fi

cd "$MEMORIA_DIR"

# 1. Traz atualizações do remoto sem perder edits locais não commitados
if ! git pull --rebase --autostash; then
  git rebase --abort 2>/dev/null || true
  echo "[mem-sync] ERRO no pull/rebase (conflito?). Resolva em $MEMORIA_DIR e rode de novo."
  exit 1
fi

# 2. Commita mudanças, se houver
if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "memoria: sync automático $(date '+%Y-%m-%d %H:%M:%S')"
fi

# 3. Envia, se houver remoto configurado
if git remote get-url origin >/dev/null 2>&1; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if ! git push origin "$BRANCH"; then
    echo "[mem-sync] ERRO: push falhou (autenticação/remoto). Veja docs/07."
    exit 1
  fi
else
  echo "[mem-sync] aviso: sem remoto 'origin'; sincronizei só localmente"
fi

echo "[mem-sync] ok $(date '+%H:%M:%S')"
