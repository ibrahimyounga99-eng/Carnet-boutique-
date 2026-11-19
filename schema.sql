-- Carnet Boutique : schéma de base de données (Supabase / PostgreSQL)
-- À coller une seule fois dans Supabase > SQL Editor > New query, puis « Run ».

-- 1) Données des commerçants : une seule table, une ligne par client / mouvement / ligne de caisse.
create table if not exists public.records (
  user_id    uuid    not null default auth.uid() references auth.users(id) on delete cascade,
  id         text    not null,                 -- ex. « c:ab12 » (client), « t:… » (mouvement), « k:… » (caisse), « s:shop »
  kind       text    not null,
  data       jsonb,
  updated_at bigint  not null,                 -- date de modification choisie par l'application (millisecondes)
  deleted    boolean not null default false,   -- suppression douce : la ligne reste, marquée supprimée
  synced_at  timestamptz not null default now(), -- rempli par le serveur, sert à la synchronisation
  primary key (user_id, id)
);
create index if not exists records_sync_idx on public.records (user_id, synced_at);
alter table public.records enable row level security;

-- 2) Abonnements : une ligne par commerçant ayant payé.
create table if not exists public.subscriptions (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  paid_until timestamptz not null
);
alter table public.subscriptions enable row level security;

-- 3) Accès : essai gratuit de 14 jours après l'inscription, ou abonnement en cours.
--    Si vous changez 14 jours ici, changez aussi TRIAL_DAYS dans config.js.
create or replace function public.has_access() returns boolean
language sql stable security definer set search_path = public, auth as $$
  select now() < greatest(
    (select created_at from auth.users where id = auth.uid()) + interval '14 days',
    coalesce((select paid_until from public.subscriptions where user_id = auth.uid()), 'epoch'::timestamptz)
  );
$$;

-- 4) Règles de sécurité : chacun ne voit et ne modifie que ses propres données.
drop policy if exists "lire ses donnees"    on public.records;
drop policy if exists "ajouter ses donnees" on public.records;
drop policy if exists "modifier ses donnees" on public.records;
drop policy if exists "lire son abonnement" on public.subscriptions;

create policy "lire ses donnees"     on public.records for select using (user_id = auth.uid());
create policy "ajouter ses donnees"  on public.records for insert with check (user_id = auth.uid() and public.has_access());
create policy "modifier ses donnees" on public.records for update using (user_id = auth.uid())
                                                               with check (user_id = auth.uid() and public.has_access());
create policy "lire son abonnement"  on public.subscriptions for select using (user_id = auth.uid());
-- Aucune règle de suppression : les lignes ne sont jamais effacées, seulement marquées « deleted ».

-- 5) Synchronisation : le serveur date chaque écriture, et ignore une écriture plus ancienne que celle déjà enregistrée
--    (cas d'un téléphone qui renvoie d'anciennes modifications après un long moment hors ligne).
create or replace function public.records_before_write() returns trigger
language plpgsql as $$
begin
  if tg_op = 'UPDATE' and new.updated_at < old.updated_at then
    return null;
  end if;
  new.synced_at := now();
  return new;
end;
$$;
drop trigger if exists records_before_write on public.records;
create trigger records_before_write before insert or update on public.records
  for each row execute function public.records_before_write();

-- 6) Activer un abonné à la main, après réception de son paiement Mobile Money.
--    Utilisation (dans SQL Editor) :  select public.activate_phone('70123456', 30);
create or replace function public.activate_phone(p_phone text, p_days int default 30) returns timestamptz
language plpgsql security definer set search_path = public, auth as $$
declare
  v_uid uuid;
  v_cur timestamptz;
  v_new timestamptz;
begin
  select id into v_uid from auth.users
   where email = 'p226' || regexp_replace(p_phone, '\D', '', 'g') || '@carnet-boutique.app';
  if v_uid is null then
    raise exception 'Aucun compte pour ce numéro';
  end if;
  select paid_until into v_cur from public.subscriptions where user_id = v_uid;
  v_new := greatest(now(), coalesce(v_cur, now())) + make_interval(days => p_days);
  insert into public.subscriptions (user_id, paid_until) values (v_uid, v_new)
  on conflict (user_id) do update set paid_until = excluded.paid_until;
  return v_new;
end;
$$;
revoke all on function public.activate_phone(text, int) from public, anon, authenticated;
