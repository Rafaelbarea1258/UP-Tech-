# UpTECH — Sistema de Gestão da Loja

Sistema completo para a loja de celular e computador **UpTECH**, com vendas (PDV), assistência técnica (ordens de serviço), estoque, clientes, financeiro, relatórios e usuários — mesmo padrão técnico usado nos outros sistemas do Rafael (HTML/JS + Supabase, hospedado no Netlify).

## Módulos

- **Dashboard** — logo no topo, uma lista de demandas do dia a dia (ex: "Formatar notebook do cliente João", "Trocar tela do iPhone da Maria"): adicione quantas quiser, e ao concluir clique na bolinha ao lado para marcar como feita — ela some da lista na hora. Abaixo, vendas do dia, OS em aberto, alertas de estoque baixo, faturamento do mês.
- **Vendas (PDV)** — busca de produto, carrinho, seleção de cliente com busca, desconto, forma de pagamento, baixa automática no estoque.
- **Orçamentos** — monte uma proposta de venda (produtos + desconto + validade) sem mexer no estoque nem no financeiro; dá para marcar como aprovado/recusado, copiar um resumo para enviar por WhatsApp, exportar um PDF, e converter em venda de verdade quando o cliente aceitar.
- **Ordens de Serviço** — quadro por status (aguardando diagnóstico → aguardando aprovação → aguardando peça → em andamento → concluído → entregue), peças usadas com baixa de estoque, registro automático do pagamento no financeiro ao entregar.
- **Calculadora de preço** — dentro de uma OS, uma calculadora sugere o valor do orçamento a partir do custo da peça (custo × multiplicador + taxa da maquininha + frete do moto boy) — veja "Sobre a calculadora de preço" mais abaixo.
- **Link do orçamento para o cliente** — tanto em Orçamentos quanto em Ordens de Serviço, o botão "Copiar link para o cliente" gera um link público (sem necessidade de login) onde o cliente vê o orçamento e pode aprovar ou recusar direto pelo celular — ótimo para enviar por WhatsApp.
- **Estoque** — celulares, computadores, acessórios e peças, com alerta de estoque mínimo.
- **Clientes** — cadastro e histórico de compras/OS.
- **Financeiro** — lançamentos manuais (entradas/saídas), gráfico dos últimos 6 meses, saldo do mês.
- **Relatórios** — faturamento, ticket médio, vendas por dia, produtos mais vendidos.
- **Usuários** — login da equipe (admin, vendedor, técnico) — somente administradores acessam esta aba.

## Como colocar no ar

### 1. Banco de dados (Supabase)
1. Crie um projeto no [supabase.com](https://supabase.com) (ou use um já existente).
2. Abra **SQL Editor** → cole o conteúdo do arquivo `schema.sql` → clique em **Run**.
3. Em **Project Settings → API**, copie a **Project URL** e a chave **anon public**.
4. Substitua `SUPABASE_URL_AQUI` e `SUPABASE_ANON_KEY_AQUI` pela Project URL e pela chave **anon public** em **dois arquivos**:
   - `index.html` (o sistema da loja)
   - `orcamento-cliente.html` (a página pública que os clientes veem ao clicar no link do orçamento)

   Use os mesmos valores nos dois arquivos.

### 2. Publicação (Netlify)
1. Em [app.netlify.com](https://app.netlify.com), arraste a **pasta inteira** (com `index.html`, `orcamento-cliente.html` e os demais arquivos, já com as chaves preenchidas) em **Sites → Add new site → Deploy manually**, ou conecte um repositório.
2. Pronto — o link gerado é o endereço do sistema da loja. A página pública de orçamentos fica automaticamente em `seu-link.netlify.app/orcamento-cliente.html` (o botão "Copiar link para o cliente" já monta esse endereço sozinho).

### 3. Primeiro acesso
- Usuário: `admin`
- Senha: `uptech123`

**Troque essa senha assim que possível**, pela aba **Usuários** (menu lateral, visível só para administradores).

## Observações importantes

- Os dados ficam no Supabase, então todos os funcionários (em qualquer computador) veem as mesmas vendas, estoque e OS em tempo real.
- O controle de quem pode ver a aba **Usuários** é feito pelo cargo (`admin`, `vendedor`, `tecnico`) definido no cadastro de cada usuário.
- Toda venda no PDV e toda entrega de OS com valor gera automaticamente um lançamento no **Financeiro**.
