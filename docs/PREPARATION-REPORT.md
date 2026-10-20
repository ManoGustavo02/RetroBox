# Preparação e publicação · RetroBox 2.4.0

Repositório: **ManoGustavo02/RetroBox**, branch **main**, API **2**. Os caminhos históricos da biblioteca e o bootstrap permanente foram preservados. A 2.4.0 acrescenta suporte nativo a scripts universais para todos os consumidores de CreateScriptHub.

## Alteração entregue

UniversalScripts fica ao lado de Games, com Name, Description e URL (ou Callback local). Id é opcional. O launcher tem categoria independente e badge UNIVERSAL; não exige PlaceId, não consulta metadados de jogo e não teleporta. Execução, status, capacidades, cancelamento cooperativo, perfis e limpeza usam o runtime existente. Temas e SetIcon/PixelIcons permanecem compatíveis.

GitHub hospeda a library e seus updates; o proprietário usará links Raw do Pastefy para os scripts de gameplay e universais. O export Mano Gustavo Hub 2.2.0 mantém o tema Hacker, os sete jogos e seus IDs. Nenhum paste foi criado e nenhuma URL de Pastefy foi inventada. As sete URLs antigas estão preservadas para substituição pelos Raw reais do proprietário.

## Arquivos principais

- src/UniversalScripts.lua: normalização, APIs, execução e categoria universais.
- src/HubLauncher.lua e src/HubUpdates.lua: apresentação, seleção/perfis e catálogo declarativo.
- RetroBox.lua e tools/build_distribution.py: integração e standalone incorporado.
- tests/universal-scripts.lua, tests/universal-catalog.lua, tests/headless.lua e testes de origem/prompt.
- examples/universal-scripts.lua, documentação, canais Stable/Preview e novo pin 2.4.0.

Os caminhos src/, tests/ e docs/ acima são relativos a RetroBox-UI-v1.1.0/retrobox-ui. Pins já publicados não foram regravados.

## Validação local concluída

- **420/420** testes de lógica da library, incluindo 25 novas regressões universais e **35 exemplos** distribuídos.
- **37/37** testes do Mano Gustavo Hub 2.2.0: sete jogos preservados, tema Hacker, universais e URLs Raw do Pastefy simuladas.
- **4/4** exemplos do prompt completo; os três exemplos anteriores e a sequência bootstrap → janela → aba → seção → controles foram preservados.
- **2/2** testes Python de distribuição; **14 manifestos** e **20 arquivos históricos** conferidos.
- Runtime: **622411 bytes**, SHA-256 `c70d7ea7c17ee76e77d874d183c04d2d0c08cbb8f38921b6d28c3650b3bb7729`.
- Regressões estritas de PixelIcon/lifecycle mantidas: destruição idempotente, pai/janela destruídos, troca de ícones, temas, perfis, reexecução e hubs; nenhum Parent bloqueado registrado.

HTTP de testes usa respostas controladas. Nenhum script real de gameplay foi executado. Renderização nativa, gestos, miniaturas reais e compatibilidade com o executor precisam de conferência no Roblox.

## Conferência remota

- Publicação atômica em main: commit `b645d10cf4d6354499512b1d792ac7df0dad821b`, árvore `4dc5b0934c7077ea8a2fd171c5ec55f3211308b1`. Os **260 arquivos** da árvore remota correspondem à árvore local testada; resposta recursiva sem truncamento.
- **9 arquivos públicos** baixados por HTTPS sem login, com **HTTP 200** e igualdade de bytes: bootstrap, Stable, Preview, pin 2.4.0, runtime imutável, aliases de runtime e documentação. Ambos os canais resolvem 2.4.0.
- O bootstrap baixado publicamente passou em **3/3** verificações: Stable, Preview e Pinned 2.4.0, criando e destruindo o Hub Hacker com categoria/tag universal e uma fonte inofensiva de transporte simulado. Sem conexões residuais, Parent bloqueado ou escrita em ícone destruído. O transporte Pastefy e o renderer continuam simulados.
- [GitHub Actions · Validate RetroBox](https://github.com/ManoGustavo02/RetroBox/actions/runs/39364680359), associado ao commit de distribuição, concluiu com **success**. O badge consulta o workflow real.
- O arquivo do Mano Gustavo Hub é uma entrega separada; não foi publicado em um novo repositório ou paste. As URLs reais do Pastefy precisam ser fornecidas pelo proprietário.

A 2.3.1 e seus resultados anteriores permanecem no histórico. A documentação desta evidência é publicada em um commit posterior sem alterar os bytes da distribuição.

## Apresentação e backup

README bilíngue, banner, badges, MIT preservada e guias de contribuição/suporte/segurança permanecem. About/topics exigem configuração administrativa; o texto para copiar está em REPOSITORY-SETUP.md. Não se afirma que configurações da conta tenham sido alteradas.

O backup inclui a árvore completa da library, artefatos, prompt integral, export do Hub e relatórios. Não contém o histórico Git da conta antiga nem os sete scripts remotos de gameplay.
