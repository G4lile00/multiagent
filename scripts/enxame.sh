#!/usr/bin/env bash
# enxame.sh — atalho para despachar tarefas aos enxames do OpenCode
# Uso: enxame.sh <time/agente ou nome> "<tarefa>" [diretorio-do-projeto]
# Ex.: enxame.sh developer_team/arquiteto "implementar CLI com testes" ~/projetos/faturamento
#      enxame.sh coletor-fontes "<pergunta PICO>..." ~/revisoes/telemedicina
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Uso: $0 <team/agente ou nome> \"<tarefa>\" [diretorio-do-projeto]" >&2
  echo "developer_team: arquiteto | dev-backend | dev-frontend | revisor" >&2
  echo "science_team:   coletor-fontes | seletor | extrator | estatistico | redator | pesquisador | analista-dados" >&2
  exit 2
fi

AGENTE="$1"
TAREFA="$2"
DIR="${3:-$PWD}"

# Aceita nome curto ou ID completo <time>/<agente>
case "$AGENTE" in
  developer_team/arquiteto|developer_team/dev-backend|developer_team/dev-frontend|developer_team/revisor) ;;
  science_team/coletor-fontes|science_team/seletor|science_team/extrator|science_team/estatistico|science_team/redator|science_team/pesquisador|science_team/analista-dados) ;;
  arquiteto|dev-backend|dev-frontend|revisor)        AGENTE="developer_team/$AGENTE" ;;
  coletor-fontes|seletor|extrator|estatistico|redator|pesquisador|analista-dados) AGENTE="science_team/$AGENTE" ;;
  *)
    echo "[enxame] agente desconhecido: $AGENTE" >&2
    exit 2
    ;;
esac

if [[ ! -d "$DIR" ]]; then
  echo "[enxame] diretório não existe: $DIR" >&2
  exit 2
fi

echo "[enxame] despachando para '$AGENTE' em $DIR ..."
cd "$DIR"
exec opencode run --agent "$AGENTE" "$TAREFA"
