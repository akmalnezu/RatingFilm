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
    end;

    start transaction;
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

#2: Login User

drop procedure if exists LoginUser$$

create procedure LoginUser(
    in p_email varchar(100),
    in p_password varchar(100)
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;
    select * from user where email = p_email and password = p_password;
    commit;
end$$

#3: Login Admin

drop procedure if exists LoginAdmin$$

create procedure LoginAdmin(
    in p_username varchar(50),
    in p_password varchar(100)
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;
    select * from admin where username = p_username and password = p_password;
    commit;
end$$

#4: Tambah Film (Admin)

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
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;
    insert into film (admin_id, judul, genre, sutradara, pemeran, tahun_rilis, sinopsis)
    values (p_admin_id, p_judul, p_genre, p_sutradara, p_pemeran, p_tahun_rilis, p_sinopsis);
    commit;
end$$

#5: Beri Ulasan (Rating & Review)

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
        commit;
    end if;
end$$

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
    end;

    start transaction;
    delete from review where user_id = p_user_id and film_id = p_film_id;
    delete from rating where user_id = p_user_id and film_id = p_film_id;
    commit;
end$$

#7: Tambah Watchlist

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

#8: Hapus Watchlist

drop procedure if exists HapusWatchlist$$

create procedure HapusWatchlist(
    in p_user_id int,
    in p_film_id int
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;
    delete from watchlist where user_id = p_user_id and film_id = p_film_id;
    commit;
end$$

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

#10: Menghapus Film (Admin) - Menghapus data child terlebih dahulu

drop procedure if exists HapusFilm$$

create procedure HapusFilm(
    in p_film_id int
)
begin
    declare exit handler for sqlexception
    begin
        rollback;
    end;

    start transaction;
    delete from watchlist where film_id = p_film_id;
    delete from review where film_id = p_film_id;
    delete from rating where film_id = p_film_id;
    
    delete from film where id = p_film_id;
    commit;
end$$

DELIMITER ;

call TambahFilm(1, 'The Batman', 'Action, Crime', 'Matt Reeves', 'Robert Pattinson, Zoë Kravitz', 2022, 'Batman menyelidiki korupsi di Gotham.');