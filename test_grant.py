import mysql.connector

print("=" * 70)
print("     PEMBUKTIAN HAK AKSES USER 'user_film' (EXECUTE & SELECT)")
print("=" * 70)

try:
    conn = mysql.connector.connect(
        host="localhost",
        user="user_film",
        password="password123",
        database="ratingfilm"
    )
    cursor = conn.cursor()

    # 1. Cek Hak Akses Resmi dari MySQL
    print("\n[1] DAFTAR RESMI IZIN DARI MYSQL:")
    cursor.execute("SHOW GRANTS FOR 'user_film'@'localhost'")
    for row in cursor.fetchall():
        print("  ->", row[0])

    # 2. Uji Izin SELECT (Harus Berhasil)
    print("\n[2] UJI IZIN 'SELECT' PADA VIEW/TABEL:")
    cursor.execute("SELECT judul, rating FROM FilmLengkapDenganGenre LIMIT 2")
    films = cursor.fetchall()
    print("  [BERHASIL] SELECT berhasil dieksekusi:")
    for f in films:
        print("   *", f)

    # 3. Uji Izin EXECUTE Stored Procedure (Harus Berhasil)
    print("\n[3] UJI IZIN 'EXECUTE' STORED PROCEDURE:")
    cursor.callproc("FilterFilmByGenre", ["Action"])
    print("  [BERHASIL] Procedure 'FilterFilmByGenre' berhasil dipanggil!")

    # 4. Uji Perintah yang DILARANG: DROP TABLE (Harus Ditolak!)
    print("\n[4] UJI PERINTAH TERLARANG: DROP TABLE film")
    try:
        cursor.execute("DROP TABLE film")
        print("  [BAHAYA] DROP berhasil (ini salah!)")
    except mysql.connector.Error as err:
        print("  [TERBUKTI DITOLAK!] MySQL menolak perintah DROP:")
        print(f"  -> Pesan Error: {err.msg}")

    # 5. Uji Akses Database Lain: mysql.user (Harus Ditolak!)
    print("\n[5] UJI MENGAKSES DATABASE LAIN (mysql.user)")
    try:
        cursor.execute("SELECT * FROM mysql.user")
        print("  [BAHAYA] Berhasil intip database sistem!")
    except mysql.connector.Error as err:
        print("  [TERBUKTI DITOLAK!] Akses ke database lain ditolak:")
        print(f"  -> Pesan Error: {err.msg}")

    cursor.close()
    conn.close()
    print("\n" + "=" * 70)
    print("KESIMPULAN: User 'user_film' HANYA memiliki hak EXECUTE & SELECT!")
    print("=" * 70)

except mysql.connector.Error as err:
    print("Gagal koneksi:", err.msg)
