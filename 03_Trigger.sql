DELIMITER $$

#1. Setelah insert rating, update rating rata-rata film di tabel film dan hapus film dari watchlist user yang bersangkutan
create trigger AfterInsertRating
after insert on rating
for each row
begin
    update film set rating = AverageRating(new.film_id)
    where id = new.film_id;

    delete from watchlist 
    where user_id = new.user_id and film_id = new.film_id;
end$$

#2.Setelah update rating, update rating rata-rata film di tabel film

create trigger AfterUpdateRating
after update on rating
for each row
begin
    update film set rating = AverageRating(new.film_id)
    where id = new.film_id;
end$$

#3. Setelah delete rating, update rating rata-rata film di tabel film

create trigger AfterDeleteRating
after delete on rating
for each row
begin
    update film set rating = AverageRating(old.film_id)
    where id = old.film_id;
end$$

#4. Setelah menghapus Film, hapus semua rating, review, dan watchlist yang terkait dengan film tersebut

create trigger BeforeDeleteFilm
before delete on film
for each row
begin
    delete from rating where film_id = old.id;
    delete from review where film_id = old.id;
    delete from watchlist where film_id = old.id;
end$$

#5. Setelah menghapus User, hapus semua rating, review, dan watchlist yang terkait dengan user tersebut

create trigger BeforeDeleteUser
before delete on user
for each row
begin
    delete from rating where user_id = old.id;
    delete from review where user_id = old.id;
    delete from watchlist where user_id = old.id;
end$$


DELIMITER ;
