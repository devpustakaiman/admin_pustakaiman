[?25l│
◒  Downloading snippet[1G[J[?25h-- 1. Tambahkan kolom slug ke tabel articles
ALTER TABLE public.articles 
ADD COLUMN IF NOT EXISTS slug TEXT;

-- 2. Isi otomatis slug untuk seluruh artikel yang sudah ada berdasarkan judul
UPDATE public.articles
SET slug = LOWER(REGEXP_REPLACE(REGEXP_REPLACE(TRIM(title), '[^a-zA-Z0-9\s]', '', 'g'), '\s+', '-', 'g'))
WHERE slug IS NULL OR slug = '';

-- 3. Tambahkan kolom whatsapp_naskah ke site_settings untuk fitur nomor WA kirim naskah
ALTER TABLE public.site_settings 
ADD COLUMN IF NOT EXISTS whatsapp_naskah TEXT;
