# RetroBox 2.10.0 — Central própria e Novidades sem avisos

## Comportamento

Novidades continua disponível em todas as janelas como histórico oficial da RetroBox separado das notas opcionais do script. Saem contadores, etiquetas, botão de marcar como lido e estado de leitura. Editar uma nota ou importar um perfil antigo não faz reaparecer indicadores. A API 2 conserva GetUnreadUpdateCount (sempre 0 após validar a origem) e MarkUpdateRead (validação e retorno da janela, sem persistência).

CreateFeedbackHub passa a usar uma interface própria por padrão, para qualquer consumidor da library. Cartões escolhem o tipo de relato; as etapas Mensagem, Diagnóstico e Revisar organizam o fluxo. O contexto com jogo/jogador e o status têm área própria. Categorias, navegação e textos se adaptam à largura e à escala. A janela independente tem navegação horizontal; ao abrir ferramentas normais, a navegação comum é restaurada. A Central anexada não modifica as outras abas.

Revisar mostra a mensagem completa e o diagnóstico preparado que será anexado. Enviar só acontece por ação explícita. Cancelar uma espera continua disponível nas outras etapas. Rascunho, idioma, temas, controles públicos, transporte e seus estados permanecem compatíveis. Layout='Classic' permite a apresentação anterior; GetPage/SetPage controlam as etapas do Launcher.

## Causas confirmadas e correções

- News.lua mantinha hashes de conteúdo como marcadores de leitura em Appearance.Advanced.NewsRead. O badge e as etiquetas dependiam desse estado; uma alteração do conteúdo também mudava sua identidade de leitura. O sistema foi retirado, inclusive a exportação. A importação valida e descarta marcadores antigos sem reativar indicadores.
- A Central anterior era um conjunto de seções no layout comum da janela. FeedbackLauncher.lua fornece composição e navegação próprias, reutilizando os mesmos controles, scopes e runtime. Ações têm uma única legenda alinhada; o foco encaminha para a etapa correta e overlays são fechados na navegação.
- A prévia de diagnóstico era marcada como somente leitura apenas na criação. Input:_render restaurava TextEditable ao atualizar o valor. FeedbackDiagnostics.lua agora reafirma a propriedade após atualizar a prévia, mantendo a seleção/cópia sem torná-la editável.

## Arquivos e distribuição

- Novo src/FeedbackLauncher.lua; integração em FeedbackHub.lua e tools/build_distribution.py.
- News.lua, FeedbackDiagnostics.lua, testes de diagnóstico/novidades e novos testes do launcher.
- Runtime incorporado, aliases Stable/Preview e release imutável dist/releases/2.10.0, com manifesto SHA-256.
- Guias de Novidades/Central/API, changelog, READMEs, relatórios e prompt integral docs/Prompt-RetroBox-IA-v2.10.0.md.

API 2 e bootstrap permanente preservados. Consumidores em Stable/Preview recebem a mudança ao executar novamente; MinVersion antigo compatível não fixa uma versão. Pinned e fontes fixas continuam na edição escolhida. Nenhuma credencial real acompanha o repositório.

## Verificação

625 testes de lógica e 43 exemplos passaram, incluindo 86 verificações focadas de feedback, diagnóstico/novidades e launcher. Também passaram os 12 exemplos completos do prompt, 24 testes Node e dois Python; 22 manifests e os assets foram conferidos. Incluem categoria, envio explícito, timeout/cancelamento, revisão completa, prévia somente leitura, idioma, temas, perfis legados, foco, dropdowns, Classic, Central anexada, navegação normal e reexecução. A matriz de geometria usa desktop e celulares de 390/320 pixels, escalas .75/1.5 e texto em 1.4, em PT/EN.

[Validação completa](VALIDATION.md) · [Central de Ideias](FEEDBACK-HUB.md) · [Novidades](NEWS.md)

Os serviços, transporte e geometria são simulados. Não foi enviado feedback a um Discord real; não há renderer Roblox neste ambiente. Os testes não substituem a inspeção visual e de entrada no executor alvo.
