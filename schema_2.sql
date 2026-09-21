-- =========================================================
-- UpTECH — Schema do banco de dados (Supabase / PostgreSQL)
-- Sistema de gestão para loja de celulares e assistência técnica
-- =========================================================

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------
-- USUÁRIOS (login da equipe da loja)
-- ---------------------------------------------------------
create table if not exists usuarios (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  login text not null unique,
  senha text not null,
  cargo text not null default 'vendedor', -- admin, vendedor, tecnico
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------
-- CLIENTES
-- ---------------------------------------------------------
create table if not exists clientes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  telefone text,
  cpf_cnpj text,
  email text,
  endereco text,
  observacoes text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------
-- PRODUTOS / ESTOQUE (celulares, computadores, acessórios, peças)
-- ---------------------------------------------------------
create table if not exists produtos (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  categoria text not null default 'acessorio', -- celular, computador, acessorio, peca
  marca text,
  modelo text,
  cor text,
  imei text,
  codigo_barras text,
  custo numeric(12,2) not null default 0,
  preco_venda numeric(12,2) not null default 0,
  estoque_atual integer not null default 0,
  estoque_minimo integer not null default 1,
  fornecedor text,
  foto_url text,
  ativo boolean not null default true,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------
-- VENDAS (PDV)
-- ---------------------------------------------------------
create table if not exists vendas (
  id uuid primary key default gen_random_uuid(),
  numero serial,
  cliente_id uuid references clientes(id),
  usuario_id uuid references usuarios(id),
  forma_pagamento text not null default 'dinheiro',
  desconto numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  status text not null default 'concluida', -- concluida, cancelada
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists itens_venda (
  id uuid primary key default gen_random_uuid(),
  venda_id uuid references vendas(id) on delete cascade,
  produto_id uuid references produtos(id),
  produto_nome text,
  quantidade integer not null default 1,
  preco_unitario numeric(12,2) not null default 0,
  subtotal numeric(12,2) not null default 0
);

-- ---------------------------------------------------------
-- ORDENS DE SERVIÇO (assistência técnica)
-- ---------------------------------------------------------
create table if not exists ordens_servico (
  id uuid primary key default gen_random_uuid(),
  numero serial,
  cliente_id uuid references clientes(id),
  tecnico_id uuid references usuarios(id),
  tipo_aparelho text not null default 'celular', -- celular, computador, tablet, outro
  marca text,
  modelo text,
  imei text,
  senha_aparelho text,
  acessorios_entregues text,
  defeito_relatado text,
  diagnostico text,
  servico_realizado text,
  valor_orcamento numeric(12,2) not null default 0,
  valor_final numeric(12,2) not null default 0,
  status text not null default 'aguardando_diagnostico',
  -- aguardando_diagnostico, aguardando_aprovacao, aguardando_peca, em_andamento, concluido, entregue, cancelado
  garantia_dias integer not null default 90,
  data_entrada timestamptz not null default now(),
  data_previsao date,
  data_conclusao timestamptz,
  data_entrega timestamptz,
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists os_pecas (
  id uuid primary key default gen_random_uuid(),
  os_id uuid references ordens_servico(id) on delete cascade,
  produto_id uuid references produtos(id),
  produto_nome text,
  quantidade integer not null default 1,
  preco_unitario numeric(12,2) not null default 0
);

-- ---------------------------------------------------------
-- ORÇAMENTOS (propostas de venda, não afetam estoque/financeiro)
-- ---------------------------------------------------------
create table if not exists orcamentos (
  id uuid primary key default gen_random_uuid(),
  numero serial,
  cliente_id uuid references clientes(id),
  usuario_id uuid references usuarios(id),
  desconto numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  validade_dias integer not null default 7,
  status text not null default 'aberto', -- aberto, aprovado, recusado, expirado, convertido
  observacoes text,
  created_at timestamptz not null default now()
);

create table if not exists orcamento_itens (
  id uuid primary key default gen_random_uuid(),
  orcamento_id uuid references orcamentos(id) on delete cascade,
  produto_id uuid references produtos(id),
  produto_nome text,
  quantidade integer not null default 1,
  preco_unitario numeric(12,2) not null default 0,
  subtotal numeric(12,2) not null default 0
);

-- ---------------------------------------------------------
-- TAREFAS (demandas do dia a dia, tipo lista de afazeres)
-- ---------------------------------------------------------
create table if not exists tarefas (
  id uuid primary key default gen_random_uuid(),
  descricao text not null,
  usuario_id uuid references usuarios(id),
  concluida boolean not null default false,
  created_at timestamptz not null default now(),
  concluida_at timestamptz
);

-- ---------------------------------------------------------
-- FINANCEIRO (caixa, contas a pagar/receber)
-- ---------------------------------------------------------
create table if not exists financeiro_lancamentos (
  id uuid primary key default gen_random_uuid(),
  tipo text not null, -- entrada, saida
  categoria text,
  descricao text,
  valor numeric(12,2) not null default 0,
  forma_pagamento text,
  data date not null default current_date,
  status text not null default 'pago', -- pago, pendente
  venda_id uuid references vendas(id),
  os_id uuid references ordens_servico(id),
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------
-- Índices úteis
-- ---------------------------------------------------------
create index if not exists idx_produtos_categoria on produtos(categoria);
create index if not exists idx_vendas_created on vendas(created_at);
create index if not exists idx_os_status on ordens_servico(status);
create index if not exists idx_os_created on ordens_servico(created_at);
create index if not exists idx_financeiro_data on financeiro_lancamentos(data);
create index if not exists idx_orcamentos_status on orcamentos(status);
create index if not exists idx_tarefas_concluida on tarefas(concluida);

-- ---------------------------------------------------------
-- RLS: sistema interno da loja, acesso liberado via anon key
-- (o controle de acesso é feito pelo login da aplicação)
-- ---------------------------------------------------------
alter table usuarios enable row level security;
alter table clientes enable row level security;
alter table produtos enable row level security;
alter table vendas enable row level security;
alter table itens_venda enable row level security;
alter table ordens_servico enable row level security;
alter table os_pecas enable row level security;
alter table financeiro_lancamentos enable row level security;
alter table orcamentos enable row level security;
alter table orcamento_itens enable row level security;
alter table tarefas enable row level security;

drop policy if exists "acesso_total" on usuarios;
create policy "acesso_total" on usuarios for all using (true) with check (true);

drop policy if exists "acesso_total" on clientes;
create policy "acesso_total" on clientes for all using (true) with check (true);

drop policy if exists "acesso_total" on produtos;
create policy "acesso_total" on produtos for all using (true) with check (true);

drop policy if exists "acesso_total" on vendas;
create policy "acesso_total" on vendas for all using (true) with check (true);

drop policy if exists "acesso_total" on itens_venda;
create policy "acesso_total" on itens_venda for all using (true) with check (true);

drop policy if exists "acesso_total" on ordens_servico;
create policy "acesso_total" on ordens_servico for all using (true) with check (true);

drop policy if exists "acesso_total" on os_pecas;
create policy "acesso_total" on os_pecas for all using (true) with check (true);

drop policy if exists "acesso_total" on financeiro_lancamentos;
create policy "acesso_total" on financeiro_lancamentos for all using (true) with check (true);

drop policy if exists "acesso_total" on orcamentos;
create policy "acesso_total" on orcamentos for all using (true) with check (true);

drop policy if exists "acesso_total" on orcamento_itens;
create policy "acesso_total" on orcamento_itens for all using (true) with check (true);

drop policy if exists "acesso_total" on tarefas;
create policy "acesso_total" on tarefas for all using (true) with check (true);

-- ---------------------------------------------------------
-- Usuários iniciais da equipe
-- IMPORTANTE: troque essas senhas pela tela de Usuários assim que possível
-- ---------------------------------------------------------
insert into usuarios (nome, login, senha, cargo)
values
  ('Administrador', 'admin', 'uptech123', 'admin'),
  ('Rafael', 'Rafael', '145565', 'admin')
on conflict (login) do nothing;
