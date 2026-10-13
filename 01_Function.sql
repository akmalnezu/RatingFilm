DELIMITER $$

create function TotalWatchlist(id_user int) returns int reads sql data
begin
	declare jumlah int;
	select count(*) into jumlah from watchlist
	where user_id = id_user;
	return jumlah;
end$$
select username, TotalWatchlist(id) as TotalFilmDiWatchlist from user;

create function AverageRating(id_film int) returns decimal(3,1) reads sql data
begin
	declare avg_rating decimal(3,1);
	select ifnull(avg(nilai), 0.0) into avg_rating from rating
	where film_id = id_film;
	return avg_rating;
end$$

create function CekSudahRating(id_user int, id_film int) returns int reads sql data
begin
    declare jumlah int;
    select count(*) into jumlah from rating
    where user_id = id_user and film_id = id_film;
    return jumlah;
end$$

DELIMITER ;