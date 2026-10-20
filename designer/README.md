# RetroBox Designer 2.5

Editor visual offline para construir interfaces RetroBox, conectar blocos e exportar Luau e projeto JSON. **`index.html` funciona sozinho**, sem instalar Node, servidor ou extensão.

## Abrir o editor

1. [Baixe o HTML completo](https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/designer/index.html) com **Salvar como**, mantendo a extensão `.html`.
2. Abra o arquivo baixado no navegador. O GitHub mostra o código do HTML; o editor abre depois de baixá-lo.
3. Clique em componentes ou arraste-os para uma seção. Selecione itens em **Estrutura** e edite em **Propriedades**. Abas, seções, linhas e controles podem ser organizados sem editar Luau.
4. Em **Ligações**, conecte saídas e entradas por clique ou arraste. Arraste o cabeçalho para mover um bloco; clique no fio para removê-lo.
5. Use **Testar** para experimentar valores e eventos. Salve JSON para reabrir o projeto e exporte Luau para a biblioteca real.

Inclui 21 componentes nativos e Row, 22 tipos de bloco, os 12 temas reais e os 76 ícones pixel art. Há editor visual de campos de formulário e edição JSON para dados complexos, como tabelas, árvores e cards. Desktop/tablet/celular ajustam a prévia; o zoom é independente do tamanho exportado.

Ctrl+Z desfaz, Ctrl+Shift+Z refaz e Ctrl+S baixa JSON. O histórico tem limite de 30 versões e 6 MiB. O salvamento automático depende do navegador/origem `file:`; o **JSON baixado é o backup portátil**.

A versão 2.5.1 evita recálculo exponencial de expressões compartilhadas, com cache por leitura e regressões de refresh.

## Blocos e conexões

| Papel | Blocos |
| --- | --- |
| Eventos explícitos | Click, Change, Apply |
| Dados e condições | Value, Constant, Compare, Math, And, Or, Not, Format |
| Atualização contínua | Binding |
| Ações | Branch, SetValue, SetVisible, SetDisabled, SetText, Notify, Call, SetLocale, ApplyForm, CancelForm |

Portas quadradas levam execução; redondas levam valores. Cores distinguem número, boolean e texto. Uma entrada de dados aceita um fio. Tipos incompatíveis, IDs inexistentes, ciclos e realimentação impedem a exportação. Projetos com blocos incompletos podem ser salvos como rascunho JSON.

O exemplo inicial liga Slider → Format → Binding para atualizar um Label e Button → Notify para uma notificação. Binding é silencioso e não dispara ações de clique. Para código próprio, use **Call** e forneça o handler em `actions` no Luau. Na prévia, Call registra uma ação pendente e interrompe aquela sequência; o editor não executa código digitado nem scripts de gameplay.

## Exportação

- **Script completo** usa o bootstrap permanente API 2, com `MinVersion="2.5.1"`. Preencha os `TODO` de `actions` para ligar sua aplicação.
- **Módulo** retorna `function(Library, actions)`. Passe a library carregada e os handlers. O módulo valida handlers de Call antes de criar a janela.
- O resultado do Luau expõe `Window`, `Controls`, `States` e `Flow`.
- **JSON** usa `Kind="RetroBoxDesignerProject"`, `SchemaVersion=1`. Guarda estrutura, IDs, valores iniciais, modelos, traduções, posições e conexões. Use **Abrir JSON** para continuar.

O editor não importa Lua arbitrário, callbacks ou objetos Roblox. A exportação chama métodos reais da library e seus fixtures são executados nos testes Lua. Confira os [projetos prontos](examples/) e as [APIs nativas 2.5](../RetroBox-UI-v1.1.0/retrobox-ui/docs/DEVELOPMENT-TOOLS.md).

## Formulários e componentes reutilizáveis

Form tem **Editar campos**, com tipo, Id, título, valor inicial, obrigatório e opções específicas. Aplicar/Cancelar no editor confirma ou descarta a estrutura; na prévia e na library esses botões confirmam ou descartam os valores digitados. Dados de formulário só chegam ao State confirmado depois de Apply.

Selecione uma seção e use **Salvar como componente** para criar um modelo de até 32 controles. Adicione instâncias na biblioteca à esquerda. IDs e valores são próprios de cada instância, como `carteira/coins`. `Props` substitui opções por Id interno. Modelos não aninham Form ou outro Component; use esses grupos lado a lado.

## Idiomas e tradução opcional

Editor e prévia têm seletores de idioma independentes. Em Traduções, use **Coletar textos**, edite PT/EN e confira a prévia. Alterar o original invalida a tradução anterior. `Translate=false` exclui um controle; parâmetros como `{value}` e `{count}` devem permanecer.

Dicionários funcionam offline. Tradução automática de textos novos exige um serviço do desenvolvedor; nenhuma API paga, credencial ou backend vem embutido. O editor só envia mensagens quando você clica em **Traduzir pendentes**. Valores digitados na prévia e código não são enviados. A URL do serviço não entra no projeto exportado.

Serviço HTTPS com CORS recebe:

```json
{"sourceLocale":"pt-BR","targetLocale":"en-US","entries":[{"key":"coins.Title","text":"Moedas: {count}","context":"coins / Title"}]}
```

E retorna:

```json
{"translations":{"coins.Title":"Coins: {count}"}}
```

Há lotes de até 32 mensagens, cancelamento, timeout de 60 segundos e limite de resposta de 1 MiB. Chaves inesperadas, dados inválidos e parâmetros alterados são rejeitados. Respostas de originais já modificados são descartadas. Chaves privadas ficam no backend. HTTP local é aceito somente em localhost/127.0.0.1 para desenvolvimento.

## Limites da prévia e hospedagem

A prévia web aproxima Roblox. Ela não reproduz a engine, modelos 3D, animações ou funções do executor. Assets Roblox aparecem como indicação; imagens HTTPS podem ser carregadas pelo navegador. Keybind mostra tecla e modo; o comportamento real deve ser conferido no cliente. Verifique fontes, toque, atalhos, geometria e conteúdo avançado no Roblox.

O HTML pode ser servido em uma hospedagem estática. GitHub Pages pode ser habilitado pelo proprietário; não é necessário para abrir o arquivo local e não é pressuposto como ativo.

## Desenvolvimento

Edite `src/`; `schema.json` é compartilhado com a biblioteca; `assets.json` vem dos temas/ícones reais. Não edite o HTML gerado à mão.

```sh
# Na raiz, com liblua5.4 instalada
python3 tools/build_designer.py
python3 tools/build_designer.py --check
cd designer
npm ci --ignore-scripts
npm test
npx playwright install chromium
npm run test:browser
```

`RETROBOX_CHROMIUM` pode apontar para um Chromium instalado. Node/Playwright são dependências apenas dos testes. Da raiz, `node designer/tests/generate-fixtures.js` renova projetos e exportações de referência. A suíte Lua também executa essas exportações.

English: download the single `index.html`, open it locally, build your UI, connect typed blocks, test, save project JSON and export Luau. Change editor language in the top bar. Custom actions need Luau handlers; machine translation needs your HTTPS service. Native APIs and source remain under the original library folder.
