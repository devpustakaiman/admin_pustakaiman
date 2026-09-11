ALTER TABLE public.site_settings 
ADD COLUMN IF NOT EXISTS manuscript_whatsapp_enabled BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS manuscript_whatsapp_number TEXT;
