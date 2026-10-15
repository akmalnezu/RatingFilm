#1
drop view if exists FilmWithAverageRating;

create view FilmWithAverageRating as
select f.id, f.judul, f.sutradara, f.pemeran, f.tahun_rilis, f.sinopsis, f.rating as average_rating
from film f;
select * from FilmWithAverageRating;
select * from FilmWithAverageRating WHERE judul = 'Spider-Man: No Way Home';

#2
drop view if exists ViewDetailReview;

create view ViewDetailReview as
select 
    f.id as film_id,
    f.judul as judul_film,
    u.id as user_id, 
    u.username as nama_user, 
    r.nilai as rating_diberikan,
    rv.isi_review as isi_review,
    rv.create_at as tanggal_review
from review rv
join user u on rv.user_id = u.id
join film f on rv.film_id = f.id
left join rating r on rv.user_id = r.user_id and rv.film_id = r.film_id;

select * from ViewDetailReview;
select * from ViewDetailReview WHERE judul_film = 'Spider-Man: No Way Home';

#3
drop view if exists AktivitasUser;

create view AktivitasUser as
select
    u.id as user_id,
    u.username as nama_user,
    u.email as email_user,
    (select count(*) from rating where user_id = u.id) as total_rating_diberikan,
    (select count(*) from review where user_id = u.id) as total_review_ditulis,
    TotalWatchlist(u.id) as total_film_di_watchlist
from user u;

select * from AktivitasUser;
select * from AktivitasUser where nama_user = 'Ariel';

#4
drop view if exists DaftarWatchlistUser;

create view DaftarWatchlistUser as
select
    u.id as user_id,
    u.username as nama_user,
    f.id as film_id,
    f.judul as judul_film,
    w.create_at as tanggal_ditambahkan
from watchlist w
join user u on w.user_id = u.id
join film f on w.film_id = f.id;

select * from DaftarWatchlistUser;
select * from DaftarWatchlistUser where nama_user = 'Ariel';

#5
drop view if exists ViewFilmPopuler;

create view ViewFilmPopuler as
select 
    f.id as film_id,
    f.judul as judul_film,
    f.tahun_rilis,
    AverageRating(f.id) as rating_rata_rata,
    (select count(*) from rating where film_id = f.id) as jumlah_pemberi_rating,
    (select count(*) from review where film_id = f.id) as jumlah_review
from film f;

select * from ViewFilmPopuler order by rating_rata_rata desc, jumlah_pemberi_rating desc limit 10;

#6

drop view if exists FilmLengkapDenganGenre;

create view FilmLengkapDenganGenre as
select
    f.id as film_id,
    f.judul,
    group_concat(g.nama_genre SEPARATOR ', ') as genre,
    f.sutradara,
    f.pemeran,
    f.tahun_rilis,
    f.sinopsis,
    f.rating as average_rating
from film f
left join film_genre fg on f.id = fg.film_id
left join genre g on fg.genre_id = g.id
group by f.id, f.judul, f.sutradara, f.pemeran, f.tahun_rilis, f.sinopsis, f.rating;

SELECT * FROM FilmLengkapDenganGenre;
SELECT * FROM FilmLengkapDenganGenre WHERE judul = 'Spider-Man: No Way Home';