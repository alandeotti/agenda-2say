-- Responsável obrigatório: lista de quem tem acesso à marca + aviso pro Alan reconhecendo o e-mail.
-- Só cria/troca funções e uma coluna opcional. Não apaga nem altera dado nenhum.
-- Rodar inteiro no SQL Editor do Supabase.

-- 1. Nome curto opcional pra aparecer no card no lugar do e-mail (vazio = parte antes do @).
alter table public.membros add column if not exists nome text;

-- 2. Lista de quem tem acesso à marca. O RLS só deixa cada um ler a própria linha
--    de membros, então isto roda como dono, mas só responde pra quem é da marca.
create or replace function public.membros_da_marca(p_marca text)
returns table(email text, nome text) language sql stable security definer set search_path = '' as $$
  select lower(m.email), coalesce(nullif(trim(max(m.nome)), ''), split_part(lower(m.email), '@', 1))
  from public.membros m
  where m.marca_id = p_marca
    and exists (select 1 from public.membros eu
                where eu.marca_id = p_marca and lower(eu.email) = lower(auth.jwt() ->> 'email'))
  group by lower(m.email)
  order by 2;
$$;
revoke all on function public.membros_da_marca(text) from public, anon;
grant execute on function public.membros_da_marca(text) to authenticated;

-- 3. Aviso pro Alan (_avisos.sql): agora reconhece 'Alan' (card antigo) e o e-mail dele.
create or replace function public.avisa_responsavel()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.avisos (marca_id, semana, dia, card_id, tema, status, por)
  select new.marca_id, s.key, d.key, c->>'id', c->>'tema', c->>'status', auth.jwt() ->> 'email'
  from jsonb_each(coalesce(new.dados->'semanas','{}')) s,
       jsonb_each(coalesce(s.value->'dias','{}')) d,
       jsonb_array_elements(d.value) c
  where lower(trim(c->>'resp')) in ('alan', 'eduardodeotti3@gmail.com')
    and coalesce(auth.jwt() ->> 'email','') <> 'eduardodeotti3@gmail.com'
    and not exists (
      select 1
      from jsonb_each(coalesce(old.dados->'semanas','{}')) s2,
           jsonb_each(coalesce(s2.value->'dias','{}')) d2,
           jsonb_array_elements(d2.value) c2
      where tg_op = 'UPDATE' and c2->>'id' = c->>'id'
        and lower(trim(c2->>'resp')) in ('alan', 'eduardodeotti3@gmail.com'));
  return null;
end $$;
