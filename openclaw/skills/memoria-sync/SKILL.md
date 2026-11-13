---
name: memoria-sync
description: Sincroniza a memória persistente (~/memoria) com o GitHub sob demanda — commit + pull --rebase + push com lock. Use após escritas importantes na memória ou a pedido do usuário.
metadata:
  openclaw:
    requires:
      bins:
        - git
---

# Sincronização da memória

## Quando usar

- Após registrar decisão/resultado importante na memória e não poder esperar o timer de 15 min
- Antes de despachar enxame em outra máquina (garante memória fresca)
- A pedido do usuário

## Como executar

```bash
$HOME/bin/mem-sync.sh
```

O script é idempotente e seguro: usa `flock` (não sobrepõe com o timer), `pull --rebase --autostash` (tolera edits não commitados) e só commita se houver mudanças.

## Interpretação da saída

- `[mem-sync] ok` -> tudo sincronizado
- `outra sincronização em andamento` -> espere o timer; não force
- `ERRO no pull` / `push falhou` -> informe o usuário; NÃO tente resolver com `push --force` (nunca). Conflitos se resolvem em `$HOME/memoria` com rebase manual.

## Regras

- Nunca rode `git push`/`git pull` na memória fora deste script.
- Se falhar 2 vezes seguidas, registre o problema na sua memória individual e avise o usuário com a mensagem de erro.
