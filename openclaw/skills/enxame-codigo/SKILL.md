---
name: enxame-codigo
description: Orquestra o enxame de código OpenCode (developer_team: arquiteto, devs, revisor) com protocolo de validação. Use quando o usuário pedir implementação de código, refatoração ou correção que mereça mais de um agente. Para revisão sistemática de literatura, use revisao-sistematica.
metadata:
  openclaw:
    requires:
      bins:
        - opencode
---

# Enxame de código via OpenCode (developer_team)

Agentes: `developer_team/arquiteto`, `developer_team/dev-backend`, `developer_team/dev-frontend`, `developer_team/revisor`. Os arquivos de definição ficam em `.opencode/agents/developer_team/` do projeto.

## Quando usar

- Implementação de feature/scrípt com mais de um arquivo
- Refatoração com risco de regressão
- Correção de bug que precisa de verificação com testes

Para tarefa trivial (1 arquivo, sem testes), NÃO use esta skill: faça você mesmo.

## Protocolo

1. **Prepare o despacho** (você): objetivo em 1 frase, critérios de aceite verificáveis, restrições (não tocar em X, usar Y), diretório do projeto. Consulte `$HOME/memoria/compartilhada/estado-projetos.md`.
2. **Plano**: despache ao arquiteto do time de código:
   ```bash
   cd <diretorio-do-projeto> && opencode run --agent developer_team/arquiteto "<objetivo>. Critérios de aceite: <lista>. Restrições: <lista>. Produza o plano e delegue aos devs."
   ```
3. **Valide o plano** contra o pedido original. Rejeitado -> devolva com correção (1 vez); persistindo, reescreva o plano você mesmo.
4. **Execução**: acompanhe a delegação aos devs. Exija artefatos (arquivos tocados, testes rodados), não promessas.
5. **Revisão**: exija veredito do revisor. DEVOLVIDO -> corrija e re-revise. Limite: 3 ciclos.
6. **Verificação final** (você): confira item a item os critérios de aceite.
7. **Registro**: entrada em `$HOME/memoria/individual/enxame.md`; atualize `estado-projetos.md` se necessário; rode a skill `memoria-sync`.

## Execução direta (atalho)

```bash
$HOME/bin/enxame.sh <agente> "<tarefa>" [diretorio]
```

## Cuidados

- Cada `opencode run` consome cota GLM; evite re-despachos desnecessários.
- O subagente não vê esta conversa: tudo que ele precisa vai no texto do despacho.
- Erro 1302 (cota) -> pause o enxame, avise o usuário, aguarde a janela de renovação.
