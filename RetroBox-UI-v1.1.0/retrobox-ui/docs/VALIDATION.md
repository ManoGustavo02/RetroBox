# Validação · RetroBox UI 2.8.0

- **573/573 testes de lógica**, com **42 exemplos** pelo bootstrap real, incluindo **34 regressões novas** da Central de Ideias.
- Envio: nenhum POST na abertura; snapshot dos campos, confirmação válida, recusas, resposta inválida/204, 429, Retry-After, pausa local, duplicata entre Hubs e reenvio incerto explícito.
- Segurança do contrato: hosts e caminhos do webhook, categorias/limites, UTF-8, mentions desativadas, campos públicos limitados, token/rascunho/identidade fora dos perfis, mensagens de erro sem credenciais, transporte customizado e fallback do executor.
- Concorrência: resposta lenta/timeout, cancelamento antes e depois do início, edição durante envio, retenção/limpeza condicional do rascunho, respostas de metadados antigas, LocalPlayer tardio, fechamento de confirmação e reexecução com HTTP em andamento.
- Interface: PT/EN e auto, título/ações/categorias, nomes literais, avatar desativado/indisponível, layouts desktop/mobile, Scale .75/1.5, TextScale 1.4, contraste, ciclos repetidos, descarte externo/deferido e globais do executor somente leitura.
- **37/37 testes do Mano Gustavo Hub**; consumidor, sete jogos/IDs e URLs preservados. **24/24 Node**, **2/2 Python**, **20 manifests**, origem histórica e links/assets verificados. O CI inclui os oito testes Chromium antes da promoção.
- **11/11 exemplos completos do prompt**, além do script standalone do usuário, conferidos com HTTP/transporte simulados e sem arquivos de executor obrigatórios.
- Runtime: **807181 bytes**, SHA-256 **fb6d47c4ba3f43bd307fb5243beed35da0ac24349cae901c672683cbc1414a9b**. Stable/Preview 2.8.0; bootstrap, Designer e todas as releases anteriores preservados por bytes.

Nenhuma mensagem foi publicada em Discord real nos testes; não foi fornecido um webhook de destino. Não há cliente/renderer Roblox neste ambiente. Estes resultados validam lógica, geometria, payloads e ciclo de vida simulados, não inspeção visual nativa nem compatibilidade universal com executores. [Contrato e limites](FEEDBACK-HUB.md) · [Release](RELEASE-2.8.md).

---

## Histórico da validação 2.7.0

# Validação · RetroBox UI 2.7.0

- **539/539 testes de lógica**, com **41 exemplos** executados pelo bootstrap real. Incluem **26 regressões novas** de acabamento, RGB, carregamento e perfis de aparência.
- RGB: agendador compartilhado com ColorPickers, contraste, Unicode/RichText preservados, opções inválidas, limite de efeitos, opções substituídas sem duplicação, tema atual restaurado, visibilidade, preferências e descarte externo/deferido.
- Loading/skeletons: progresso real e desconhecido, conclusão repetida, atualização tardia, substituição, timeout, controles sem perda de valor, geometria em tamanho mínimo/escala, limites e falhas antes da alocação.
- Hub: paletas independentes entre janela e Hubs, hover/campos/pixels/overlays locais, importação atômica e anterior à criação, snapshot após exclusão do tema base, editor com repetição/descarte, metadados e catálogo universal. A matriz de contraste agora muda explicitamente o tema do Hub.
- **37/37 testes do Mano Gustavo Hub**, com seus sete jogos/IDs e URLs Pastefy. O consumidor permanece byte a byte; o harness só atualizou a expectativa do título de seção para o novo papel Text.
- **24/24 Node**, **2/2 Python**, **19 manifests** e todos os links/assets verificados. O CI da pull request inclui também os oito testes Chromium do Designer antes da promoção.
- Runtime: **768050 bytes**, SHA-256 **5d64663839ffce66334ec4f1021aca49803bbda76d2caa88cb343ac8c8b9e0a8**. Stable/Preview 2.7.0; bootstrap, Designer e todas as releases anteriores preservados por bytes.

O mock de UDim2 agora expõe o tipo e a igualdade de valor correspondentes à engine; não representa renderização. Fixtures de movimento isolado dispensam a nova apresentação inicial para medir somente o recurso sob teste. A demonstração [appearance-and-rgb.lua](../examples/appearance-and-rgb.lua) mostra componentes comuns e Hub usando as APIs públicas.

Não há cliente/renderer Roblox neste ambiente. Os resultados acima validam lógica, geometria, estados de tween simulados e limpeza; a aparência na engine deve ser conferida pela demonstração nativa. [Mudanças, limites e APIs](RELEASE-2.7.md) · [CI](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml).

---

## Histórico da validação 2.6.0

# Validação · RetroBox UI 2.6.0

- **513/513 testes de lógica**, com **40 exemplos**. Incluem **11 regressões de identidade** e **20 de movimento**, além da cobertura anterior.
- Perfil: LocalPlayer tardio, propriedades incompletas, mudança de Name/DisplayName, PlayerAdded de terceiros, avatar offline/obsoleto, reabertura com evento perdido, nome real Player, Unicode/tradução e destruição durante HTTP.
- Movimento: estados intermediários de contador e máscaras do ProgressChart, entrada/morfologia de gráficos, escala .75/1/1.5, limite de 96 tracks/512 pontos, controle Animated=false, preferências globais, arraste real do cabeçalho, modais, foco, reciclagem e destruição com ícones estritos.
- **37/37 testes do Mano Gustavo Hub** com o export conhecido e seus endereços configurados; **24/24 Node**, **2/2 Python** e **18 manifests** de distribuição.
- A demonstração `examples/motion-and-profile.lua` participa dos 40 exemplos executados pelo loader real e usa somente dados fictícios.
- Runtime: **729528 bytes**, SHA-256 **bbffc9a97395f33f70e9d2d92650e609c816045ad7bd6638368d5655d96bfb54**. Stable/Preview gerados para 2.6.0; pins anteriores preservados.

O CI da pull request executa também os oito testes Chromium do Designer antes de promover a árvore testada para main. Bootstrap e Designer são preservados por bytes; o build determinístico do editor foi verificado. Veja o [workflow](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml).

Não há renderer/cliente Roblox disponível neste ambiente. Os testes de animação usam doubles de eventos/tween com interpolação numérica e dimensional; não constituem inspeção visual na engine. O HTML do Designer não foi usado como prova das animações nativas. [Causas, comportamento e exemplo executável](RELEASE-2.6.md).

---

## Histórico da validação 2.5.2

# Validação · RetroBox UI 2.5.2

- **482/482 testes de lógica nativa**, com os **39 exemplos** existentes. Incluem **16 regressões novas** de retângulos, cliques, seleção, ajuda, teclas, perfis e limpeza.
- Matriz do Hub: PT/EN × Hacker/Retro98/Paper/Midnight × Scale .75/1/1.5 × TextScale .8/1/1.4. Também há controles tradicionais estreitos, acessórios em várias linhas e modo touch com viewport 390×844.
- **37/37 testes do Mano Gustavo Hub anexado**, com seus sete jogos, IDs e URLs do Pastefy. O consumidor foi mantido byte a byte; o harness atualizou as expectativas das URLs enviadas e do novo popup, em vez da altura do painel antigo. Fontes remotas de execução são inofensivas e simuladas.
- **24/24 testes Node** do Designer, **2/2 testes Python** de promoção/rollback/imutabilidade e **17 manifestos** verificados. O verificador de migração confirma seus 24 arquivos históricos; nenhuma release anterior foi alterada.
- Designer HTML, fontes do Designer e bootstrap permanente preservados por bytes. O build offline continua com 21 componentes e 22 blocos.
- Runtime: **712884 bytes**, SHA-256 **d92198fadfeea99b8af366968de6acdf09265475edbc677768deb47aa9b231f5**. Os canais gerados Stable/Preview apontam para 2.5.2; pins anteriores permanecem disponíveis.

A suíte Chromium possui oito testes e é executada pelo job `designer` do GitHub Actions antes da promoção desta correção para `main`. A tentativa local não iniciou o navegador porque o binário Chromium não está instalado neste ambiente; isso não é apresentado como oito testes aprovados localmente. Consulte os checks da pull request e o [histórico do CI](https://github.com/ManoGustavo02/RetroBox/actions/workflows/validate.yml) para o resultado hospedado.

As três imagens fornecidas foram abertas e inspecionadas. Não há cliente/renderer Roblox disponível aqui: os 482 testes são de lógica e geometria simulada, não uma conferência visual nativa. O preview do Designer também não é usado como substituto do renderer Roblox. [Causas, arquivos e correções](RELEASE-2.5.2.md).

---

## Histórico da validação 2.5.1

# Validação · RetroBox UI 2.5.1

- **466/466 testes nativos** com **39 exemplos**, incluindo 43 regressões dos novos recursos e três exports Luau reais.
- **24/24 testes Node** e **8/8 testes Chromium**, incluindo avaliação de DAG compartilhado em tempo linear, refresh sem cache obsoleto e comparação de registros sem depender da ordem das chaves.
- **37/37 testes do Mano Gustavo Hub**, preservando os sete jogos/IDs, tema Hacker e endereços configurados.
- **8/8 exemplos do prompt integral**; os quatro anteriores permanecem byte a byte. **2/2 testes Python** da distribuição.
- **16 manifestos** e **24 arquivos históricos** conferidos. Bootstrap permanente preservado. Stable/Preview 2.5.1.
- Runtime: **702573 bytes**, SHA-256 **56067844fa497db3934456b1b3e1bdd747fcc3c06d4e9744f1af1a3eb1b68531**.

A reprodução original fez 4.097 leituras para 12 operações compartilhadas; após a correção, fez duas (incluindo a inicialização). Regressões com 28 operações confirmam leituras constantes e valores atualizados após SetValue. Cada leitura de entrada cria seu próprio cache; ele não sobrevive a alterações ou ações.

Publicação e CI hospedado ficam no [relatório do repositório](../../../docs/PREPARATION-REPORT.md). HTTP de gameplay/tradução é simulado nos testes, com fontes inofensivas. A aparência e os gestos no Roblox ainda exigem conferência nativa. O HTML foi inspecionado no Chromium e não reproduz toda a engine.

---

## Histórico da validação 2.5.0

# Validação · RetroBox UI 2.5.0

## Designer e ferramentas · 20/10/2026 (UTC)

- **465/465 testes de lógica** da biblioteca, com **39 exemplos**. Incluem 42 novas regressões de idiomas, provider, forms, componentes, CardGrid, grafos e diagnóstico; três exportações Luau reais do Designer executadas contra os construtores nativos.
- **22/22 testes Node** do modelo/compilador: catálogo/ícones/temas reais, JSON inválido, protótipos/ciclos, escaping Luau, namespaces, traduções/parâmetros, tipos e feedback, rascunhos, templates e simulador.
- **8/8 testes no Chromium**: abertura offline, edição/duplicação/exclusão/undo, downloads JSON/Luau, reimportação, campos de formulário, ligações tipadas e movimento de blocos, PT/EN, tradutor HTTPS simulado e painéis em tela pequena.
- **37/37 testes do Mano Gustavo Hub 2.2.0** contra a 2.5, preservando os sete jogos/IDs, tema Hacker, universais e links configurados. O export conhecido foi usado sem mudar o catálogo; alterações externas do usuário no Pastefy não foram baixadas.
- **8/8 exemplos do prompt completo**: os quatro anteriores preservados byte a byte e quatro novos exemplos funcionais.
- **2/2 testes Python** de promoção/rollback/imutabilidade; **15 manifestos**, **22 arquivos históricos**, assets do editor e build determinístico conferidos.
- Runtime: **702260 bytes**, SHA-256 **a72afad60f1cd9b5a107245a728bfd250f1e93815ef0e94edec9ec99a1ba50d7**. O bootstrap permanente foi preservado por bytes; Stable/Preview resolvem a nova release e Pinned preserva as anteriores.

Os testes do navegador usaram Chrome Headless Shell 155.0.8059.84 com Playwright 1.62.1. O HTML não precisa dessas dependências para funcionar; elas são usadas somente nos testes. Transports de tradução, Pastefy e gameplay são controlados nos testes; código real de gameplay não foi executado. As regressões estritas de PixelIcon mantêm zero Parent bloqueado, zero escrita em ícone destruído e retorno das conexões ao baseline.

A conferência pública e o workflow hospedado são registrados separadamente no [relatório de publicação](../../../docs/PREPARATION-REPORT.md). A renderização da engine Roblox não está disponível aqui. A prévia HTML não comprova fontes, gestos, imagens/modelos 3D ou compatibilidade de um executor específico; confira esses pontos no cliente final.

## Reprodução

Na raiz: `python3 tools/verify_repository.py` e `python3 tools/build_designer.py --check`. Na pasta da library: `python3 tools/verify_distribution.py`, `python3 tools/verify_origin_migration.py`, `python3 tests/run_headless.py`, `python3 tests/test_release_pipeline.py`. No Designer: `npm ci --ignore-scripts`, `npm test`, `npx playwright install chromium` e `npm run test:browser`.

Os testes do prompt usam `RETROBOX_PROMPT_PATH=/caminho/Prompt-RetroBox-IA-v2.5.0.md python3 tests/run_headless.py tests/prompt-runtime.lua`. Esse arquivo integral é entregue ao proprietário separadamente.

---

## Histórico da validação 2.4.0

# Validação · RetroBox UI 2.4.0

## Scripts universais · 20/10/2026 (UTC)

- **420/420 testes de lógica** e **35 exemplos** distribuídos aprovados. São 25 novas regressões: 20 de estrutura/execução/seleção/lifecycle e 5 de catálogo JSON atômico.
- **37/37 testes do Mano Gustavo Hub 2.2.0**, com tema Hacker, sete jogos/IDs e suporte a URLs Raw HTTPS do Pastefy para jogos e universais. Downloads simulados ocorrem apenas ao executar.
- **4/4 exemplos do prompt completo**; três exemplos anteriores preservados byte a byte e novo exemplo universal separado.
- **2/2 testes Python** de promoção, rollback e imutabilidade; **14 manifestos** e **20 arquivos históricos** verificados. Bootstrap permanente preservado byte a byte.
- Runtime: **622411 bytes**, SHA-256 **c70d7ea7c17ee76e77d874d183c04d2d0c08cbb8f38921b6d28c3650b3bb7729**.

As regressões cobrem definição mínima e Id automático, validação atômica, namespace separado dos jogos, ausência de PlaceId/teleporte/metadados, badge/categoria, perfis silenciosos, CRUD, capacidade HTTP/loadstring, erro de compilação/execução, progresso, execuções duplicadas, cancelamento e resultados obsoletos. O catálogo JSON não pode injetar URLs ou código; omissão preserva os universais existentes e lista vazia os remove. Temas, escala, PixelIcons, reexecução e destruição de janelas/hubs preservam a limpeza. O double estrito não registrou Parent bloqueado.

Arquivos: src/UniversalScripts.lua, src/HubLauncher.lua, src/HubUpdates.lua, RetroBox.lua, builder, testes, novo exemplo e documentação/distribuição. Veja [RELEASE-2.4.md](RELEASE-2.4.md) e [UNIVERSAL-SCRIPTS.md](UNIVERSAL-SCRIPTS.md).

Após a publicação da 2.4.0, nove arquivos públicos passaram na comparação por bytes, Stable/Preview/Pinned passaram em três verificações com o bootstrap baixado e o workflow do commit de distribuição concluiu com sucesso. O [relatório de publicação](../../../docs/PREPARATION-REPORT.md) registra separadamente os resultados públicos observados. HTTP local é simulado, com fontes inofensivas; nenhum script real de gameplay foi executado. Não há renderer Roblox neste ambiente. Aparência, gestos e compatibilidade com o executor precisam de conferência nativa.

## Reprodução

```sh
python3 tests/run_headless.py
python3 tests/test_release_pipeline.py
python3 tools/verify_distribution.py
python3 tools/verify_origin_migration.py
```

---

## Histórico da validação 2.3.1

# Validação · RetroBox UI 2.3.1

## Migração da origem em 20/10/2026 (UTC)

- **395/395 testes de lógica aprovados**, incluindo quatro novas regressões de origem: Root padrão da conta nova e carregamento do bootstrap real com os manifestos/artefato reais em Stable, Preview e Pinned. HTTP simulado exige a origem exata ManoGustavo02; não aceita a conta antiga.
- **34 exemplos distribuídos** carregados pela suíte completa, com limpeza das conexões ao baseline.
- **34/34 testes do export do Mano Gustavo Hub 2.1.1**, usando o novo bootstrap/MinVersion=2.3.1 e o launcher nativo. Catálogo, IDs, tema Hacker e sete URLs de gameplay preservados; conteúdo remoto real não foi executado.
- **3/3 exemplos do prompt completo** executados; estrutura bootstrap → janela → aba → seção → controles preservada.
- **2/2 testes Python** de promoção, rollback e releases imutáveis. **13 manifestos** verificados por tamanho, SHA-256, versão e aliases.
- **18 arquivos históricos** (pins da library e demonstrações de distribuição) comparados aos hashes anteriores e preservados. O standalone difere da 2.3.0 apenas no cabeçalho, versão e origem padrão; o verificador confirma esse limite.
- Runtime 2.3.1: **606526 bytes**, SHA-256 **cdf44090273caed178ba477fcb17abc408d535ee4402dbcf0459a1ead828c424**.
- A suíte preserva as regressões de PixelIcon: Destroy idempotente, destruição do pai, reexecução, janelas/hubs, substituições de ícone e alternância de temas/PixelIcons, com o double estrito de Parent bloqueado.

A suíte local usa HTTP simulado. Depois da publicação, cinco arquivos públicos foram baixados sem autenticação e comparados por bytes; o bootstrap baixado passou nos três canais com o engine double. O workflow hospedado do commit de distribuição também passou. O [relatório de publicação](../../../docs/PREPARATION-REPORT.md) registra a evidência separadamente. Não há renderer Roblox neste ambiente; aparência final, miniaturas reais e compatibilidade com um executor específico precisam de execução nativa.

## Reprodução

```sh
python3 tests/run_headless.py
python3 tests/test_release_pipeline.py
python3 tools/verify_distribution.py
python3 tools/verify_origin_migration.py
```

---

## Histórico da validação 2.3.0

# Validação · RetroBox UI 2.3.0

## Executado neste pacote local

- 391/391 testes headless com liblua 5.4, incluindo 23 regressões nativas de launcher. Todos os 34 exemplos usam a API pública e liberam suas conexões.
- 34/34 testes do Mano Gustavo Hub 2.1.0 contra a library 2.3.0, incluindo os sete jogos e a migração de filtros dos perfis 2.0. As sete URLs/associações e os IDs foram preservados; somente respostas inofensivas foram executadas.
- 2 testes Python de promoção/rollback/imutabilidade; 12 manifestos conferidos com hashlib, tamanho, versão e aliases. Os 9 arquivos publicados de releases históricas e bootstrap foram comparados com o snapshot verificado e permaneceram intactos.
- Stable/Preview/Pinned locais passaram pelo bootstrap real, com manifestos e artefato reais do pacote e transporte HTTP simulado. Foram exercitados metadata, HUD/fixação, barra de ações, preview, Stepper, snapshots, profiler e lifecycle.
- Os 6 loaders consumidores anteriormente verificados carregam a API 2.3 sem funções de arquivo do executor; o Hub antigo completo também recebe o launcher nativo sem alterações. São snapshots anteriores, não novas leituras dos HEADs públicos.
- Os 3 exemplos do prompt completo executaram com sucesso. O exemplo principal permaneceu byte a byte igual ao prompt anterior. O contrato de HTTP/bootstrap/API 2 também passou no validador Python.
- Novo launcher conferido em colunas, telas pequenas/toque, TextScale/Scale e janela baixa em paisagem; posição dos controles calculada pelo double de geometria. Todos os temas passaram nos testes de contraste dos textos visíveis dos cards.
- PixelIcons continuam idempotentes, sem Parent bloqueado ou escrita em desenho destruído nos testes estritos imediatos/diferidos. A regressão de Hold ativo durante destruição externa do ScreenGui também passou.
- Build incorporado determinístico e git diff --check. O ZIP tem manifestos SHA-256 e conferência de CRC/conteúdo.

## Causa adicional confirmada e arquivos

A limpeza diferida podia destruir o desenho do check de um toggle antes da liberação do seu atalho Hold. A liberação ainda alterava o valor e acionava _render, que acessava _checkIcon.Frame após essa referência ter sido limpa. A correção verifica o estado/hierarquia do controle e o fechamento da janela antes do render, e a referência antes da animação. A liberação lógica e dos recursos permanece; não foi acrescentado pcall de supressão.

RetroBox.lua integra o launcher aos métodos existentes de catálogo, busca/foco, janela e controles. src/HubLauncher.lua contém a apresentação nativa; src/HubUpdates.lua mantém controles compactos/opções; tools/build_distribution.py incorpora o módulo no standalone. tests/hub-launcher.lua adiciona as regressões nativas; os testes de hub existentes passaram a conferir os elementos realmente visíveis. tests/prompt-runtime.lua valida os exemplos. Documentação, exemplo nativo e dist foram atualizados. No consumidor, Mano-Gustavo-Hub.lua mantém catálogo/callbacks/ferramentas e migra o perfil; o adaptador src/Launcher.lua e seu builder foram removidos.

## Limites e publicação

Nenhum teste emula o renderer Roblox. Miniaturas/metadados reais, gestos em dispositivos e compatibilidade com um executor específico ainda precisam de conferência no cliente. O código real dos sete scripts de gameplay não foi baixado nem executado. Cancelamento permanece cooperativo.

O GitHub retornou HTTP 403 com "Your account was suspended" para os dois repositórios. Este pacote não foi publicado: os canais públicos não foram atualizados. A base local contém os 222 arquivos da última RetroBox 2.2.0 verificada e os 8 arquivos do Hub 2.0.0 verificado. Não foi possível conferir alterações remotas posteriores. Veja RELEASE-2.3.md para restaurar/publicar na ordem correta.

## Reprodução

Na pasta histórica retrobox-ui, execute python3 tests/run_headless.py, python3 tests/test_release_pipeline.py e python3 tools/verify_distribution.py. Para o consumidor, use python3 tests/run_tests.py --library /caminho/RetroBox/RetroBox-UI-v1.1.0/retrobox-ui. Os comandos exigem Python/liblua 5.4 apenas para desenvolvimento. Para o prompt: RETROBOX_PROMPT_PATH=/caminho/Prompt-RetroBox-IA-v2.3.0.md python3 tests/run_headless.py tests/prompt-runtime.lua.

---

## Histórico de validação da 2.2.0

# Validação · RetroBox UI 2.2.0

## Executado na 2.2.0

- 368 testes headless com liblua 5.4, incluindo as 336 regressões anteriores e 32 novas verificações dos componentes compactos, previews e etapas. Todos os 33 exemplos carregam a API pública e retornam as conexões ao baseline.
- Dois testes Python de promoção/rollback/imutabilidade; 11 manifests de distribuição conferidos por tamanho, SHA-256, aliases e versões. Bootstrap e pins publicados da 2.0.0/2.1.0 preservados.
- Loader de cada um dos seis consumidores atuais conferido em fonte recém-lida do GitHub, carregamento headless 2.2.0 sem arquivos de executor e Hub completo com sete jogos, sem executar scripts externos.
- Os dois exemplos do prompt completo foram executados; o segundo também concluiu RunAction, atualizou o HUD e o Stepper e liberou as views.
- Nenhum destes testes emula o renderer Roblox. Conferência visual, carregamento real de animações/miniaturas e compatibilidade com um executor específico continuam precisando de execução nativa.

## Histórico anterior de validação

- Três regressões da 1.9.2 verificam descrições multiline de jogos/scripts, ajustes de escala, atualização de textos longos/curtos, posição da descrição auxiliar, largura e fallback de medição.

- Compilação sintática de todos os arquivos Lua pelo subconjunto compatível com Lua 5.4.
- **224 testes de lógica** com sinais, instâncias e serviços simulados; os 151 testes da 1.6 continuam na suíte.
- Carregamento dos 19 exemplos por HTTP simulado + compilação do conteúdo real de `RetroBox.lua`; dashboard inicia simulação/conclui ação, e runtime-integration carrega um perfil antigo, sincroniza toggles e executa coleta/venda no grupo compartilhado.
- Loader com respostas inválidas, falha de download e erro de compilação.
- GUI por gethui/CoreGui/PlayerGui: preferência, fallback quando falta permissão, Parent explícito, falhas e limpeza ao executar de novo.
- Arquivos: detecção parcial, fallback para memória, pastas criadas sob demanda, restauração em outra instância da library, JSON inválido, falha de escrita, nomes sem colisões, caminhos inválidos, funções opcionais e debounce do AutoSave.
- Componentes, callbacks, listeners, enums, cores, RGB compartilhado, importação atômica, temas, teclas, foco, configurações, buffers, notificações e limpeza das conexões.
- Oito testes de tooltip: atraso/cancelamento do hover, painel único, Tip e atualização, toque longo, fechamento, limites da tela/tema, limpeza, validação atômica, clipping, arraste e foco. Ler dicas não altera valores nem chama callbacks.
- 23 testes de novos fluxos: aba Configurações, X/RightShift/reabrir, saves nomeados por UI, confirmação, índice entre execuções, arquivos antigos, corrupção, Storage.List, captura de mouse, combinações, Hold, filas anteriores ao load, linhas responsivas, feedback, modais, pesquisa, atalhos flutuantes, aparência/posições e toque longo.
- Dez testes de pixel art: catálogo/cópias, identidade padrão, espaço de títulos com atalhos, temas/contraste, desenhos próprios, validação atômica, texto/assets anteriores, preferências persistentes/Reset/saves antigos, notificações/diálogos e limpeza em trocas repetidas. O runner também carrega o novo exemplo icons.lua.
- A 1.9.1 confere os 76 desenhos de 12×12 e os 30 novos nomes. Monta cada ícone novo com o nome estrito `pixel:`, troca os 12 temas e verifica aparência desativada/restaurada e limpeza em substituições. As exportações SVG e os dois catálogos visuais usam os mesmos padrões Lua.
- 17 testes de runtime: correção HEX/amostra, scopes/chaves/limpeza, políticas opt-in e restart, cópia/ciclos de State, lotes/perfis coerentes, bindings bidirecionais silenciosos/normalização, All/Any/Not, callbacks antigos descartados, tarefas com yield sem sobreposição, Stop All, ações Replace/Queue/Reject/Ignore e histórico limitado, botões canceláveis e diagnóstico/adapter/Debug.
- Nove testes de dashboard: formatos, cards/status/histórico, retenção/pool, barras negativas/zero, Progress/Sparkline, desenho coalescido, parâmetros inválidos sem registro parcial, linhas responsivas/resize e falhas de formatador isoladas.
- 12 testes de animação: conflitos por propriedade, Hide/Show rápidos e cliques bloqueados, ReducedMotion, preferências/perfis/Reset, collapse/search, destruição durante saída de toasts, barreira modal, drag sem relayout, minimize reversível, limpeza de componentes animados, mouse/toque/offset/foco/janelas independentes e transições de componentes durante Hide/Show.
- Cinco regressões de interação: mouse/toque com origem/inset não zero e escalas .75/1/1.5, sem salto/inércia; launcher pelo corpo, limiar/clique, dedos independentes, save/reset/resize; aba/Configurações/scroll preservados; Body/lupa/auxiliares durante recolhimento; padding central.
- 16 testes de integração: Await/resultados/falhas/Throw, timeout separado/CancelAction, contexto cancelável, conclusão anterior/destruição/deadlock, múltiplas esperas/timers, grupos/fila/políticas, próximo prazo após conclusão, status sem emissões por frame, toggles/paradas/erros/restarts/KeepRequested, listeners e scheduler com task.spawn imediato.
- Dez testes de migração: renomear/converter em sequência, cópia/original/arquivo preservados em falha, passos ausentes/versão futura/corrupção/Migrate=false, flags desconhecidas/transitórias, valores/aparência atômicos, dados sem código/ciclos, rejeição de yield, saves antigos, BindTask após lote e limites de versões/payload.
- 26 testes de componentes/contraste: registro forte de estilos, binding combinado, doze temas em cards/plots/legendas, superfícies mistas, Terminal via UI/save/load, molduras/padding, eventos de linhas descartadas, exclusão em memória/arquivos/falhas, descrição/refluxo/ajuda, virtualização/âncora/scroll horizontal, filtros/ordenação, construção inválida sem registro parcial, dados reativos, árvore e menus/submenus/toque.
- 13 testes de ferramentas: temas locais/JSON/proteção/restauração, catálogos sem aplicar flags, aparência inválida atômica, preferências/Reset/saves antigos, preview real do editor, dashboards sem reconstrução e layouts inválidos, status/grupos/cancelamento confirmado do inspector, comandos/palette/foco, e abertura/destruição repetida com recursos/eventos retornando à contagem inicial.
- Verificação dos links locais da documentação, fontes dentro do ZIP e integridade CRC.

```bash
python3 tests/run_headless.py
# ou, com Lua 5.4 instalado:
lua tests/headless.lua
```

O runner Python requer liblua5.4 e usa a biblioteca padrão do Python. O build da imagem e do ZIP usa Pillow:

```bash
python3 tools/build_package.py
```

## Limites

Os testes não renderizam texto, bordas, rolagem ou imagens, nem executam eventos reais de mouse/toque. A medição do TextService, HTTP e funções de arquivo do executor são simulados. Workers podem dar yield e tweens podem concluir depois; o double não interpola propriedades visualmente entre frames. A geometria opcional exercita AbsolutePosition/AbsoluteSize/UIScale/origem, sem reproduzir toda a engine. As esperas usam coroutines estacionadas/retomadas, com timers e task.spawn imediato ou enfileirado simulados. Isso verifica lógica/limpeza, mas não comprova desempenho, fluidez ou compatibilidade com um executor específico.

O double de Destroying também testa entrega adiada após remover a ancestralidade, conforme o comportamento descrito em [Deferred engine events](https://create.roblox.com/docs/scripting/events/deferred). Isso verifica ownership de animações, sem reproduzir todos os eventos da engine.

**Nenhum executor Roblox estava disponível neste ambiente.** A conferência em jogo e no executor alvo, incluindo Unbound, permanece pendente. Não há promessa de suporte a todos os executores.

## Conferir no executor

1. Use o raw verificado da 1.9.2 indicado no prompt ou em DISTRIBUTION.md; ele funciona mesmo antes do merge da PR.
2. Execute o showcase e confira perfil, temas, textos, rolagem, arraste, redimensionamento, minimizar/maximizar e RightShift.
3. Confira HSV, R/G/B, HEX, opacidade, RGB e velocidade. O círculo do showcase é um exemplo de ligação por callback.
4. Na aba Configurações, crie saves com nomes próprios, selecione/carregue e confira callbacks/valores. Confirme e cancele sobrescritas. Execute de novo com os mesmos IDs/ConfigFolder e confira a lista de saves e os arquivos restaurados.
5. Execute `examples/tooltips.lua`. Confira o atraso do hover, sair do controle, trocar abas, buscar, tema e dicas perto dos limites da tela. Em toque, segure o título/descrição, solte e toque para fechar; confirme que o callback não foi executado por ler a dica.
6. Execute `examples/workflows.lua`: capture teclas e Mouse 1/2/3, teste Toggle/Press/Hold, soltar fora da interface e troca do binding. Verifique linhas combinadas, setas/Enter na busca, destaque sem callback, confirmações e botão ocupado/feedback. No toque, confira arraste dos atalhos pela barra ::, ação sem arraste, tamanho/opacidade e posições restauradas. X deve ocultar e o launcher/RightShift reabrir.
7. Verifique toque e tela pequena nos dispositivos que quiser suportar; execute `tests/executor-smoke.lua`. O teste cria componentes, troca temas, importa configurações, alterna RGB, usa diálogos/busca/atalhos e abre/atualiza/fecha uma dica pela API da engine real.
8. Confira a mensagem `[RetroBox] Real-engine smoke passed`, depois inspecione a aparência e entrada. Essa mensagem sozinha não valida a experiência visual.
9. Teste `window:Destroy()` e confirme que atalhos, RGB, modais e callbacks anteriores foram encerrados.
10. Execute `examples/icons.lua`: confira catálogo, seleção, desenhos personalizados, títulos, abas/categorias e avisos. Troque os doze temas, escala e tamanho da tela; verifique contraste, recortes e atalhos junto aos títulos. Desative os ícones padrão/detalhes em Aparência, salve/carregue e confirme que ícones explícitos permanecem.
11. Execute `examples/dashboard.lua` e inicie as amostras. Confira valores, unidades, tendências, Line/Bar/Progress/Sparkline, labels, histórico máximo e comportamento em PC/celular. Mude tamanho/escala e temas enquanto atualiza. O exemplo começa pausado e usa dados simulados.
12. Inicie, cancele e reinicie Processar demonstração, inclusive ao ocultar/minimizar. Stop All deve cancelar as ações e tarefas gerenciadas. Um callback longo que ignora tokens não pode ser encerrado à força; confira cooperatividade no seu script.
13. Salve e carregue animações/arraste. Teste ReducedMotion, velocidade/intensidade, arraste próximo a bordas, foco perdido, mouse e um segundo dedo. Abra/feche repetidamente dropdowns, ColorPicker, categorias e modais; o fechamento do modal não deve acionar controles atrás dele.
14. Crie um erro intencional num callback com Debug=true, veja GetDiagnostics/OnError e depois destrua/reexecute com o mesmo Id. Confira o fim de tasks, observadores, conexões próprias gerenciadas, gráficos e animações.
15. Execute `examples/runtime-integration.lua`: ligue coleta/venda, confira exclusão no grupo, fases/contagem regressiva e desligue enquanto aguarda. Stop All deve desligar toggles por BindTask. Teste erro intencional e restart, Queue/Ignore/Reject/Replace, Await com timeout e cancelamento só da espera ou também da ação.
16. Carregue o perfil antigo do exemplo; confira renomeação da flag e conversão do intervalo antes do início da tarefa. Salve na versão atual e carregue novamente. Teste arquivo corrompido/passos ausentes e confirme que o original e os controles permanecem intactos.
17. Oculte/reabra em Configurações e numa aba rolada; recolha/restaure e confira a lupa oculta durante toda a transição. Arraste o launcher pelo corpo e por ::, clique sem mover, troque resolução e salve/reset sua posição.
18. Arraste a barra com mouse/toque em escalas .75/1/1.5, vários pontos iniciais e resoluções. Pressionar sem mover não deve deslocar; soltar não deve continuar movimento. Confira dropdowns/inputs/campos numéricos e texto com margem consistente.

`docs/visual-concept.png` e `docs/dashboard-concept.png` são ilustrações geradas a partir da paleta; não são capturas de tela da GUI em execução.

## Conferência adicional da 1.7

1. Execute examples/contrast-showcase.lua. Alterne os doze temas sem recriar widgets; observe os quatro cards das capturas, plots/legendas/escalas, porcentagem em 0/25/50/75/100%, console e tooltips. O relatório numérico complementa a inspeção visual.
2. Execute examples/advanced-components.lua: role 2.000 itens, procure/filtre, atualize dados com IDs estáveis, ordene tabelas e role horizontalmente; teste seleção, botão direito, toque longo e teclas de lista/árvore.
3. Execute examples/theme-studio.lua: crie variação, edite, restaure, salve/carregue catálogo, duplique, exporte/importe e exclua com confirmação; oficiais devem continuar preservados. LoadThemeCatalog não deve acionar flags do script.
4. Execute examples/runtime-inspector.lua: inicie tarefa, enfileire ação no grupo, gere erro intencional, observe estados e selecione detalhes. Cancelamento aparece só quando habilitado e deve confirmar. Destrua/reabra o painel e confira limpeza.
5. Execute examples/dashboard-builder.lua: mude ordem/span/altura, redimensione a janela, salve layout e restaure; updates de valores não devem recriar controles.
6. Execute examples/command-palette.lua: F4, pesquisa, seleção por clique/teclado, navegar sem executar função, comando registrado e confirmação. Teste Escape, clique fora, troca de aba e ocultação durante overlays.
7. Execute examples/help-accessibility.lua: descrição longa em tela pequena, preferência global, tooltip com descrição oculta, badge/toque, .2 s padrão, Tab/Shift+Tab/Enter/Espaço e texto em .8/1/1.4.
8. Crie dois perfis e exclua um pela UI. Cancele/confirme, confira lista e arquivo/índice; sem delfile/Delete, a indisponibilidade deve ser explícita. Excluir AutoSave não deve recriar o arquivo.

A suíte Lua 5.4 não reproduz a coleta de proxies nativos de Instance; o teste confirma ownership forte e registro persistente, com comportamento explicado pela documentação Roblox. O simulador também não comprova clip/hover/rolagem/seleção no renderizador real. **Todos os novos componentes/ferramentas foram implementados e testados localmente; a validação no cliente Roblox permanece pendente.**


## Conferência adicional da 1.8

1. Execute `examples/themes-gallery.lua` com o raw da 1.8. Teste Hacker, Dracula, Nord, Sakura, Ocean e Amber. Alterne com o dropdown e com Próximo tema, observando os mesmos cards, gráficos, console e tabela.
2. Selecione cada tema em Configurações, salve um perfil, troque a paleta e carregue o perfil. Confira também os perfis da 1.7.
3. No Theme Studio, duplique cada paleta nova, edite a cópia e restaure. Confira que a paleta oficial permanece preservada.
4. Teste o slider de progresso em 0/25/50/75/100 e confira percentuais sobre preenchimento e vazio, legendas, escalas e avisos.
5. As prévias de `contrast-themes.png` e `themes-new.png` são composições das cores dos widgets no simulador; não substituem esta conferência nativa.


## Regressões da 1.9

- Dez testes de navegação: eventos Activated reais, caminho touch, Enter com foco no campo da palette, alvo de aba após remoção, controles removidos/ocultos/desabilitados, comandos confirmados e falhas, fechar/reabrir, salvar/descartar/cancelar, recursos e scroll/foco com escala.
- Dezenove testes do hub: opcionalidade, catálogo vazio, PlaceId/UniverseId, nenhuma ação na detecção, configuração/CRUD inválidos atômicos, pesquisa/case/sort, perfis silenciosos, URI/cache/falha/retry, limites de pool/cache/concurrency, Play registrado, exclusão mútua, capacidades/confirm/cancelamento, erro real, teleportes solicitados/negados/assíncronos/timeout/adapter, teclado e recriação com o mesmo ID, repintura dos temas.
- Dois testes de distribuição: loader HTTP completo sem funções de arquivo do executor e rejeição de capacidades ausentes/versão antiga. Os testes anteriores de rede/compilação/inicialização continuam.
- O exemplo do prompt é compilado/executado separadamente com a fonte efetivamente publicada; o validator estático confere commit, versão, caminho, APIs, ordem e ausência de arquivo local obrigatório.

A fonte do raw e o Git tree são verificados na publicação. Sinais, serviços, imagens e teleportes dos testes são simulados; isso não confirma um cliente Roblox real. A suíte não renderiza GUI nem realiza teleportes reais.

## Conferência nativa da 1.9

1. Execute remote-loader.lua pelo raw confirmado, sem RetroBox.lua no workspace do executor. Teste HTTP/loadstring ausentes e erros de rede separadamente.
2. Na palette, selecione por mouse/toque/Enter, inclusive campos fora do viewport e seções recolhidas. Confira foco, destaque e scroll nas escalas .75/1/1.5. Navegação não deve disparar callbacks.
3. Abra o Theme Studio, duplique/edite, feche salvando/descartando/cancelando e reabra. Confira retorno à aba e ausência de tabs/objetos duplicados.
4. Execute script-hub.lua. Confira imagens com e sem UniverseId, fallback em assets negados, busca, teclado, favoritos, perfis, ocultar/reabrir e todos os temas.
5. Para testar teleporte, cadastre destinos reais e permitidos; confirme manualmente. Confira TeleportInitFailed e o adapter da experiência. O método cliente legado pode ser rejeitado, e TeleportAsync exige servidor. Não use os registros vazios de demonstração como destinos reais.


## Atualização 2.0.0

A suíte atual possui 256 testes de lógica (incluindo 24 exemplos) e 2 testes de pipeline em Python. Execute `python3 tests/run_headless.py`, `python3 tests/test_release_pipeline.py` e os builders/verifier conforme [AUTO-UPDATE.md](AUTO-UPDATE.md). O relatório [RELEASE-2.0.md](RELEASE-2.0.md) separa evidência de lógica/propriedades da conferência visual real.

No executor, conferir: bootstrap/canais publicados; thumbnail em janela grande/pequena/toque/TextScale; listas com 0/1/3/20 registros; um botão de execução; confirmação de teleporte; falha/timeout; consulta/catalog update sem execução ou perda de perfis; ausência de conexões duplicadas após reexecutar. Não usar o resultado do double como screenshot/renderização nativa.


## Validação da 2.1.0

336/336 testes headless, incluindo os 29 exemplos oficiais; 2/2 testes Python de distribuição. Novas regressões: 20 de PixelIcon, 25 de metadata, 8 de profiler, 8 de snapshots, 3 do helper e 16 da operação cancelável. Testes privados: seis loaders atuais do GitHub, o hub atual com sete jogos e o exemplo principal do prompt. Dez manifestos conferidos com hashlib. Releases anteriores e bootstrap preservados byte a byte. Renderização nativa e execução específica dos jogos continuam sem validação em cliente Roblox. Detalhes e arquivos em [RELEASE-2.1.md](RELEASE-2.1.md).

## 2.9.0 — Diagnóstico e Novidades

34 novas regressões em tests/feedback-diagnostics-news.lua cobrem anexo explícito, filtragem e seleção, permissão negada, captura visível, encerramento, redação, Unicode/limites Discord, cópia, rascunhos e perfis; também histórico oficial, feeds isolados, seleção inicial de abas, PT/EN, marcadores de leitura, importação atômica e destruição/recriação da área Novidades. As suites anteriores e o Designer continuam no CI. Transporte usa respostas controladas; nenhuma credencial real é publicada ou mensagem enviada. Esta sessão não tem ambiente de execução local: resultados efetivos são os checks da revisão no GitHub. Não houve inspeção visual no Roblox.
