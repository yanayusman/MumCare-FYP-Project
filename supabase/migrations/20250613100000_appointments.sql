-- Appointments table for MumCare
-- Run in Supabase SQL Editor (Dashboard → SQL → New query)
--
-- Flow:
--   • Nurse (admin dashboard) creates/confirms appointments → sets scheduled_at, status = confirmed
--   • User requests new appointment → preferred_date, status = pending
--   • User requests reschedule → preferred_date, status = rescheduled (nurse updates scheduled_at)

CREATE TABLE IF NOT EXISTS public.appointments (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type            TEXT NOT NULL,
  doctor_name     TEXT NOT NULL DEFAULT 'Dr.',
  scheduled_at    TIMESTAMPTZ,
  preferred_date  DATE,
  notes           TEXT,
  location        TEXT,
  status          TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'confirmed', 'rescheduled', 'cancelled', 'completed')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS appointments_user_id_idx ON public.appointments(user_id);
CREATE INDEX IF NOT EXISTS appointments_scheduled_at_idx ON public.appointments(scheduled_at);

ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- Users can view their own appointments
DROP POLICY IF EXISTS "Users can view own appointments" ON public.appointments;
CREATE POLICY "Users can view own appointments"
  ON public.appointments FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Users can submit new appointment requests (pending only)
DROP POLICY IF EXISTS "Users can create appointment requests" ON public.appointments;
CREATE POLICY "Users can create appointment requests"
  ON public.appointments FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND status = 'pending'
    AND scheduled_at IS NULL
  );

-- Users can request reschedule on their own appointments
DROP POLICY IF EXISTS "Users can request reschedule" ON public.appointments;
CREATE POLICY "Users can request reschedule"
  ON public.appointments FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (
    user_id = auth.uid()
    AND status IN ('pending', 'confirmed', 'rescheduled')
  );

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_appointments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS appointments_updated_at ON public.appointments;
CREATE TRIGGER appointments_updated_at
  BEFORE UPDATE ON public.appointments
  FOR EACH ROW EXECUTE FUNCTION public.set_appointments_updated_at();
