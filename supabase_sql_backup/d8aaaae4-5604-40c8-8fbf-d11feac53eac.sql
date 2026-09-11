[?25l│
◒  Downloading snippet[1G[J◐  Downloading snippet[1G[J[?25h-- Tambahkan kolom konfigurasi WhatsApp Pre-Order ke public.site_settings
ALTER TABLE public.site_settings 
ADD COLUMN IF NOT EXISTS preorder_wa_enabled BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS preorder_wa_number TEXT DEFAULT '6281234567890';

-- Reload schema cache PostgREST agar Supabase langsung mengenali kolom baru
NOTIFY pgrst, 'reload schema';
