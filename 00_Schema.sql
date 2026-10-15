create table user (
	id int primary key auto_increment,
	username varchar (50),
	email varchar (100),
	password varchar (100),
	create_at datetime default CURRENT_TIMESTAMP(),
	update_at datetime default CURRENT_TIMESTAMP() on update CURRENT_TIMESTAMP()
);

create table admin (
	id int primary key auto_increment,
	username varchar (50),
	password varchar (100),
	create_at datetime default CURRENT_TIMESTAMP()
);

drop table if exists film;

create table film (
	id int primary key auto_increment,
	admin_id int,
	judul varchar (100),
	sutradara varchar (100),
	pemeran varchar (100),
	tahun_rilis int,
	sinopsis varchar (100),
	rating decimal(3,1) default 0.00,
	create_at datetime default CURRENT_TIMESTAMP(),
	update_at datetime default CURRENT_TIMESTAMP() on update CURRENT_TIMESTAMP(),
	foreign key (admin_id) references admin(id)
);


create table genre (
	id int primary key auto_increment,
	nama_genre varchar (50) unique
);

create table film_genre (
    film_id int,
    genre_id int,
    primary key (film_id, genre_id),
    foreign key (film_id) references film(id) on delete cascade,
    foreign key (genre_id) references genre(id) on delete cascade
);

create table rating (
	id int primary key auto_increment,
	user_id int,
	film_id int,
	nilai int check (nilai >= 1 and nilai <= 10),
	create_at datetime default CURRENT_TIMESTAMP(),
	update_at datetime default CURRENT_TIMESTAMP() on update CURRENT_TIMESTAMP(),
	foreign key (user_id) references user(id),
	foreign key (film_id) references film(id)
);

create table review (
	id int primary key auto_increment,
	user_id int,
	film_id int,
	isi_review varchar(250),
	create_at datetime default CURRENT_TIMESTAMP(),
	update_at datetime default CURRENT_TIMESTAMP() on update CURRENT_TIMESTAMP(),
	foreign key (user_id) references user(id),
	foreign key (film_id) references film(id)
);

create table watchlist (
	id int primary key auto_increment,
	user_id int,
	film_id int,
	create_at datetime default CURRENT_TIMESTAMP(),
	foreign key (user_id) references user(id),
	foreign key (film_id) references film(id)
);

insert into user (username, email, password) values
('Ariel', 'ariel@gmail.com', 'ariel123'),
('Bani', 'bani@gmail.com', 'bani123'),
('Ferdi', 'ferdi@gmail.com', 'ferdi123');

insert into admin (username, password) values
('admin1', 'admin1123'),
('admin2', 'admin2134');

-- 1. Masukkan film (TANPA genre)
insert into film (admin_id, judul, sutradara, pemeran, tahun_rilis, sinopsis) values
(1, 'Spider-Man: No Way Home', 'Jon Watts', 'Tom Holland', 2021, 'Identitas Spider-Man terungkap.'); -- Film ID 1

-- 2. Masukkan master genre ke database
insert into genre (nama_genre) values 
('Action'),    -- Genre ID 1
('Adventure'), -- Genre ID 2
('Sci-Fi'),    -- Genre ID 3
('Drama');     -- Genre ID 4

-- 3. Hubungkan Film dengan Genrenya di tabel film_genre
-- Contoh: Spider-Man (ID 1) genrenya Action (1), Adventure (2), Sci-Fi (3)
insert into film_genre (film_id, genre_id) values 
(1, 1), 
(1, 2), 
(1, 3);

insert into rating (user_id, film_id, nilai) values
(2, 1, 7),
(1, 1, 9),
(1, 2, 8),
(2, 3, 10),
(3, 1, 9);

insert into review (user_id, film_id, isi_review) values 
(1, 1, 'Seru banget, efek visualnya juara dan ceritanya mindblowing!'),
(2, 3, 'Film Indonesia terbaik yang sangat menyentuh hati dan inspiratif.'),
(3, 1, 'Agak pusing di awal, tapi endingnya keren.');

insert into watchlist (user_id, film_id) values 
(1, 3), 
(2, 1), 
(3, 2);