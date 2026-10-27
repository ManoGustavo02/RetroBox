# RetroBox 2.8.0 — Central de Ideias

Novo Feedback Hub opt-in, independente do catálogo de scripts. Cria uma janela própria ou uma guia em uma janela existente; não adiciona interfaces, telemetria ou envios em scripts que não o utilizam.

- Categorias de pedido de script, sugestão, feedback e relato de problema, com PT/EN automáticos e troca de idioma sem perder o texto.
- Jogo atual ou outro jogo por ID/link oficial; nome consultado por API, prévia dos dados e avatar quando disponível.
- Envio explícito para webhook Discord configurado pelo consumidor, ou transporte customizado para um relay próprio. Não há webhook real, teste automático de envio nem backend embutido.
- Mensagem, jogo/link/PlaceId, nome/@ e imagem disponível são os dados do embed; sem coleta adicional de identificadores do dispositivo ou sessão.
- Confirmação por resposta do Discord, cooldown, duplicatas, tratamento de 429, falha/timeout e reenvio explícito quando a entrega é incerta.
- Rascunhos preservados nas falhas e durante edição concorrente. Configurações não exportam texto, identidade ou credenciais.
- Recursos gerenciados, invalidação de metadados antigos e desconexão das respostas HTTP tardias da interface destruída.

[Guia completo e contrato](FEEDBACK-HUB.md) · [Exemplo executável](../examples/feedback-hub.lua) · [Validação](VALIDATION.md)

O token no cliente é extraível; um relay é a opção para protegê-lo. Cooldown local não autentica usuários nem substitui limitação no servidor. O texto digitado não passa por tradução automática. Avatar HTTPS é opcional e não bloqueia texto.

Arquivos principais: `src/FeedbackHub.lua`, inclusão no builder/standalone, `tests/feedback-hub.lua`, exemplo e documentação. API 2, bootstrap, estrutura histórica, Script Hub, arquivos do Designer e releases anteriores permanecem preservados. Os testes usam transporte e engine simulados; nenhuma mensagem é enviada a um Discord real, e não houve inspeção visual no cliente Roblox.
