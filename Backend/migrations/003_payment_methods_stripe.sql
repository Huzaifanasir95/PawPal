ALTER TABLE public.payment_methods
  ADD COLUMN IF NOT EXISTS stripe_payment_method_id character varying;

CREATE UNIQUE INDEX IF NOT EXISTS payment_methods_stripe_payment_method_id_idx
  ON public.payment_methods(stripe_payment_method_id)
  WHERE stripe_payment_method_id IS NOT NULL;