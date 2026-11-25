-- Idioma da página inicial, escolhido pelo gestor.
-- Corre no SQL Editor do Supabase.
alter table public.site_settings
  add column if not exists idioma text not null default 'pt';

alter table public.site_settings drop constraint if exists site_settings_idioma_check;
alter table public.site_settings
  add constraint site_settings_idioma_check check (idioma in ('pt','en','es','fr'));
