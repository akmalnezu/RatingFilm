DELIMITER $$

create trigger AfterInsertRating
after insert on rating
for each row
begin
    update film set rating = AverageRating(new.film_id)
    where id = new.film_id;

    delete from watchlist 
    where user_id = new.user_id and film_id = new.film_id;
end$$

create trigger AfterUpdateRating
after update on rating
for each row
begin
    update film set rating = AverageRating(new.film_id)
    where id = new.film_id;
end$$

create trigger AfterDeleteRating
after delete on rating
for each row
begin
    update film set rating = AverageRating(old.film_id)
    where id = old.film_id;
end$$

create trigger BeforeDeleteFilm
before delete on film
for each row
begin
    delete from rating where film_id = old.id;
    delete from review where film_id = old.id;
    delete from watchlist where film_id = old.id;
end$$

create trigger BeforeDeleteUser
before delete on user
for each row
begin
    delete from rating where user_id = old.id;
    delete from review where user_id = old.id;
    delete from watchlist where user_id = old.id;
end$$


DELIMITER ;
