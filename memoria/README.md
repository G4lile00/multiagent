# Memória Multi-Agente — convenção de uso

Este repositório é a memória persistente do sistema multi-agente. Sincroniza com o GitHub a cada 15 minutos (timer systemd) e pode ser sincronizado manualmente com `mem-sync.sh`.

## Estrutura

```
individual/        memória privada de cada agente (longo prazo)
compartilhada/     conhecimento de todos
  decisoes.md        decisões tomadas, contexto e consequências
  descobertas.md     achados de pesquisa, análise de dados, experimentos
  estado-projetos.md estado vivo dos projetos: objetivo atual, pendências, bloqueios
```

## Regras

1. **Quem escreve**: cada agente escreve na SUA memória individual e, quando o achado interessa a todos, uma linha-resumo em `compartilhada/` apontando para o detalhe.
2. **O que registrar**: decisões e justificativas, resultados verificados, aprendizados, pendências. NÃO registrar transcrição de conversa ou log de execução.
3. **Antes de agir**: ler `compartilhada/estado-projetos.md` e a própria memória individual. Não repetir o que já foi feito.
4. **Não editar** a memória de outro agente. Correções em conteúdo alheio: registrar em `compartilhada/decisoes.md` citando o autor.

## Formato de entrada

```markdown
### [AAAA-MM-DD HH:MM] <agente> — <título curto>
- Contexto: (1 linha)
- Decisão/Achado: (2-4 linhas, objetivo)
- Consequência/Próximo passo: (1 linha)
```

Exemplo:

```markdown
### [2026-11-13 14:30] arquiteto — escolha do ORM do projeto-faturamento
- Contexto: MVP de faturamento, 3 tabelas, time de 1 dev.
- Decisão: usar SQLite via stdlib (sem ORM). Volume previsto cabe em SQLite;
  removes dependência e simplifica deploy.
- Consequência: dev-backend não deve incluir SQLAlchemy no requirements.
```

## Curadoria

- Toda segunda-feira (ou sob pedido), o assistente principal resume entradas antigas de mais de 30 dias em um parágrafo no topo do arquivo e remove o detalhe (o histórico permanece no git).
- `estado-projetos.md` mantém apenas o estado ATUAL: reescrever, não acumular.
