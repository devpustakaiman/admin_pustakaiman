-- Tambahkan kolom featured_categories ke tabel site_settings
ALTER TABLE site_settings 
ADD COLUMN IF NOT EXISTS featured_categories JSONB DEFAULT '{
  "main_category": { "category_id": null, "book_covers": [] },
  "sub_categories": []
}'::jsonb;

-- Refresh schema cache PostgREST agar Supabase langsung mengenali kolom baru
NOTIFY pgrst, 'reload schema';
