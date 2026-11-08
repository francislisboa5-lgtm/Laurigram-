-- LAURIGRAM: esquema inicial Supabase/PostgreSQL
-- Executar apenas depois de rever o projeto. Ativar RLS em todas as tabelas.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  username text unique,
  avatar_url text,
  bio text,
  role text not null default 'user' check (role in ('user','moderator','admin')),
  verified_until timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check (char_length(body) <= 5000),
  photo_url text,
  visibility text not null default 'public' check (visibility in ('public','followers','private')),
  created_at timestamptz not null default now()
);

create table if not exists public.pages (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  name text not null,
  category text not null,
  description text default '',
  created_at timestamptz not null default now()
);

create table if not exists public.page_admins (
  page_id uuid references public.pages(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  permission text not null default 'editor' check (permission in ('owner','editor','analyst')),
  primary key (page_id,user_id)
);

create table if not exists public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  profile_url text,
  reason text,
  amount_aoa integer not null default 989,
  payment_reference text unique not null,
  status text not null default 'pending' check (status in ('pending','paid','rejected','expired')),
  requested_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id)
);

create table if not exists public.sponsorships (
  id uuid primary key default gen_random_uuid(),
  page_id uuid not null references public.pages(id),
  buyer_id uuid not null references public.profiles(id),
  amount_aoa integer not null check (amount_aoa > 0),
  duration_days integer not null check (duration_days > 0),
  payment_reference text unique not null,
  status text not null default 'pending' check (status in ('pending','paid','rejected','active','completed')),
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  reviewed_by uuid references public.profiles(id)
);

create table if not exists public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references public.profiles(id),
  action text not null,
  target_table text not null,
  target_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.pages enable row level security;
alter table public.page_admins enable row level security;
alter table public.verification_requests enable row level security;
alter table public.sponsorships enable row level security;
alter table public.audit_log enable row level security;

-- Políticas mínimas de arranque. Não concedem poderes administrativos ao browser.
create policy "profiles readable" on public.profiles for select to authenticated using (true);
create policy "profile owner inserts" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "profile owner updates" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "public posts readable" on public.posts for select to anon, authenticated using (visibility = 'public' or user_id = auth.uid());
create policy "users create own posts" on public.posts for insert to authenticated with check (user_id = auth.uid());
create policy "users edit own posts" on public.posts for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "users delete own posts" on public.posts for delete to authenticated using (user_id = auth.uid());

create policy "pages readable" on public.pages for select to anon, authenticated using (true);
create policy "owners create pages" on public.pages for insert to authenticated with check (owner_id = auth.uid());

-- As tabelas de pedidos/pagamentos/admin ficam sem políticas para o cliente:
-- gerir por Edge Functions/servidor com verificação de role e registo de auditoria.
-- Nunca colocar a chave service_role no HTML/JavaScript do navegador.
