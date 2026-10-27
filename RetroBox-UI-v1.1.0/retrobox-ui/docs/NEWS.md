# Novidades · RetroBox 2.9 / API 2

Todas as janelas recebem uma categoria interna Novidades, inclusive janelas com Settings=false, Script Hubs e a Central de Ideias. Ela não toma a seleção inicial das abas do consumidor. O conteúdo é criado quando a categoria é aberta.

## Duas origens independentes

**RetroBox:** histórico oficial de API 2 incluído na versão carregada. O consumidor lê cópias por Library:GetReleaseNotes() e window:GetLibraryUpdates(); não existe setter público nem opção de substituir esse histórico. LibraryUpdates e ReleaseNotes nas opções da janela são recusados. Alterar um retorno ou um perfil não altera as notas oficiais.

**Este script:** vazio por padrão. O desenvolvedor fornece ScriptUpdates na criação da janela ou usa window:SetScriptUpdates(array). O conteúdo de uma janela não altera outras janelas nem a origem RetroBox. Não há downloads, callbacks, comandos ou código nos registros.

A autoridade é a API pública: código executado no mesmo cliente pode adulterar a própria cópia local. Isso não altera o repositório oficial nem o conteúdo distribuído a outros usuários.

## Estrutura

```lua
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua'))({
    Channel='stable', MinVersion='2.9.0',
})
local window = Library:CreateWindow({
    Id='meu-script', Title='Meu script', Locale='auto',
    ScriptUpdates={{
        Id='script-1.2.0', Version='1.2.0', Date='2026-10-27',
        Title={['pt-BR']='Melhorias de interface',['en-US']='Interface improvements'},
        Description={['pt-BR']='Adicionado um painel de estatísticas.', ['en-US']='Added a statistics panel.'},
    }},
})
local tab = window:CreateTab('Principal')
local section = tab:CreateSection('Recursos')
section:AddButton({Title='Abrir novidades',Callback=function() window:OpenUpdates('Script') end})
```

Até 100 entradas, em ordem definida pelo desenvolvedor (recomenda-se a mais recente primeiro). Id único: 1–64 letras, números, pontos, underscores ou hífens. Title: até 160 caracteres; Description: até 2400. Ambos aceitam string literal ou tabela com pt-BR e en-US. Version é texto opcional de até 48 bytes; Date opcional usa YYYY-MM-DD. Campos desconhecidos são recusados. O runtime não executa descrições, comandos ou URLs e usa texto simples.

## Métodos e leitura

- window:OpenUpdates('Library'|'Script') abre a categoria e seleciona a origem. Retorna a aba.
- window:GetLibraryUpdates() / GetScriptUpdates() retornam cópias.
- window:SetScriptUpdates(array) valida tudo antes de substituir o feed local.
- window:GetUnreadUpdateCount('Library'|'Script') retorna a contagem da origem.
- window:MarkUpdateRead(source,id) marca uma entrada existente.
- window.NewsTab é a aba interna; é possível reabri-la por OpenUpdates após destruí-la explicitamente.

A marcação de leitura usa hash dos campos estáveis, não o idioma exibido. Editar conteúdo com o mesmo Id o torna não lido novamente. Somente os hashes em Appearance.Advanced.NewsRead entram nos perfis; as notas oficiais e o conteúdo do script não são importados do perfil. Mapas e limites são validados antes de aplicar a configuração.

## Publicação

Uma nova versão da RetroBox deve acrescentar sua entrada em src/News.lua, preservar as anteriores e passar pelo builder e CI. O canal stable no bootstrap permanente disponibiliza essa versão na próxima execução. Uma janela já aberta mantém as notas da versão que está rodando; não é uma conexão de notícias em tempo real. Pinned permanece na versão solicitada.

[API](API.md) · [Central de Ideias](FEEDBACK-HUB.md) · [Release 2.9](RELEASE-2.9.md)
