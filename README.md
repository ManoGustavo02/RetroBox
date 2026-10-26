<p align="center"><img src="assets/retrobox-banner.svg" alt="RetroBox — interfaces retrô, componentes e runtime em Luau" width="100%"></p>

# RetroBox UI

<p align="center"><img src="assets/retrobox-badges.svg" alt="RetroBox 2.6.0 · API 2 · 12 temas · 76 pixel icons · MIT" width="795"></p>

[![Validação](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml/badge.svg?branch=main)](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml)

**Uma interface retrô. Componentes para construir o seu projeto.**

Biblioteca de GUI em Luau para scripts executados no cliente Roblox por executores compatíveis. Janelas, temas, controles, dados ao vivo e Script Hubs compartilham o mesmo runtime, os perfis e a limpeza de recursos.

[English](README.en.md) · [Começar](RetroBox-UI-v1.1.0/retrobox-ui/README.md) · [API](RetroBox-UI-v1.1.0/retrobox-ui/docs/API.md) · [Script Hub](RetroBox-UI-v1.1.0/retrobox-ui/docs/SCRIPT-HUB.md) · [Exemplos](RetroBox-UI-v1.1.0/retrobox-ui/examples) · [Segurança](SECURITY.md)

> **RetroBox 2.6.0 · API 2** — distribuição da conta **ManoGustavo02**. Designer offline com blocos e exportação Luau; idiomas automáticos, formulários, componentes reutilizáveis, CardGrid e diagnóstico do catálogo. Os testes de lógica não substituem a conferência visual no executor. [Histórico e validação](RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md).

**Novo na 2.6.0:** perfil acompanha o jogador real mesmo com inicialização tardia; animações ampliadas em controles, gráficos, cards e arraste. [Relatório](RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.6.md) · [Demonstração nativa](RetroBox-UI-v1.1.0/retrobox-ui/examples/motion-and-profile.lua).

## Designer visual: monte e conecte no navegador

[**Baixar RetroBox Designer — HTML único**](https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/designer/index.html) · [**Como abrir e usar**](designer/README.md) · [Projetos de exemplo](designer/examples/)

Salve o arquivo com extensão `.html` e abra-o no navegador. Arraste controles, edite formulários, escolha o tema, interligue blocos tipados e teste a prévia. Salve o projeto em JSON e exporte Luau usando as APIs reais da library. Funciona offline; traduções automáticas opcionais usam seu próprio serviço. O GitHub mostra o código do arquivo; o editor abre depois de baixá-lo.

[Idiomas, formulários, componentes, CardGrid e grafos — APIs 2.5](RetroBox-UI-v1.1.0/retrobox-ui/docs/DEVELOPMENT-TOOLS.md).

## O que dá para construir

| Para o seu projeto | Componentes nativos |
| --- | --- |
| Menus e configurações | Janela, abas, categorias, controles, busca, perfis, atalhos e acessibilidade. |
| Dados ao vivo | StatCards, gráficos, tabelas, listas virtuais, logs e dashboards. |
| Informação fora do menu | Mini HUD, fixação de controles e barra compacta de ações. |
| Pré-visualizações | Imagens, modelos, animações e renderers definidos pelo desenvolvedor. |
| Operações acompanháveis | Tarefas, ações, grupos, cancelamento cooperativo, etapas e profiler. |
| Catálogo de jogos e scripts | Launcher nativo com busca, favoritos, miniaturas, metadados, cards e execução explícita. |

Doze temas, incluindo **Hacker**, Dracula, Nord, Sakura e Retro98, e **76 ícones pixel art embutidos**. Cada consumidor escolhe sua aparência. O launcher é parte de `CreateScriptHub`; seu projeto fornece o catálogo e os callbacks. A categoria **Universal** recebe nome, descrição e URL próprios, incluindo Raw do Pastefy. [Scripts universais](RetroBox-UI-v1.1.0/retrobox-ui/docs/UNIVERSAL-SCRIPTS.md).

## Finalidade e uso autorizado

A RetroBox oferece código e exemplos para estudo e desenvolvimento de interfaces, estado e ciclo de vida em Luau. Use-a em experiências próprias ou em ambientes para os quais você tenha autorização, respeitando as regras do Roblox, do ambiente de execução e da hospedagem.

O carregamento documentado usa HTTP e `loadstring` em executor cliente compatível. Callbacks e código remoto configurados pelo consumidor executam no ambiente desse cliente. Revise a origem e o conteúdo que você decide carregar. Não distribua credenciais ou dados pessoais nos scripts.

Este aviso esclarece a finalidade do projeto. Ele não concede permissões sobre serviços de terceiros e não garante aceitação por plataformas ou imunidade a suspensão. A licença [MIT](LICENSE) existente foi preservada.

## Primeiro contato

Este endereço permanente resolve as próximas atualizações compatíveis da API 2. Não há troca de código de uma janela já aberta.

```lua
local RetroBox = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"
))({Channel = "stable", MinVersion = "2.6.0"})
```

Monte os componentes na sequência padrão da library:

```lua
local window = RetroBox:CreateWindow({
    Id = "meu-projeto", Title = "Meu projeto", Theme = "Hacker",
})
local tab = window:CreateTab({Title = "Principal", Icon = "home"})
local section = tab:CreateSection("Controles")
section:AddButton({
    Id = "aviso", Title = "Mostrar aviso", Icon = "info",
    Callback = function() window:Notify({Content = "Interface pronta."}) end,
})
```

Para um catálogo, use [CreateScriptHub](RetroBox-UI-v1.1.0/retrobox-ui/examples/native-hub-launcher.lua). Ele recebe o launcher padrão da library. Para dados fora da janela, veja [Mini HUD](RetroBox-UI-v1.1.0/retrobox-ui/docs/COMPACT-VIEWS.md); para imagens e modelos, [Previews](RetroBox-UI-v1.1.0/retrobox-ui/docs/PREVIEWS.md).

## Estrutura preservada

| Caminho | Conteúdo |
| --- | --- |
| `RetroBox-UI-v1.1.0/retrobox-ui/RetroBox.lua` | Fonte standalone da biblioteca. |
| `RetroBox-UI-v1.1.0/retrobox-ui/src/` | Módulos incorporados ao standalone pelo builder. |
| `RetroBox-UI-v1.1.0/retrobox-ui/docs/` | API, guias, migrações e relatórios das versões. |
| `RetroBox-UI-v1.1.0/retrobox-ui/examples/` | Exemplos funcionais de demonstração. |
| `RetroBox-UI-v1.1.0/retrobox-ui/tests/` | Testes de lógica e double de engine. |
| `designer/index.html` e `designer/src/` | Editor visual completo e suas fontes, catálogo e projetos JSON. |
| `tools/build_designer.py` | Build determinístico do HTML e extração dos assets reais. |
| `dist/bootstrap/`, `dist/channels/`, `dist/releases/` | Bootstrap, canais e artefatos versionados. |

A pasta histórica faz parte dos caminhos compatíveis. A apresentação deste repositório adiciona documentação na raiz sem mover a library, alterar a API ou reescrever releases.

## Qualidade, publicação e suporte

- [Contribuir](CONTRIBUTING.md): testes e build determinístico.
- [Segurança](SECURITY.md): limites do carregamento remoto e relato de vulnerabilidades.
- [Suporte](SUPPORT.md): como reproduzir erros e tratar relatos de uso indevido.
- [Configuração do repositório](docs/REPOSITORY-SETUP.md): proprietário, descrição, topics e checklist de entrega.
- [Publicação responsável](docs/PUBLICATION.md): endereço novo, canais e configurações da conta/repositório.
- [Validação da distribuição](RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md): testes realizados e limites reais.
- [Histórico](RetroBox-UI-v1.1.0/retrobox-ui/CHANGELOG.md) e [licença MIT](LICENSE).

O workflow incluído confere fontes, distribuição e testes em pushes/PRs quando o GitHub Actions estiver habilitado. As permissões são de leitura e não há publicação automática de código.

*Banner: ilustração vetorial da identidade do projeto, não uma captura da interface Roblox.*
