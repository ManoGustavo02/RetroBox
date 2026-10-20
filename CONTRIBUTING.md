# Contribuir com a RetroBox

Descreva o problema concreto e a mudança de comportamento. Mantenha IDs, API pública, perfis, temas e os caminhos históricos compatíveis. Os exemplos devem demonstrar operações locais ou integrações para as quais o desenvolvedor tenha autorização.

## Desenvolvimento

O fonte está em `RetroBox-UI-v1.1.0/retrobox-ui`. O standalone incorpora os módulos de src/; edite o módulo correspondente quando houver um bloco gerado. Use Python 3 e liblua 5.4 para os testes de lógica.

Na raiz do repositório:

```sh
python3 tools/verify_repository.py
cd RetroBox-UI-v1.1.0/retrobox-ui
python3 tools/build_distribution.py --embed-only
python3 tests/run_headless.py
python3 tests/test_release_pipeline.py
python3 tools/verify_distribution.py
python3 tools/verify_origin_migration.py
```

`--embed-only` precisa deixar o fonte/distribuição já revisados consistentes. Não edite uma release publicada para alterar comportamento; aumente a versão e gere um artefato novo conforme o guia de distribuição.

## PRs e relatos

- Use uma reprodução mínima e explique o resultado esperado/observado.
- Para mudanças de runtime/lifecycle, inclua regressões que reproduzam a falha.
- Para documentação e apresentação, confira links, arquivos e o resultado visual relevante.
- Identifique se a validação foi lógica, geometria simulada ou execução real no cliente. Não apresente screenshots de conceito como prova de renderização.
- Preserve a licença MIT e a atribuição. Confira direitos de imagens, ícones e trechos de terceiros.
- Revise diffs antes de publicar; não inclua tokens, cookies, dados pessoais ou arquivos de ambiente locais.

Os testes não executam os scripts de gameplay reais de projetos consumidores. O código executável de exemplos deve ser legível e revisável. Vulnerabilidades seguem [SECURITY.md](SECURITY.md).
