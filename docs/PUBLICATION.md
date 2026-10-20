# Publicação da RetroBox

RetroBox 2.3.1/API 2 usa o repositório público **ManoGustavo02/RetroBox**, confirmado pelo proprietário. A integração conectada tem permissão de escrita. Os resultados de conferência remota ficam no relatório de preparação; não se deve confundir testes locais com execução hospedada de CI.

## Apresentação

README em português e inglês, banner original, badges locais de versão/API/temas/ícones/licença, licença MIT preservada, SECURITY, CONTRIBUTING, SUPPORT, formulário de bug, modelo de PR e workflow de validação. Os valores da descrição e dos topics estão em [REPOSITORY-SETUP.md](REPOSITORY-SETUP.md).

A library oferece interfaces, estado e ciclo de vida em Luau para executor cliente compatível. A documentação descreve esse funcionamento, a finalidade didática e o uso autorizado. O aviso educativo esclarece a finalidade do projeto; não substitui as regras das plataformas nem garante disponibilidade da conta.

## Origem e artefatos

O Root padrão, os bootstraps, os guias e os exemplos ativos usam a conta nova. A migração gera a release **2.3.1**, preservando os bytes dos pins 2.0.0, 2.1.0, 2.2.0 e 2.3.0. A pasta `RetroBox-UI-v1.1.0/retrobox-ui/` e `dist/` mantêm seus caminhos. Consulte [RELEASE-2.3.1.md](../RetroBox-UI-v1.1.0/retrobox-ui/docs/RELEASE-2.3.1.md).

Novas publicações devem incluir todos os arquivos em um commit atômico ou enviar o artefato imutável antes de promover os canais. Confira Stable, Preview e Pinned pelos manifestos publicados, compare tamanho/SHA-256 e carregue o bootstrap sem login.

Os scripts que ainda usam a URL da conta anterior precisam de atualização dessa URL. Não há redirecionamento automático entre contas GitHub. O bootstrap da conta nova resolve as próximas atualizações compatíveis na reexecução; não substitui janelas abertas.

## Validação e CI

O workflow verifica documentação, assets, módulos incorporados, distribuição, origem, imutabilidade e testes de lógica. Usa `contents: read`, não recebe segredos de publicação e não faz deploy. O checkout está fixado no commit `3d3c42e5aac5ba805825da76410c181273ba90b1`, verificado na preparação anterior como a release oficial v7.0.1.

Os resultados locais estão em [VALIDATION.md](../RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md). GitHub Actions e raw públicos devem ser avaliados por seus resultados reais. Lógica e geometria simuladas não comprovam renderização nativa Roblox.

Configurações como 2FA, recuperação da conta, proteção de branch e relatos privados de segurança são administradas no GitHub. O pacote não afirma que estejam ativadas. [SECURITY.md](../SECURITY.md) detalha o modelo de confiança e os canais de relato.
