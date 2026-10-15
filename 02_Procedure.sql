DELIMITER $$

#1: Registrasi dengan validasi anti-duplikat

drop procedure if exists RegistrasiUser$$

create procedure RegistrasiUser(
    in p_username varchar(50),
    in p_email varchar(100),
    in p_password varchar(100)
)
begin
    declare cek_duplikat int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    
    -- VALIDASI 1: Cek format email menggunakan REGEXP
    if p_email not regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Format email tidak valid!';
    end if;

    -- VALIDASI 2: Cek apakah email/username sudah dipakai
    select count(*) into cek_duplikat from user 
    where email = p_email or username = p_username;

    if cek_duplikat > 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Username atau Email sudah terdaftar!';
    else
        insert into user (username, email, password) 
        values (p_username, p_email, p_password);
        commit;
    end if;
end$$

call RegistrasiUser('Wisnu', 'wisnu@example.com', 'password123');

#2: Login User

drop procedure if exists LoginUser$$

create procedure LoginUser(
    in p_akun varchar(100), 
    in p_password varchar(100)
)
begin
    declare cek_user int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    
    -- VALIDASI: Jika input mengandung '@', pastikan format emailnya benar
    if p_akun like '%@%' and p_akun not regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Format penulisan email tidak valid!';
    end if;
    
    select count(*) into cek_user from user 
    where (email = p_akun or username = p_akun) and password = p_password;

    if cek_user = 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Email/Username atau Password salah!';
    else
        select * from user 
        where (email = p_akun or username = p_akun) and password = p_password;
        commit;
    end if;
end$$

call LoginUser('akmal@example.com', 'password123');

#3: Login Admin

drop procedure if exists LoginAdmin$$

create procedure LoginAdmin(
    in p_username varchar(50),
    in p_password varchar(100)
)
begin
    declare cek_admin int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    
    select count(*) into cek_admin from admin 
    where username = p_username and password = p_password;

    if cek_admin = 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Username atau Password admin salah!';
    else
        select * from admin where username = p_username and password = p_password;
        commit;
    end if;
end$$

call LoginAdmin('admin1', 'admin123');

#4: Tambah Film (Admin) - Dengan Pengecekan Duplikat

drop procedure if exists TambahFilm$$

create procedure TambahFilm(
    in p_admin_id int,
    in p_judul varchar(100),
    in p_genre varchar(100),
    in p_sutradara varchar(100),
    in p_pemeran varchar(100),
    in p_tahun_rilis int,
    in p_sinopsis varchar(100)
)
begin
    declare cek_duplikat int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal; 
    end;

    start transaction;
    select count(*) into cek_duplikat from film where judul = p_judul;

    if cek_duplikat > 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Film dengan judul ini sudah ada di database!';
    else
        insert into film (admin_id, judul, genre, sutradara, pemeran, tahun_rilis, sinopsis)
        values (p_admin_id, p_judul, p_genre, p_sutradara, p_pemeran, p_tahun_rilis, p_sinopsis);
        commit;
    end if;
end$$

call TambahFilm(1, 'Inception', 'Sci-Fi, Thriller', 'Christopher Nolan', 'Leonardo DiCaprio, Joseph Gordon-Levitt', 2010, 'A thief who steals corporate secrets through dream-sharing technology.');

#5: Beri Ulasan (Rating & Review) - Update otomatis jika sudah rating

drop procedure if exists BeriUlasan$$

create procedure BeriUlasan(
    in p_user_id int,
    in p_film_id int,
    in p_nilai int,
    in p_isi_review varchar(250)
)
begin
    declare sudah_rating int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    set sudah_rating = CekSudahRating(p_user_id, p_film_id);

    if sudah_rating > 0 then
        update rating set nilai = p_nilai, update_at = CURRENT_TIMESTAMP() 
        where user_id = p_user_id and film_id = p_film_id;

        update review set isi_review = p_isi_review, update_at = CURRENT_TIMESTAMP() 
        where user_id = p_user_id and film_id = p_film_id;
    else
        insert into rating (user_id, film_id, nilai) values (p_user_id, p_film_id, p_nilai);
        insert into review (user_id, film_id, isi_review) values (p_user_id, p_film_id, p_isi_review);
    end if;
    commit;
end$$

call BeriUlasan(1, 1, 9, 'Film ini sangat menghibur dan penuh aksi!');

#6: Hapus Ulasan (User)

drop procedure if exists HapusUlasan$$

create procedure HapusUlasan(
    in p_user_id int,
    in p_film_id int
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    delete from review where user_id = p_user_id and film_id = p_film_id;
    delete from rating where user_id = p_user_id and film_id = p_film_id;
    commit;
end$$

call HapusUlasan(1, 1);

#7: Tambah Watchlist - Pengecekan Film Kembar

drop procedure if exists TambahWatchlist$$

create procedure TambahWatchlist(
    in p_user_id int,
    in p_film_id int
)
begin
    declare sudah_di_watchlist int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    select count(*) into sudah_di_watchlist from watchlist 
    where user_id = p_user_id and film_id = p_film_id;

    if sudah_di_watchlist > 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Film sudah ada di watchlist user ini.';
    else
        insert into watchlist (user_id, film_id) values (p_user_id, p_film_id);
        commit;
    end if;
end$$

call TambahWatchlist(1, 1);

#8: Hapus Watchlist

drop procedure if exists HapusWatchlist$$

create procedure HapusWatchlist(
    in p_user_id int,
    in p_film_id int
)
begin
    declare cek_watchlist int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    
    select count(*) into cek_watchlist from watchlist 
    where user_id = p_user_id and film_id = p_film_id;

    if cek_watchlist = 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Film tersebut tidak ada di watchlist Anda!';
    else
        delete from watchlist where user_id = p_user_id and film_id = p_film_id;
        commit;
    end if;
end$$

call HapusWatchlist(1, 1);

#9: Mengubah Film (Admin)

drop procedure if exists UbahFilm$$

create procedure UbahFilm(
    in p_film_id int,
    in p_judul varchar(100),
    in p_genre varchar(100),
    in p_sutradara varchar(100),
    in p_pemeran varchar(100),
    in p_tahun_rilis int,
    in p_sinopsis varchar(100)
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    update film 
    set judul = p_judul, 
        genre = p_genre, 
        sutradara = p_sutradara, 
        pemeran = p_pemeran, 
        tahun_rilis = p_tahun_rilis, 
        sinopsis = p_sinopsis
    where id = p_film_id;
    commit;
end$$

call UbahFilm(4, 'Spider-Man: No Way Home', 'Action, Adventure, Sci-Fi', 'Jon Watts', 'Tom Holland, Zendaya, Benedict Cumberbatch', 2021, 'Identitas Spider-Man terungkap, dan dia meminta bantuan Doctor Strange.');

#10: Menghapus Film

drop procedure if exists HapusFilm$$

create procedure HapusFilm(
    in p_film_id int
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    delete from watchlist where film_id = p_film_id;
    delete from review where film_id = p_film_id;
    delete from rating where film_id = p_film_id;
    
    delete from film where id = p_film_id;
    commit;
end$$

call HapusFilm(1);

#11: Menghapus User

drop procedure if exists HapusUser$$

create procedure HapusAkun(
    in p_user_id int
)
begin
    declare cek_user int;
    declare exit handler for sqlexception
    begin
        rollback;
        resignal;
    end;

    start transaction;
    
    -- Mengecek apakah user dengan ID tersebut terdaftar di database
    select count(*) into cek_user from user where id = p_user_id;

    if cek_user = 0 then
        rollback;
        signal sqlstate '45000' set message_text = 'Gagal: Akun user tidak ditemukan!';
    else
        delete from user where id = p_user_id;
        
        commit;
    end if;
end$$

DELIMITER ;