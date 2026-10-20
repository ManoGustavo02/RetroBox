# RetroBox 2.3.1 · Origem ManoGustavo02

Migração em 20/10/2026 (UTC), com API 2 e estrutura de arquivos preservadas. A conta conectada foi confirmada como **ManoGustavo02**. Repositório público confirmado: `https://github.com/ManoGustavo02/RetroBox`. Os resultados de conferência remota são registrados no relatório de publicação.

## Alteração

A origem padrão do updater e dos bootstraps passa a `https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main`. Os guias e exemplos ativos usam essa origem. Stable/Preview deste pacote resolvem a nova release imutável 2.3.1. Nome, diretórios, API pública, temas, perfis e launcher nativo permanecem compatíveis.

O código da library só muda no cabeçalho, em `Library.Version` e no `OfficialRoot` incorporado de `src/UpdateCore.lua`. A renderização, as personalizações, a limpeza idempotente de PixelIcons, o `SetIcon()` e os componentes da 2.3.0 são preservados.

Os artefatos 2.0.0, 2.1.0, 2.2.0 e 2.3.0 ficam byte a byte iguais aos backups verificados. Notas históricas mantêm os links originais como registro; os guias ativos apontam para a nova conta. Pins antigos também mantêm seu código histórico, incluindo suas origens embutidas. Para carregá-los pela nova distribuição, use o novo bootstrap com `Channel="pinned"` e a versão desejada.

## Consumidores e atualização

Use:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"))({Channel="stable",MinVersion="2.3.1"})
```

Um loader que ainda aponta para a conta suspensa precisa ter sua URL substituída. Hospedar a library na conta nova não redireciona os endereços da conta antiga. As próximas versões compatíveis são resolvidas ao reexecutar o bootstrap da conta nova; uma janela aberta não sofre hot swap.

O export separado do Mano Gustavo Hub preserva catálogo, IDs, tema Hacker e as sete URLs dos scripts de gameplay. Atualizar o endereço da library não recupera essas URLs antigas: os respectivos repositórios precisam de migração própria antes de afirmar que todos os scripts do catálogo estão disponíveis.

## Verificação

O relatório [VALIDATION.md](VALIDATION.md) registra os resultados locais da migração. As regressões usam o bootstrap real, os manifestos reais e o artefato real com HTTP simulado e origem estrita. A suíte anterior cobre temas, substituição de ícones, janelas, hubs, reexecução e a limpeza de PixelIcons. O verificador de origem confere os hashes históricos e limita as diferenças do runtime às três alterações descritas acima.

GitHub Actions, acesso raw sem login e renderização no executor ainda precisam de conferência após a publicação.
