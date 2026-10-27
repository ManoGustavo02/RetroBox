# Preparação e publicação · RetroBox 2.8.0

Central de Ideias / Feedback Hub como módulo opt-in independente do catálogo de scripts. UI nativa com PT/EN, prévia, jogo/identidade e webhook ou transporte customizado. [Guia](../RetroBox-UI-v1.1.0/retrobox-ui/docs/FEEDBACK-HUB.md) · [Release](../RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.8.md) · [Validação](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md).

Validação local: 573 testes de lógica, 42 exemplos, 34 regressões novas, 37 testes do consumidor, 24 Node, dois Python, 20 manifests e 11 exemplos do prompt, além do starter do usuário. A promoção usa a árvore exata da pull request validada no CI, com os oito testes Chromium.

Runtime: 807181 bytes; SHA-256 `fb6d47c4ba3f43bd307fb5243beed35da0ac24349cae901c672683cbc1414a9b`. API 2, bootstrap, Designer e releases anteriores preservados. Sem credenciais reais ou POST de teste a um Discord real; o renderer Roblox não está disponível neste ambiente.

---

## Histórico da publicação 2.7.0

# Preparação e publicação · RetroBox 2.7.0

Acabamento compartilhado na library e no Hub, RGB opcional em textos, carregamento e perfis locais de aparência. [Relatório técnico](../RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.7.md) · [Validação](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md) · [Demonstração](../RetroBox-UI-v1.1.0/retrobox-ui/examples/appearance-and-rgb.lua).

539 testes de lógica, 41 exemplos, 26 novas regressões, 37 testes do consumidor, 24 Node, dois Python e 19 manifests conferidos localmente. A promoção usa a árvore validada na pull request, incluindo os oito testes Chromium no CI. O renderer Roblox não está disponível neste ambiente.

Runtime: 768050 bytes; SHA-256 `5d64663839ffce66334ec4f1021aca49803bbda76d2caa88cb343ac8c8b9e0a8`. API 2, endereço permanente do bootstrap, Designer e releases históricas preservados. O consumidor mantém SHA-256 `e56b77521c5f159923fcdd0f66eb235b8900299c7fcca4a05c3136f72913655b`, seus jogos/IDs e endereços.

---

## Histórico da publicação 2.6.0

# Preparação e publicação · RetroBox 2.6.0

Identidade real do jogador com recuperação automática e movimento coordenado na library. [Relatório técnico](../RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.6.md) · [Validação](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md) · [Demonstração nativa](../RetroBox-UI-v1.1.0/retrobox-ui/examples/motion-and-profile.lua).

A promoção para main ocorre após os checks da pull request. O [histórico de CI](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml) registra testes e versão revisada. As alterações ficam na própria library e se aplicam ao Hub padrão e aos outros consumidores da API 2. Nenhum catálogo/ID/URL do usuário foi modificado.

Validação local: 513 testes de lógica, 40 exemplos, 37 testes do consumidor, 24 Node, dois Python e 18 manifests. O CI inclui a suíte de oito testes Chromium. A renderização Roblox não foi executada; estados intermediários são testados com doubles, com demonstração nativa disponível para conferência no executor.

Artefato: 729528 bytes, SHA-256 `bbffc9a97395f33f70e9d2d92650e609c816045ad7bd6638368d5655d96bfb54`. API 2, bootstrap permanente, Designer e releases anteriores preservados. A distribuição contém `dist/releases/2.6.0`, manifests e aliases Stable/Preview.

---

## Histórico da publicação 2.5.2

# Preparação e publicação · RetroBox 2.5.2

Correção compartilhada do launcher e dos controles tradicionais, sem ajustes nos scripts consumidores. Veja o [relatório das causas e arquivos](../RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.5.2.md) e os [resultados locais](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md).

## Integridade e compatibilidade

API 2, estrutura histórica, perfis/favoritos e bootstrap permanente preservados. A árvore publicada contém a release imutável `dist/releases/2.5.2`, seus manifests e aliases Stable/Preview. A promoção para `main` é feita após o CI da pull request; o [histórico do workflow](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml) mantém os resultados hospedados.

Runtime: 712884 bytes; SHA-256 `d92198fadfeea99b8af366968de6acdf09265475edbc677768deb47aa9b231f5`. Os 17 manifests são conferidos com hashlib; bootstrap/Designer e releases anteriores não foram modificados. O consumidor anexado preserva SHA-256 `e56b77521c5f159923fcdd0f66eb235b8900299c7fcca4a05c3136f72913655b`, sete jogos/IDs e os endereços Pastefy configurados pelo usuário.

## Limites de verificação

482 testes de lógica, 37 de compatibilidade do consumidor, 24 Node e dois Python passaram localmente. O CI inclui os oito testes Chromium. O Chromium local não estava instalado e não houve inspeção visual dentro do Roblox. As capturas fornecidas e os cálculos de geometria fundamentam os defeitos investigados; não são apresentados como renderização da versão corrigida.

---

## Histórico da publicação 2.5.1

# Preparação e publicação · RetroBox 2.5.1

Repositório **ManoGustavo02/RetroBox**, main, API 2. Inclui o Designer completo da família 2.5 e a correção de avaliação de subexpressões compartilhadas.

## Entrega e compatibilidade

HTML autossuficiente em [designer/index.html](../designer/index.html), [guia](../designer/README.md), fontes, catálogo compartilhado, 12 temas reais, 76 ícones, 21 componentes, Row e 22 blocos. Há montagem visual, editor de campos, templates, prévia, PT/EN, integração opcional de tradução e exportação JSON/Luau. A biblioteca fornece idiomas, Form, Component, CardGrid, FlowGraph e diagnóstico nativos. API 2, pasta histórica, bootstrap e IDs do catálogo do usuário preservados.

## Verificação local

466 testes nativos/39 exemplos, 24 testes Node, oito cenários Chromium, 37 testes do Hub, oito exemplos do prompt e dois testes Python. Dezesseis manifestos e 24 arquivos históricos preservados, incluindo a release 2.5.0. Runtime 702573 bytes, SHA-256 56067844fa497db3934456b1b3e1bdd747fcc3c06d4e9744f1af1a3eb1b68531. [Detalhes](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md).

## Publicação anterior conferida

A entrega 2.5.0 foi publicada no commit 8208f5a07e0a5e4957841354b3e5fcc508c7532f, árvore 07be4fdebbddbd32206f8f5d599f56b774c21b8c, com 298 arquivos. Doze arquivos públicos retornaram HTTP 200 e bytes idênticos; o bootstrap público passou nos três canais com idioma, Form, FlowGraph, universal local e limpeza estrita. Os jobs validate e designer do [workflow 39503280842](https://github.com/ManoGustavo02/RetroBox/actions/runs/39503280842) concluíram com sucesso.

## Conferência remota 2.5.1

- Publicação atômica em main: commit a16bc73a094e3c4f4cabe6dc2d1304081231d88a, árvore 0f2c4e8e3971b604e3447bf19dd3576584b32642. Os 301 arquivos correspondem à árvore local testada; a consulta recursiva não foi truncada.
- Doze arquivos públicos baixados sem login retornaram HTTP 200 e bytes idênticos: bootstrap, canais Stable/Preview, pin/runtime 2.5.1, aliases, HTML, catálogo e guias. Ambos os canais resolvem 2.5.1.
- O bootstrap baixado passou em três verificações (Stable, Preview, Pinned), criando e destruindo idioma/Form/FlowGraph/Hub com callback local inofensivo. Zero conexões residuais, Parent bloqueado ou escrita em ícone destruído; gameplay e renderer Roblox continuam fora desses testes.
- Os jobs validate e designer do [workflow 39505267355](https://github.com/ManoGustavo02/RetroBox/actions/runs/39505267355), associado à release 2.5.1, concluíram com sucesso.
- Este registro de evidência é um commit posterior que preserva os bytes da distribuição.

## Limites

Tradução arbitrária precisa de dicionário ou serviço do desenvolvedor; Locale usa idioma configurado, não nacionalidade. Call exige handlers Luau. Scripts reais de gameplay não foram executados. Renderização Roblox requer conferência no cliente. Pages, About/topics e configurações administrativas não são pressupostos como alterados; o HTML abre após download.

---

## Histórico da documentação 2.5.0

# Preparação e publicação · RetroBox 2.5.0

Repositório: **ManoGustavo02/RetroBox**, main, API **2**. Designer HTML offline com blocos, JSON e exportação Luau; localização, formulários, componentes reutilizáveis, CardGrid, FlowGraph e diagnóstico são recursos nativos para todos os consumidores.

## Organização e compatibilidade

O README bilíngue destaca [o HTML e seu guia](../designer/README.md). A pasta designer contém fontes, HTML autossuficiente, catálogo compartilhado, assets reais, projetos JSON, fixtures Luau e testes. API 2, bootstrap, pasta histórica, licença e releases até 2.4 foram preservados. Nenhum jogo ou Id do catálogo do usuário foi reescrito; nenhum paste foi publicado nem Raw inventado.

## Validação local

465 testes nativos com 39 exemplos; 22 testes Node; oito cenários no Chromium; três exportações Luau reais; 37 testes do Mano Gustavo Hub; oito exemplos do prompt integral e dois testes Python de distribuição. Quinze manifestos e 22 arquivos históricos conferidos. Runtime 702260 bytes, SHA-256 a72afad60f1cd9b5a107245a728bfd250f1e93815ef0e94edec9ec99a1ba50d7. Detalhes: [VALIDATION.md](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md).

## Conferência remota

Publicação atômica, acesso aos arquivos públicos e CI hospedado serão registrados após observação. As verificações acima são locais. GitHub Pages, About/topics e configurações administrativas não são pressupostos como alterados; o Designer abre pelo HTML baixado.

## Tradução e prévia

Locale usa o idioma configurado no Roblox, sem inferir nacionalidade. Dicionários funcionam offline; tradução arbitrária precisa do serviço do desenvolvedor. O editor envia apenas mensagens cadastradas mediante ação explícita. Custom Call exige handlers Luau. A prévia e o double de engine não substituem a conferência de fontes, gestos, assets/modelos e layout no cliente Roblox.

---

## Histórico da publicação 2.4.0

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
