-- Carepoint clinic booking schema for Supabase (Postgres).
-- Run in Supabase Dashboard → SQL Editor. No service_role key belongs in the browser.
create extension if not exists pgcrypto;

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  patient_name varchar(120) not null check (length(trim(patient_name)) between 2 and 120),
  email varchar(254) not null check (email ~* '^[A-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[A-Z0-9-]+(\.[A-Z0-9-]+)+$'),
  phone varchar(32),
  appointment_date date not null check (appointment_date >= current_date),
  time_slot varchar(5) not null check (time_slot in ('08:00','09:00','10:00','11:00','12:00','14:00','15:00','16:00')),
  visit_type varchar(80) not null default 'General consultation',
  status varchar(16) not null default 'pending' check (status in ('pending','confirmed','completed','cancelled')),
  created_at timestamptz not null default now(),
  constraint appointments_unique_slot unique (appointment_date, time_slot)
);

create index if not exists appointments_date_time_idx on public.appointments (appointment_date, time_slot);
create index if not exists appointments_email_idx on public.appointments (lower(email));
alter table public.appointments enable row level security;

-- Patients may book a visit. RLS intentionally prevents anonymous browsing of patient records.
drop policy if exists "Anyone can create an appointment" on public.appointments;
create policy "Anyone can create an appointment"
  on public.appointments for insert to anon, authenticated
  with check (
    length(trim(patient_name)) between 2 and 120
    and length(trim(email)) between 5 and 254
    and appointment_date >= current_date
    and time_slot in ('08:00','09:00','10:00','11:00','12:00','14:00','15:00','16:00')
    and status = 'pending'
  );

-- Only signed-in clinic users can view or manage records. Restrict staff account creation
-- to the clinic administrator in Supabase Auth; do not enable public sign-up for staff.
drop policy if exists "Clinic staff can view appointments" on public.appointments;
create policy "Clinic staff can view appointments"
  on public.appointments for select to authenticated using (true);
drop policy if exists "Clinic staff can update appointments" on public.appointments;
create policy "Clinic staff can update appointments"
  on public.appointments for update to authenticated using (true) with check (true);
drop policy if exists "Clinic staff can delete appointments" on public.appointments;
create policy "Clinic staff can delete appointments"
  on public.appointments for delete to authenticated using (true);

grant usage on schema public to anon, authenticated;
grant insert on public.appointments to anon, authenticated;
grant select, update, delete on public.appointments to authenticated;
