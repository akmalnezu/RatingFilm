-- =============================================================================
-- 06_Grant.sql : Pembuatan User Khusus dengan Hak Akses EXECUTE & SELECT Saja
-- Database     : ratingfilm
-- =============================================================================

-- 1. Hapus user lama jika sudah ada (agar bersih)
DROP USER IF EXISTS 'user_film'@'localhost';

-- 2. Buat user baru dengan nama 'user_film' dan password 'password123'
CREATE USER 'user_film'@'localhost' IDENTIFIED BY 'password123';

-- 3. Berikan HANYA hak akses EXECUTE dan SELECT pada seluruh database 'ratingfilm'
--    - EXECUTE : Menjalankan seluruh Stored Procedure dan Stored Function
--    - SELECT  : Membaca seluruh data Tabel dan VIEW
GRANT EXECUTE, SELECT ON ratingfilm.* TO 'user_film'@'localhost';

-- 4. Muat ulang tabel hak akses agar langsung aktif
FLUSH PRIVILEGES;

-- 5. Cek pembuktian hak akses yang telah berhasil diberikan
SHOW GRANTS FOR 'user_film'@'localhost';
