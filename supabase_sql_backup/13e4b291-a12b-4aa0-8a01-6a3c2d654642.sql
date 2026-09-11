[?25l│
[?25h-- 1. Matikan RLS sementara untuk membersihkan sisa konfigurasi
ALTER TABLE public.media_videos DISABLE ROW LEVEL SECURITY;

-- 2. Hapus semua kemungkinan policy yang pernah dibuat di tabel ini
DROP POLICY IF EXISTS "Allow authenticated delete" ON public.media_videos;
DROP POLICY IF EXISTS "Allow authenticated insert" ON public.media_videos;
DROP POLICY IF EXISTS "Allow authenticated update" ON public.media_videos;
DROP POLICY IF EXISTS "Allow all for authenticated" ON public.media_videos;
DROP POLICY IF EXISTS "Allow all for media_videos" ON public.media_videos;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.media_videos;

-- 3. Aktifkan kembali RLS
ALTER TABLE public.media_videos ENABLE ROW LEVEL SECURITY;

-- 4. Pasang satu policy universal (mencakup SELECT, INSERT, UPDATE, DELETE untuk publik & admin)
CREATE POLICY "Allow all operations for all users"
ON public.media_videos
FOR ALL
TO public
USING (true)
WITH CHECK (true);
