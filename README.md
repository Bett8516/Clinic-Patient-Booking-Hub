# Carepoint · Clinic Patient Booking Hub

A responsive patient booking and clinic appointment dashboard. The browser sends asynchronous Supabase requests; PostgreSQL stores appointments and row-level security protects patient records. Patient booking is available without a staff login, while viewing, exporting, and managing the patient list requires an authenticated clinic account.

## Set up Supabase

1. Create a Supabase project. The project database can be named `healthcare_db` to match the exam brief; Supabase hosts the PostgreSQL database for the project.
2. In the Supabase SQL Editor, run [`supabase/schema.sql`](supabase/schema.sql).
3. In **Project Settings → API**, copy the Project URL and the publishable key (or legacy `anon` key). Paste them in [`config.js`](config.js).
4. Create staff accounts from the Supabase Dashboard under **Authentication → Users**. Keep public staff sign-up disabled. The app uses email and password sign-in.
5. Serve the project from a local web server, for example `npx serve .`, then open the local URL. Browser ES modules do not work reliably from `file://`.

Only a publishable/anon key belongs in `config.js`; never expose a service-role or secret key in client-side code. RLS permits anonymous booking inserts but does not permit anonymous reads. A unique date/time constraint prevents two patients from taking the same slot. To add more times or permit concurrent providers, update the SQL constraint/policy and the form options together.

## Features

- Responsive clinic dashboard with appointment counts, search, upcoming/all filters, and a monthly booking calendar.
- Patient booking with date, time, contact, and visit type fields; Supabase insertion runs without a page reload.
- Staff sign-in and protected appointment listing/export.
- CSV export of the staff-visible appointment list.
- RLS, database checks, parameterized Supabase client calls, and duplicate-slot protection.
- A preview mode runs without credentials using sample appointments. Preview bookings are stored only in this browser's local storage; connect Supabase before using real patient details.

## Supabase API shape

The browser uses Supabase's PostgREST API for `public.appointments`:

- `GET /rest/v1/appointments?select=*&order=appointment_date.asc,time_slot.asc` — authenticated clinic staff only.
- `POST /rest/v1/appointments` — patient booking; inserts a pending record and returns a clean success/error message.

The attached assessment mentions `appointments.php` and PHP/PDO. This implementation adapts the requested asynchronous GET/POST behavior to Supabase as requested, so there is no PHP endpoint or PHP database password to maintain.

## Basic environment safety

Position the screen at a comfortable eye level, keep wrists neutral, take regular breaks, and route cables away from walking paths. Store obsolete clinic computers and accessories securely until they can be handed to an authorized e-waste collection or recycling provider under the institution's local disposal process; remove clinic data using the institution's approved sanitization process before disposal.
