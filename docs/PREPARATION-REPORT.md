# Preparação e publicação · RetroBox 2.3.1

Conta/proprietário confirmado: **ManoGustavo02**, ID público 345044484. Repositório público: **ManoGustavo02/RetroBox**, branch **main**. A origem padrão do updater, o bootstrap e os guias/exemplos ativos foram migrados sem mudar a estrutura ou a API pública.

## Apresentação e arquivos

README bilíngue, banner original, badges locais, MIT preservada, guias de segurança/contribuição/suporte/publicação, formulário de bug, modelo de PR e workflow de validação. Descrição e topics preparados em REPOSITORY-SETUP.md; esses campos da interface do GitHub exigem configuração administrativa e não são alterados pelo envio dos arquivos.

## Validação local

395/395 testes da library, 34 exemplos, 34/34 testes do export do Hub, 3/3 exemplos do prompt e 2/2 testes da pipeline aprovados. Treze manifestos e dezoito arquivos históricos conferidos. Runtime: 606526 bytes, SHA-256 `cdf44090273caed178ba477fcb17abc408d535ee4402dbcf0459a1ead828c424`. As únicas diferenças no runtime são cabeçalho, versão e Root padrão. Nenhum script real de gameplay foi executado; a conferência do renderer Roblox continua necessária.

## Conferência remota

- Publicação em main no commit `a9b21a550ac379f3c0368cd3f5991a1016ff31d8`; árvore `f2906fc81628872f1b1d350e117efdeabd131b6b`, com os 252 arquivos conferidos contra a árvore local testada.
- Bootstrap, Stable, Preview, manifesto Pinned 2.3.1 e runtime baixados por HTTPS público sem login: HTTP 200 e bytes idênticos aos arquivos testados. O runtime tem o tamanho e SHA-256 registrados acima.
- O bootstrap baixado publicamente carregou os três canais e criou/destruiu o Hub nativo no tema Hacker: 3/3 verificações com engine simulada, sem arquivos do executor e sem erros de Parent bloqueado.
- O workflow hospedado [Validate RetroBox #1](https://github.com/ManoGustavo02/RetroBox/actions/runs/39348763850), associado ao commit de publicação, concluiu com **success**. O badge do README consulta o status real do workflow, sem status estático inventado.
- README, banner e badges conferidos na página pública do GitHub. Essa conferência é da apresentação do repositório, não do renderer Roblox.
- O campo lateral About e os topics continuam sem configuração. A conexão usada publica arquivos, mas não oferece edição desses campos administrativos. A descrição e os tópicos para copiar estão em [REPOSITORY-SETUP.md](REPOSITORY-SETUP.md). Não foi anunciado que esses campos, 2FA, proteção de branch ou relato privado de segurança tenham sido ativados.

## Conteúdo dos backups

O ZIP de entrega contém a árvore completa da library publicada, artefatos versionados, o prompt completo, o export separado do Hub e relatórios de verificação. Ele não restaura o histórico Git completo da conta anterior nem copia os repositórios dos sete scripts de gameplay. Os pins históricos foram preservados por bytes.
