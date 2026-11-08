# LAURIGRAM — protótipo inicial

Este pacote contém:
- `index.html`: interface responsiva inicial em português, sem vídeos.
- `supabase_schema.sql`: esquema inicial de dados e RLS para revisão.

## O que já funciona nesta demonstração
- Navegação entre feed, explorar, páginas, mensagens, notificações, selo azul, promoção e conta.
- Criar publicações temporárias no navegador.
- Criar cartões de páginas temporários no navegador.
- Pedidos de pagamento apenas demonstrativos, com referência fictícia.

## O que ainda NÃO está ligado
Autenticação real, fotografias armazenadas, comentários/likes persistentes, mensagens, notificações,
traduções completas, checkout Express, confirmação de pagamentos, verificação real, campanhas e
painel administrativo protegido. Não recolhe nem confirma dinheiro nesta versão.

## Próximos passos
1. Criar/usar um projeto Supabase.
2. Rever o SQL antes de executar no SQL Editor.
3. Configurar Supabase Auth e políticas RLS adicionais.
4. Criar Edge Functions para criar referências e para aprovar/rejeitar pagamentos.
5. Configurar storage privado/público para fotografias e validar uploads.
6. Proteger administração no servidor; nunca confiar em botões escondidos ou roles editáveis pelo utilizador.
7. Publicar o `index.html` no GitHub Pages/Netlify para pré-visualização.

O número de pagamento só deve aparecer num checkout autenticado, e a confirmação deve ser feita
após verificar a entrada real na conta Express. O número de Express não está embutido neste pacote.
