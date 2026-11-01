# RetroBox 2.12.0 — Nova tela de boot

## Comportamento

A tela de inicialização era criada no `CreateWindow` e finalizada logo no frame seguinte (`task.defer`), então sumia antes de ser vista. A 2.12 troca o padrão por uma [tela de boot](BOOT-SCREEN.md) estilo terminal retrô, com duração de 2 s: emblema pixel que cresce, título digitado, log com `[ OK ]`, barra em blocos com percentual, cursor piscando, varredura CRT e saída que fecha a tela como um monitor antigo, revelando a janela.

Clique, Enter, Espaço ou Esc pulam a sequência. `Duration`, `Title`, `Subtitle`, `Message`, `Steps`, `Skippable` e `OnComplete` personalizam o boot; `window:ShowBootScreen` o reproduz sob demanda. O script nunca espera pela animação.

Compatibilidade: `LoadingScreen=false` continua desligando; `LoadingScreen={Style="Card"}` mantém o cartão anterior sem atraso; com Reduced Motion e sem pedido explícito não há boot, e um pedido explícito mostra uma versão estática curta. `ShowLoading` não mudou.

## Imagens da documentação

As ilustrações mostravam versões antigas (1.9.0/1.9.2). O novo `tools/build_docs_images.py` regenera `visual-concept.png`, `dashboard-concept.png`, `pixel-icons.png`, `contrast-themes.png` e `themes-new.png` com a versão atual e cria `boot-screen.png` e `refined-controls.png`. `pixel-icons-new.png` continua como registro histórico dos ícones da 1.9.1.

## Arquivos e distribuição

- `src/BootScreen.lua` (bloco `RETRO212 BOOT SCREEN`) e integração em `src/Appearance.lua`.
- `tests/boot-screen.lua`, `examples/boot-screen.lua`; o teste de inicialização em `tests/appearance.lua` passa a descrever o novo contrato (boot por padrão, `Card` imediato).
- Release imutável `dist/releases/2.12.0`, aliases Stable/Preview, entrada oficial em Novidades.
- Documentação, imagens e prompt integral `docs/Prompt-RetroBox-IA-v2.12.0.md`.

API 2 e bootstrap permanente preservados. Consumidores Stable/Preview recebem o boot ao executar novamente.

## Verificação

[Validação](VALIDATION.md). Tempo, tweens e geometria são simulados; não há renderer Roblox neste ambiente.
