-- ============================================================
-- ATUALIZAÇÃO DA BASE DE DADOS — corre isto no SQL Editor do Supabase
-- (não apaga nada do que já tens, só adiciona o que falta)
-- ============================================================

-- 1. Opções de personalização por produto
--    (ponto da carne, extras com preço, molhos, etc.)
alter table public.products
  add column if not exists opcoes jsonb not null default '[]';

-- Exemplo de estrutura guardada em "opcoes":
-- [
--   {"nome":"Dosagem","tipo":"single","escolhas":[{"nome":"500 mg"},{"nome":"1 g","preco":300}]}
-- ]

-- 2. Configurações visuais do site (cores, logo, imagem de fundo)
--    Só existe UMA linha nesta tabela (id fixo = 1).
create table if not exists public.site_settings (
  id int primary key default 1,
  cor_laranja text not null default '#2E7D32',
  cor_laranja_clara text not null default '#66BB6A',
  logo_url text,
  hero_url text,
  constraint singleton check (id = 1)
);

insert into public.site_settings (id) values (1)
  on conflict (id) do nothing;

alter table public.site_settings enable row level security;

create policy "todos veem as configurações"
  on public.site_settings for select
  using (true);

create policy "só admin edita as configurações"
  on public.site_settings for update
  using (public.is_admin())
  with check (public.is_admin());
