-- ============================================================
-- CATÁLOGO DA FARMÁCIA — corre no SQL Editor do Supabase
-- Categorias: 'medicamentos', 'higiene', 'vitaminas'.
-- Os preços são EXEMPLOS: ajusta-os e confirma o stock real.
-- Só venda livre; para medicamentos com receita usa requer_receita = true.
-- Corre depois do migration-7.
-- ============================================================

-- 1) Desativa o que já existia (não apaga, para não partir encomendas antigas)
update public.products set ativo = false;

-- 2) Medicamentos
insert into public.products (nome, descricao, preco, categoria, stock, ativo, requer_receita) values
('Paracetamol 500 mg',        'Analgésico e antipirético · caixa com 20 comprimidos',      1500, 'medicamentos', 200, true, false),
('Ibuprofeno 400 mg',         'Anti-inflamatório e analgésico · caixa com 20 comprimidos', 2200, 'medicamentos', 150, true, false),
('Xarope para a Tosse',       'Alívio da tosse seca e irritativa · frasco 150 ml',         3500, 'medicamentos', 80,  true, false),
('Soro Fisiológico',          'Limpeza nasal e ocular · 20 ampolas',                       2500, 'medicamentos', 100, true, false),
('Antiácido Mastigável',      'Alívio da azia e má digestão · 24 comprimidos',             2800, 'medicamentos', 90,  true, false),
('Sais de Reidratação Oral',  'Reposição de líquidos e sais · 6 saquetas',                 3000, 'medicamentos', 100, true, false),
('Antibiótico (com receita)', 'Dispensa apenas mediante receita médica válida',            5000, 'medicamentos', 60,  true, true);

-- 3) Higiene e cuidado pessoal
insert into public.products (nome, descricao, preco, categoria, stock, ativo, requer_receita) values
('Álcool Gel 250 ml',         'Desinfetante para as mãos',                                 1800, 'higiene', 150, true, false),
('Pensos Rápidos',            'Caixa com 40 unidades',                                     1500, 'higiene', 120, true, false),
('Máscaras Cirúrgicas',       'Caixa com 50 unidades',                                     3500, 'higiene', 100, true, false),
('Termómetro Digital',        'Leitura rápida',                                            4500, 'higiene', 40,  true, false),
('Protetor Solar FPS 50',     'Proteção alta · 100 ml',                                    6500, 'higiene', 60,  true, false),
('Pasta de Dentes',           'Proteção anticáries · 75 ml',                               1600, 'higiene', 120, true, false);

-- 4) Vitaminas e suplementos
insert into public.products (nome, descricao, preco, categoria, stock, ativo, requer_receita) values
('Vitamina C 1000 mg',        'Reforço do sistema imunitário · 30 comprimidos efervescentes', 4000, 'vitaminas', 100, true, false),
('Multivitamínico',           'Complexo de vitaminas e minerais · 60 cápsulas',            6000, 'vitaminas', 80,  true, false),
('Ómega 3',                   'Saúde cardiovascular · 60 cápsulas',                        7500, 'vitaminas', 60,  true, false),
('Vitamina D3',               'Saúde dos ossos · 60 cápsulas',                             5500, 'vitaminas', 70,  true, false),
('Ferro + Ácido Fólico',      'Suplemento para anemia ligeira · 30 comprimidos',           3800, 'vitaminas', 70,  true, false);

-- 5) Ordem no catálogo
update public.products p set ordem = sub.rn
from (select id, row_number() over (partition by categoria order by nome) as rn
      from public.products where ativo = true) sub
where p.id = sub.id;

-- Confirmação: 7 medicamentos + 6 higiene + 5 vitaminas = 18 linhas ativas
select categoria, count(*) from public.products where ativo = true group by categoria;
