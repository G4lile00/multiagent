# Science Team — guia de APIs científicas

Referência para o agente `coletor-fontes`. Todas as bases abaixo são públicas e gratuitas. **Regra geral: API oficial, nunca raspagem de sites de editoras.**

## PubMed (E-utilities)

- Base: `https://eutils.ncbi.nlm.nih.gov/entrez/eutils/`
- Buscar IDs: `esearch.fcgi?db=pubmed&term=<query>&retmax=200&retmode=json`
- Trazer resumos: `esummary.fcgi?db=pubmed&id=<ids>&retmode=json` (metadados) e `efetch.fcgi?db=pubmed&id=<ids>&rettype=abstract&retmode=text`
- Exemplo:
  ```bash
  curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=randomized%20controlled%20trial%20AND%20telemedicine&retmax=100&retmode=json"
  ```
- Limite: sem chave, 3 req/s (espaçar lote com `sleep 0.4`). Com chave de desenvolvedor, 10 req/s.

## OpenAlex

- Base: `https://api.openalex.org/works`
- Exemplo:
  ```bash
  curl -s "https://api.openalex.org/works?search=systematic%20review%20telemedicine&per-page=100&mailto=SEU_EMAIL"
  ```
- `mailto` entra no polite pool (limites melhores). Paginação via `cursor=*`.
- Retorna DOI, título, autores, ano, abstract em `abstract_inverted_index` (reconstruir invertendo o índice).

## Europe PMC

- Base: `https://www.ebi.ac.uk/europepmc/webservices/rest/search`
- Exemplo:
  ```bash
  curl -s "https://www.ebi.ac.uk/europepmc/webservices/rest/search?query=telemedicine%20AND%20OPEN_ACCESS:y&format=json&pageSize=100"
  ```
- Inclui preprints e texto completo de artigos abertos (`/article/<src>/<id>/fullTextXML`).

## arXiv

- Base: `http://export.arxiv.org/api/query`
- Exemplo:
  ```bash
  curl -s "http://export.arxiv.org/api/query?search_query=all:transformer&max_results=100"
  ```
- Resposta em Atom XML. Limite: 1 req/3 s.

## Crossref

- Base: `https://api.crossref.org/works`
- Exemplo:
  ```bash
  curl -s "https://api.crossref.org/works?query.bibliographic=telemedicine+depression&rows=100&mailto=SEU_EMAIL"
  ```
- Melhor para metadados/DOI do que para resumos.

## LILACS / SciELO (literatura Brasil e América Latina)

- Busca avançada via BVS: `https://lilacs.bvsalud.org/` (filtros, exportação dos resultados)
- SciELO API: `https://api.scielo.org/` (documentação em https://scielo.readthedocs.io)
- Exportar como RIS/CSV e salvar em `busca/lilacs/<data>/` como os demais.

## Deduplicação

- Chave preferencial: **DOI** (minúsculas, sem prefixo `https://doi.org/`). Secundária: PMID.
- PubMed e Europe PMC se sobrepõem quase 100% — conte duplicatas para o fluxo PRISMA.
