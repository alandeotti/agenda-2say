-- Anexos das ideias/cards (roteiro em .doc, .docx, .txt; até 10 MB) no Storage.
-- Bucket PRIVADO 'anexos', caminho marca_id/ideia_ou_card_id/arquivo.
-- Editor da marca envia e apaga; editor e leitor baixam (signed URL); quem não é da marca não vê nada.
-- Só cria: não apaga nem altera dado nenhum. Pode rodar de novo sem erro. Rodar inteiro no SQL Editor.

-- 1. Bucket. O limite e os tipos valem também no servidor, não só na página.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('anexos', 'anexos', false, 10485760, array[
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'text/plain'])
on conflict (id) do nothing;

-- 2. Policies. A 1ª pasta do caminho é a marca; o papel vem de membros pelo e-mail do login.
do $$
begin
  if not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname = 'anexos_baixar') then
    create policy anexos_baixar on storage.objects for select to authenticated
    using (bucket_id = 'anexos' and exists (
      select 1 from public.membros m
      where m.marca_id = (storage.foldername(name))[1]
        and lower(m.email) = lower(auth.jwt() ->> 'email')));
  end if;

  if not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname = 'anexos_enviar') then
    create policy anexos_enviar on storage.objects for insert to authenticated
    with check (bucket_id = 'anexos' and exists (
      select 1 from public.membros m
      where m.marca_id = (storage.foldername(name))[1]
        and lower(m.email) = lower(auth.jwt() ->> 'email')
        and m.papel = 'editor'));
  end if;

  if not exists (select 1 from pg_policies where schemaname = 'storage' and tablename = 'objects' and policyname = 'anexos_apagar') then
    create policy anexos_apagar on storage.objects for delete to authenticated
    using (bucket_id = 'anexos' and exists (
      select 1 from public.membros m
      where m.marca_id = (storage.foldername(name))[1]
        and lower(m.email) = lower(auth.jwt() ->> 'email')
        and m.papel = 'editor'));
  end if;
end $$;
