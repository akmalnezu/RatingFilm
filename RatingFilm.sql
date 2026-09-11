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

create table film (
	id int primary key auto_increment,
	admin_id int,
	judul varchar (100),
	genre varchar (100),
	sutradara varchar (100),
	pemeran varchar (100),
	tahun_rilis int,
	sinopsis varchar (100),
	create_at datetime default CURRENT_TIMESTAMP(),
	update_at datetime default CURRENT_TIMESTAMP() on update CURRENT_TIMESTAMP(),
	foreign key (admin_id) references admin(id)
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

insert into film (admin_id, judul, genre, sutradara, pemeran, tahun_rilis, sinopsis) values
('')

insert into rating (user_id, film_id, nilai) values
('')

insert into review (user_id, film_id, isi_review) values 
('')

insert into watchlist (user_id, film_id) values 
('')

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
	insert into film (admin_id, judul, genre, sutradara, pemeran, tahun_rilis, sinopsis)
	values (p_admin_id, p_judul, p_genre, p_sutradara, p_pemeran, p_tahun_rilis, p_sinopsis);
end
call TambahFilm(1, 'The Batman', 'Action, Crime', 'Matt Reeves', 'Robert Pattinson, Zoë Kravitz', 2022, 'Batman menyelidiki korupsi di Gotham.');

create function

















