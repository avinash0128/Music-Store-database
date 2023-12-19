drop database music_database;
create database music_database;
use music_database;

create table media_type(
	media_type_id int primary key,
    name text
);
select * from media_type;


create table genre(
	genre_id int primary key,
    name text
);
select * from genre;


create table artist(
	artist_id int primary key,
    name text
);
select * from artist;


create table album(
	album_id int primary key,
    title text,
    artist_id int
);
select * from album;


create table playlist(
	playlist_id int primary key,
    name text
);
select * from playlist;


create table playlist_track(
	playlist_id int,
    track_id int
);
select * from playlist_track;


create table employee(
	employee_id int primary key,
    last_name text,
    first_name text,
    title text,
    reports_to int,
    levels text,
    birthdate text,
    hire_date text,
    address text,
    city text,
    state text,
    country text,
    postal_code text,
    phone text,
    fax text,
    email text
);
select * from employee;


create table customer(
	customer_id int primary key,
    first_name text,
	last_name text,
    company text,
    address text,
    city text,
    state text,
    country text,
    postal_code text,
    phone text,
    fax text,
    email text,
    support_rep_id int
);
select * from customer;


create table invoice(
	invoice_id int primary key,
    customer_id int,
    invoice_date text,
    billing_address text,
    billing_city text,
    billing_state text,
	billing_country text,
	billing_postal_code text,
	total float
);
select * from invoice;


create table invoice_line(
	invoice_line_id int primary key,
    invoice_id int,
    track_id int,
    unit_price float,
    quantity int
);
select * from invoice_line;


create table track(
	track_id int primary key,
    name text,
    album_id int,
    media_type_id int,
    genre_id int,
    composer text,
    milliseconds bigint,
    bytes bigint,
    unit_price float
);
select* from track;

select * from album;














