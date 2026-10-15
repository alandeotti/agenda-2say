-- Avisos de card com responsável = Alan, lidos pelo hook do Claude no vault da Movva.
create table public.avisos (
  id bigint generated always as identity primary key,
  marca_id text not null,
  semana text, dia text, card_id text, tema text, status text,
  por text,
  criado_em timestamptz not null default now(),
  lido boolean not null default false
);
alter table public.avisos enable row level security;
-- sem policy e sem grant: só as funções abaixo encostam nela

create or replace function public.avisa_responsavel()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.avisos (marca_id, semana, dia, card_id, tema, status, por)
  select new.marca_id, s.key, d.key, c->>'id', c->>'tema', c->>'status', auth.jwt() ->> 'email'
  from jsonb_each(coalesce(new.dados->'semanas','{}')) s,
       jsonb_each(coalesce(s.value->'dias','{}')) d,
       jsonb_array_elements(d.value) c
  where lower(trim(c->>'resp')) = 'alan'
    and coalesce(auth.jwt() ->> 'email','') <> 'eduardodeotti3@gmail.com'
    and not exists (
      select 1
      from jsonb_each(coalesce(old.dados->'semanas','{}')) s2,
           jsonb_each(coalesce(s2.value->'dias','{}')) d2,
           jsonb_array_elements(d2.value) c2
      where tg_op = 'UPDATE' and c2->>'id' = c->>'id' and lower(trim(c2->>'resp')) = 'alan');
  return null;
end $$;

create trigger tg_avisa_responsavel after insert or update on public.sistemas
for each row execute function public.avisa_responsavel();

-- leitura pelo hook do Claude: devolve os não lidos e marca como lidos
create or replace function public.avisos_novos(chave text)
returns setof public.avisos language plpgsql security definer set search_path = '' as $$
begin
  if encode(sha256(convert_to(chave,'UTF8')),'hex') <> 'b35f333e9a9b1dd70250a0f1b4495b2a8d323b6b73c2a6e0b19ec0e222a34d01' then
    raise exception 'chave inválida';
  end if;
  return query update public.avisos set lido = true where not lido returning *;
end $$;
revoke all on function public.avisos_novos(text) from public;
grant execute on function public.avisos_novos(text) to anon, authenticated;
revoke all on function public.avisa_responsavel() from public, anon, authenticated;
