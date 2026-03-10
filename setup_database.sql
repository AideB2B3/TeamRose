-- Run this in your Supabase SQL Editor to ensure the 'shops' table matches the app code.
-- Dashboard -> SQL Editor -> New Query

ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS phone_number TEXT;
ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS business_hours TEXT;
ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
ALTER TABLE public.shops ADD COLUMN IF NOT EXISTS verified BOOLEAN DEFAULT false;
