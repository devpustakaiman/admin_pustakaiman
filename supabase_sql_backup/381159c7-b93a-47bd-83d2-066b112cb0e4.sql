-- Tambah kolom is_upcoming dan release_date ke tabel books
ALTER TABLE books 
ADD COLUMN IF NOT EXISTS is_upcoming BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS release_date DATE;

-- Indeks untuk query landing page dan filtering
CREATE INDEX IF NOT EXISTS idx_books_is_upcoming ON books (is_upcoming);
