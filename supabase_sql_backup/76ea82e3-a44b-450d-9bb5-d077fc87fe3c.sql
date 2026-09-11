ALTER TABLE public.site_settings
ADD COLUMN IF NOT EXISTS facebook_url text DEFAULT 'https://www.facebook.com/penerbit.imania/',
ADD COLUMN IF NOT EXISTS x_url text DEFAULT 'https://x.com/penerbitimania',
ADD COLUMN IF NOT EXISTS instagram_url text DEFAULT 'https://www.instagram.com/penerbitimania/',
ADD COLUMN IF NOT EXISTS tiktok_url text DEFAULT 'https://www.tiktok.com/@penerbitimania',
ADD COLUMN IF NOT EXISTS mizanstore_url text DEFAULT 'https://mizanstore.com';

-- Tambahkan kolom twitter_url ke tabel site_settings
ALTER TABLE public.site_settings
ADD COLUMN IF NOT EXISTS twitter_url text DEFAULT 'https://x.com/penerbitimania';

-- Samakan isinya dengan x_url jika sudah ada
UPDATE public.site_settings 
SET twitter_url = COALESCE(x_url, 'https://x.com/penerbitimania')
WHERE id = 'default';

-- Refresh schema cache PostgREST Supabase agar langsung terbaca
NOTIFY pgrst, 'reload schema';
