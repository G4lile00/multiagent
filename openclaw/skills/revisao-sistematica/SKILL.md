---
name: revisao-sistematica
description: Orquestra o pipeline de revisão sistemática com o science_team (coletor-fontes, seletor, extrator, estatistico, redator) seguindo PRISMA 2020. Use quando o usuário pedir levantamento/revisão de literatura científica, meta-análise ou revisão sistemática.
metadata:
  openclaw:
    requires:
      bins:
        - opencode
        - curl
---

# Revisão sistemática via science_team

## Quando usar

- Revisão sistemática ou meta-análise de um tema
- Levantamento estruturado de literatura (não é pesquisa rápida — para isso, use o agente `science_team/pesquisador` direto)

## Preparação (com o usuário, antes de despachar)

1. **Pergunta PICO** (população, intervenção, comparador, desfecho)
2. **Critérios de inclusão/exclusão** numerados, sem sobreposição
3. **Bases** a consultar (PubMed, OpenAlex, Europe PMC, arXiv, Crossref, LILACS/SciELO)
4. **Período e idiomas**
5. **Desfecho e medida de efeito** esperada (para o estatístico)
6. **Diretório do projeto da revisão** (o pipeline cria `busca/`, `triagem/`, `extracao/`, `analise/` dentro dele)

Ambíguo -> pergunte. Não comece sem os critérios fechados.

## Protocolo

1. **Coleta** — despache `science_team/coletor-fontes` (mode all):
   ```bash
   cd <projeto-revisao> && opencode run --agent science_team/coletor-fontes "<pergunta PICO>. Bases: <lista>. Período: <X>. Salve resultados brutos e produza busca/consolidado.csv."
   ```
   Confira: contagens por base + deduplicação reportadas.
2. **Triagem em lotes** — divida o consolidado em lotes de 10-20 resumos. Para cada lote, DUAS chamadas independentes ao `science_team/seletor` (mesmos critérios, lotes embaralhados entre as duas):
   ```bash
   opencode run --agent science_team/seletor "Triagem do lote <arquivo>. Inclusão: <critérios>. Exclusão: <critérios>."
   ```
   Compare as decisões das duas passadas: concordância vira INCLUIR/EXCLUIR; **toda discordância e todo TALVEZ você decide** (lendo o resumo) e registra o motivo em `triagem/decisoes-orchestrador.md`.
3. **Extração** — despache `science_team/extrator` com o schema de campos. Confira `extracao/faltantes.md` antes de seguir.
4. **Síntese** — despache `science_team/estatistico` (se houver >= 2 estudos por comparação): efeito combinado, heterogeneidade, forest plot, sensibilidade e **imprecisão GRADE**.
5. **Redação** — despache `science_team/redator` com a estrutura PRISMA e as seções pedidas.
6. **Verificação final** (você): fluxograma confere com as contagens? números do texto = números dos artefatos? limitações declaradas?
7. **Registro** — atualize `$HOME/memoria/compartilhada/estado-revisao.md` (contagens PRISMA + fase atual); entrada em `individual/ciencia.md` se houver aprendizado; rode a skill `memoria-sync`.

## Cuidados

- **Cota**: triagem é o gargalo (lotes x 2 seletores). Pré-filtre por palavra-chave se o volume for alto e informe o usuário do custo estimado ANTES de começar.
- **Validação humana**: para publicação, a triagem de texto completo e a aprovação final são do usuário. Você entrega a revisão auditável, não o veredito definitivo.
- Nunca informe contagem/número que não venha dos arquivos do projeto.
