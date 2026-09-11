-- 1. Buat tabel categories
create table if not exists public.categories (
    id uuid default gen_random_uuid() primary key,
    name text not null unique,
    slug text not null unique,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Beri hak akses (RLS) agar bisa dibaca publik dan ditulis oleh admin
alter table public.categories enable row level security;

create policy "Allow public read categories"
on public.categories for select
to anon, authenticated
using (true);

create policy "Allow authenticated insert categories"
on public.categories for insert
to authenticated
with check (true);

create policy "Allow authenticated update categories"
on public.categories for update
to authenticated
using (true);

create policy "Allow authenticated delete categories"
on public.categories for delete
to authenticated
using (true);

-- 3. (Opsional) Masukkan kategori unik yang saat ini sudah ada di tabel books
insert into public.categories (name, slug)
select distinct category, lower(regexp_replace(category, '[^a-zA-Z0-9]+', '-', 'g'))
from public.books
where category is not null and category != ''
on conflict (name) do nothing;
