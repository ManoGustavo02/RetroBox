# RetroBox 2.5.0 — Designer, idiomas e ferramentas para desenvolvedores

O [Designer HTML](../../../designer/README.md) monta a GUI, conecta eventos e valores por blocos, testa uma prévia e exporta projeto JSON e Luau. O HTML gerado é autossuficiente: não exige instalação ou servidor. O repositório mantém fontes, catálogo compartilhado, assets extraídos da library, exemplos de projeto, exportações de referência e testes no navegador.

## Novas APIs nativas

- Localização automática pelo idioma do Roblox, PT/EN internos, preferência por janela/perfil, dicionários próprios, parâmetros e integração explícita com um provider de tradução.
- Form com rascunho, validação, Aplicar/Cancelar e persistência apenas dos dados confirmados.
- RegisterComponent/AddComponent para controles reutilizáveis, IDs por instância, State agregado e limpeza dos recursos.
- CardGrid responsivo com pesquisa, filtros, badges e pool de até 64 cards para até 5000 itens.
- CreateFlowGraph com 22 tipos de nó, portas tipadas, detecção de ciclos/realimentação, bindings silenciosos e ações explícitas.
- DiagnoseCatalog/OpenCatalogDiagnostics para inspecionar fontes e compilação sem executar o código baixado.

Veja [DEVELOPMENT-TOOLS.md](DEVELOPMENT-TOOLS.md) para contratos, limites e exemplos. Tradução de textos arbitrários exige dicionários ou um serviço do desenvolvedor; não existe API/chave paga embutida. O idioma configurado não identifica nacionalidade.

## Compatibilidade e lifecycle

API 2, sequência Window → Tab → Section → controles, bootstrap permanente e pasta histórica preservados. Nenhum catálogo de jogos de consumidor é reescrito por esta atualização. Os metadados por PlaceId, universais e os links Raw do Pastefy continuam disponíveis. Artefatos publicados até 2.4.0 permanecem imutáveis.

A localização mantém registros de texto por janela e os libera em Destroying. Pares internos de uma janela não alteram textos de outra. Formulários e componentes liberam grupos, filhos, States e conexões; grafos cancelam ações e removem referências/inscrições; CardGrid reutiliza os ícones com o lifecycle já corrigido na 2.1.0.

## Verificação

O relatório [VALIDATION.md](VALIDATION.md) registra a suíte nativa, exemplos, exportações reais, testes Node e Chromium, distribuição e limites. A conferência de publicação fica no [relatório do repositório](../../../docs/PREPARATION-REPORT.md). A prévia web e o double de engine não substituem a renderização no Roblox; imagens/modelos 3D, gestos e fontes devem ser conferidos no cliente final.
