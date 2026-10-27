# RetroBox 2.9.0 — Novidades e relatos com diagnóstico

- Novidades em todas as janelas, com histórico oficial da RetroBox separado dos updates opcionais do consumidor.
- Conteúdo oficial privado ao módulo; somente APIs de leitura por cópia. Feed do script validado, sem código, callbacks ou downloads.
- Indicação de não lidas, PT/EN, corpo com quebra de linhas e altura automática, conteúdo criado sob demanda e marcadores de leitura em perfis.
- Central de Ideias com diagnóstico opcional: erro colado, código/tag, reprodução, registros marcados, prévia e cópia.
- Importação explícita de erros/avisos disponíveis e captura de novos erros somente quando habilitada e a tela está visível. Fallback manual quando LogService não está disponível.
- Redação de padrões reconhecidos de credenciais, limites e chunks Unicode dos embeds, envio só por ação explícita, rascunho preservado e recursos liberados.
- Histórico de releases e API 2 preservados. Webhook real do consumidor permanece fora do repositório.

[Novidades](NEWS.md) · [Central de Ideias](FEEDBACK-HUB.md) · [Validação](VALIDATION.md)

As notas oficiais refletem a versão carregada e mudam na próxima execução pelo bootstrap stable. Os testes de transporte são simulados e não enviam mensagens a um webhook real. CI cobre a lógica e o Designer; a apresentação no cliente Roblox precisa de validação no executor.
