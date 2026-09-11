-- Pastikan RLS mengizinkan SELECT untuk publik / anon
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view site_settings" ON public.site_settings;
CREATE POLICY "Public can view site_settings" 
ON public.site_settings 
FOR SELECT 
TO anon, authenticated 
USING (true);

NOTIFY pgrst, 'reload schema';
