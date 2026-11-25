-- ============================================================
-- FARMÁCIA — colunas e regras que o site e o painel usam
-- corre no SQL Editor do Supabase, depois do migration-6
-- (seguro correr mais de uma vez; não apaga dados)
-- ============================================================

-- 1) Produtos: receita médica (substitui "bebida alcoólica")
alter table public.products add column if not exists requer_receita boolean not null default false;

-- 2) Perfis: e-mail (o painel mostra-o na lista de utilizadores)
alter table public.profiles add column if not exists email text;

update public.profiles p set email = u.email
from auth.users u where u.id = p.id and p.email is null;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nome, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'nome', ''), new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

-- 3) Configurações do site: textos, contactos, redes, foto de destaque
alter table public.site_settings add column if not exists nome_site text not null default 'Farmácia Vida';
alter table public.site_settings add column if not exists slogan text not null default 'A sua saúde, o nosso cuidado';
alter table public.site_settings add column if not exists hero_descricao text;
alter table public.site_settings add column if not exists hero_foto_url text;
alter table public.site_settings add column if not exists rodape_texto text default '';
alter table public.site_settings add column if not exists contacto_telefone text;
alter table public.site_settings add column if not exists contacto_email text;
alter table public.site_settings add column if not exists contacto_whatsapp text;
alter table public.site_settings add column if not exists contacto_morada text;
alter table public.site_settings add column if not exists redes_instagram text;
alter table public.site_settings add column if not exists redes_facebook text;
alter table public.site_settings add column if not exists emailjs_ativo boolean not null default false;
alter table public.site_settings add column if not exists emailjs_service_id text;
alter table public.site_settings add column if not exists emailjs_template_id text;
alter table public.site_settings add column if not exists emailjs_public_key text;

-- cores verde farmácia
alter table public.site_settings alter column cor_laranja set default '#2E7D32';
alter table public.site_settings alter column cor_laranja_clara set default '#66BB6A';

-- 4) A equipa (admin, gestor, funcionário) vê perfis e itens das encomendas
drop policy if exists "clientes veem o próprio perfil" on public.profiles;
create policy "perfil próprio ou equipa"
  on public.profiles for select
  using (auth.uid() = id or public.is_staff());

drop policy if exists "vê itens das encomendas que pode ver" on public.order_items;
create policy "vê itens das encomendas que pode ver"
  on public.order_items for select
  using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and (o.cliente_id = auth.uid() or public.is_staff())
    )
  );

drop policy if exists "cliente vê as suas encomendas" on public.orders;
create policy "cliente ou equipa vê encomendas"
  on public.orders for select
  using (auth.uid() = cliente_id or public.is_staff());

drop policy if exists "todos veem produtos ativos" on public.products;
create policy "todos veem produtos ativos"
  on public.products for select
  using (ativo = true or public.is_staff());

-- 5) Armazenamento de imagens (logo, fotos de produtos) — bucket "imagens"
insert into storage.buckets (id, name, public)
values ('imagens', 'imagens', true)
on conflict (id) do nothing;

drop policy if exists "imagens públicas" on storage.objects;
create policy "imagens públicas"
  on storage.objects for select
  using (bucket_id = 'imagens');

drop policy if exists "equipa envia imagens" on storage.objects;
create policy "equipa envia imagens"
  on storage.objects for insert
  with check (bucket_id = 'imagens' and public.is_staff());

drop policy if exists "equipa altera imagens" on storage.objects;
create policy "equipa altera imagens"
  on storage.objects for update
  using (bucket_id = 'imagens' and public.is_staff());

drop policy if exists "equipa apaga imagens" on storage.objects;
create policy "equipa apaga imagens"
  on storage.objects for delete
  using (bucket_id = 'imagens' and public.is_staff());

-- 6) Remove a coluna antiga da hamburgueria, se existir
alter table public.products drop column if exists alcoolica;
