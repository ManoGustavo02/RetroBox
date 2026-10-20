# RetroBox 2.4.0 · Scripts universais nativos

API 2 preservada. Esta versão adiciona `UniversalScripts` ao Script Hub compartilhado por todos os consumidores, mantendo a estrutura Window → Tab → Section → controles, os jogos e os IDs existentes.

## Comportamento

- Categoria independente, botão de navegação e tag UNIVERSAL nos cards. Nome, descrição e URL próprios; sem jogo fictício, consulta de metadados ou teleporte.
- Definição mínima com Name, Description e URL. Id opcional gerado a partir do nome, com Ids explícitos para casos que exigem estabilidade entre alterações do nome.
- URL HTTPS, incluindo Raw do Pastefy, ou Callback local. Download somente na execução, capacidades verificadas, compilação, status e cancelamento cooperativo no runtime existente.
- APIs próprias de cadastro, edição, seleção, execução e consulta. GetGames continua contendo somente jogos e GetSelectedGame retorna nil na categoria Universal.
- Perfis antigos compatíveis, seleção silenciosa e escolha de scripts independente por categoria. Trocas de tema, escala e PixelIcons preservadas.
- Catálogos JSON continuam declarativos: não podem introduzir URLs/código. Metadados e Actions locais podem atualizar universais de forma atômica.
- Bootstrap e origem GitHub da ManoGustavo02 permanecem. Artefatos 2.0.0 a 2.3.1 são preservados por bytes.

O Mano Gustavo Hub 2.2.0 fornece CONFIG.UniversalScripts e mantém o tema Hacker, os sete jogos e os IDs. As sete URLs antigas de gameplay ficam preservadas no backup, para o proprietário substituir pelos seus Raw do Pastefy. O arquivo do Hub é uma entrega para o usuário; não foi publicado em um paste.

## Uso e validação

Veja [UNIVERSAL-SCRIPTS.md](UNIVERSAL-SCRIPTS.md) para a estrutura, limites e APIs. O [exemplo executável](../examples/universal-scripts.lua) usa uma notificação local.

O relatório [VALIDATION.md](VALIDATION.md) registra testes locais e limites. Publicação, raw e workflow são registrados separadamente no [relatório do repositório](../../../docs/PREPARATION-REPORT.md). Não há renderer Roblox neste ambiente; os testes de engine simulada não comprovam a aparência final no cliente.
