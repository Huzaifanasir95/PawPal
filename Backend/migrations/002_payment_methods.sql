CREATE TABLE public.payment_methods (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  method_type character varying NOT NULL DEFAULT 'card',
  brand character varying NOT NULL,
  cardholder_name character varying NOT NULL,
  last4 character varying(4) NOT NULL,
  expiry_month integer NOT NULL,
  expiry_year integer NOT NULL,
  nickname character varying,
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT payment_methods_pkey PRIMARY KEY (id),
  CONSTRAINT payment_methods_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);

CREATE INDEX payment_methods_user_id_idx ON public.payment_methods(user_id);
CREATE UNIQUE INDEX payment_methods_user_default_idx ON public.payment_methods(user_id) WHERE is_default;