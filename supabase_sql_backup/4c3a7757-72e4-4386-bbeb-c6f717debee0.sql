-- 1. Tambah kolom panduan naskah ke tabel site_settings
ALTER TABLE public.site_settings 
ADD COLUMN IF NOT EXISTS manuscript_steps JSONB DEFAULT '[
  {
    "step": 1,
    "title": "Step 1: Kirim berkas & sinopsis lengkap",
    "description": "Lengkapi formulir pengiriman beserta berkas naskah lengkap (PDF/DOCX) dan sinopsis komprehensif."
  },
  {
    "step": 2,
    "title": "Step 2: Kurasi substansi & orisinalitas oleh tim redaksi",
    "description": "Tim redaksi akan melakukan peninjauan substansi dan keaslian karya (estimasi 14–30 hari kerja)."
  },
  {
    "step": 3,
    "title": "Step 3: Pemberitahuan kelayakan terbit via Email / WhatsApp resmi",
    "description": "Pemberitahuan hasil peninjauan dan status kelayakan terbit akan dikirimkan secara resmi."
  }
]'::jsonb,
ADD COLUMN IF NOT EXISTS manuscript_criteria JSONB DEFAULT '[
  "Naskah orisinal (bukan plagiasi)",
  "Format rapi (A4, 1.5 spasi, Font standar)",
  "Menyertakan daftar isi dan bab pembuka"
]'::jsonb,
ADD COLUMN IF NOT EXISTS manuscript_contact_desc TEXT DEFAULT 'Punya pertanyaan seputar syarat penerbitan naskah? Hubungi langsung meja redaksi kami melalui WhatsApp resmi.',
ADD COLUMN IF NOT EXISTS manuscript_whatsapp TEXT DEFAULT '085100007692';

-- 2. Pastikan baris 'default' terisi data awal jika masih NULL
UPDATE public.site_settings
SET 
  manuscript_steps = COALESCE(manuscript_steps, '[
    {
      "step": 1,
      "title": "Step 1: Kirim berkas & sinopsis lengkap",
      "description": "Lengkapi formulir pengiriman beserta berkas naskah lengkap (PDF/DOCX) dan sinopsis komprehensif."
    },
    {
      "step": 2,
      "title": "Step 2: Kurasi substansi & orisinalitas oleh tim redaksi",
      "description": "Tim redaksi akan melakukan peninjauan substansi dan keaslian karya (estimasi 14–30 hari kerja)."
    },
    {
      "step": 3,
      "title": "Step 3: Pemberitahuan kelayakan terbit via Email / WhatsApp resmi",
      "description": "Pemberitahuan hasil peninjauan dan status kelayakan terbit akan dikirimkan secara resmi."
    }
  ]'::jsonb),
  manuscript_criteria = COALESCE(manuscript_criteria, '[
    "Naskah orisinal (bukan plagiasi)",
    "Format rapi (A4, 1.5 spasi, Font standar)",
    "Menyertakan daftar isi dan bab pembuka"
  ]'::jsonb),
  manuscript_contact_desc = COALESCE(manuscript_contact_desc, 'Punya pertanyaan seputar syarat penerbitan naskah? Hubungi langsung meja redaksi kami melalui WhatsApp resmi.'),
  manuscript_whatsapp = COALESCE(manuscript_whatsapp, '085100007692')
WHERE id = 'default';

-- 3. Muat ulang cache skema PostgREST
NOTIFY pgrst, 'reload schema';
