create index idx_user_username on user(username);
create index idx_user_email on user(email);

create index idx_film_judul on film(judul);
create index idx_film_genre on film(genre);
create index idx_film_sutradara on film(sutradara);
create index idx_film_tahun_rilis on film(tahun_rilis);
create index idx_film_rating on film(rating);

create index idx_rating_user_film on rating(user_id, film_id);
create index idx_rating_film on rating(film_id);

create index idx_review_user_film on review(user_id, film_id);
create index idx_review_film on review(film_id);

create index idx_watchlist_user_film on watchlist(user_id, film_id);