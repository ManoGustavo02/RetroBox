# Segurança e relato de problemas

## Escopo

Relatos relevantes incluem execução inesperada, falha de validação de origem/caminho/manifesto, importação indevida de configurações, vazamento de dados, recursos não liberados e diferenças entre o código publicado e o artefato distribuído.

A versão atual deste pacote é 2.4.0/API 2, distribuída pela conta ManoGustavo02. Artefatos históricos ficam preservados; correções de runtime são entregues em uma versão nova.

## Como reportar

Se a aba Security do repositório oferecer **Report a vulnerability**, use esse canal privado. Sua disponibilidade depende de o mantenedor habilitá-lo após criar o repositório. Se não estiver disponível, abra uma issue solicitando um canal privado, com um resumo sem credenciais, dados pessoais ou detalhes suficientes para explorar uma falha contra terceiros. Relatos de uso indevido podem ser abertos como issue com os links públicos necessários e uma descrição objetiva.

Informe versão/build, componente afetado, ambiente, impacto e uma reprodução mínima em ambiente autorizado. Logs devem ter tokens, cookies e informações pessoais removidos. Não há SLA de resposta declarado neste projeto.

## Modelo de confiança

- O bootstrap baixa e compila código da origem HTTPS configurada. Essa origem precisa ser confiável para quem executa o código.
- Manifestos validam compatibilidade, canal, versão, caminho relativo, tamanho e SHA-256 antes de carregar o artefato. O SHA-256 confere os bytes; não é uma assinatura independente de quem controla a origem.
- Um comprometimento do publicador pode afetar código e manifesto juntos. Pinning, revisão de releases e cópias verificadas ajudam a controlar atualizações; não substituem proteção da conta.
- Catálogos JSON são declarativos. Os callbacks executáveis são registrados pelo desenvolvedor no código do consumidor.
- Cancelamento de ações é cooperativo. Destruir a GUI não reverte efeitos externos de callbacks já executados.
- Nunca coloque tokens de publicação ou chaves de API em um script distribuído aos clientes.

## Processo do repositório

O workflow tem permissão de leitura, usa uma versão do checkout fixada por commit e não recebe segredos de publicação. PRs executam os testes em runner hospedado, sem publicação automática. A proteção de branch, 2FA e os canais privados de relato precisam ser configurados na conta/repositório após a criação; este pacote não os ativa remotamente.

Consulte [publicação responsável](docs/PUBLICATION.md), [auto update](RetroBox-UI-v1.1.0/retrobox-ui/docs/AUTO-UPDATE.md) e [validação](RetroBox-UI-v1.1.0/retrobox-ui/docs/VALIDATION.md).
