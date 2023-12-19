use music_database;

-- que set 1 -easy
-- que1
select * from employee
order by levels desc
limit 1;-- madan mohan

-- que2
select billing_country, count(billing_country)
from invoice
group by billing_country
order by count(billing_country) desc limit 1;-- USA 131

-- que3
select billing_country, count(billing_country)
from invoice
group by billing_country
order by count(billing_country) desc limit 3;-- usa 131, canada 76, brazil 61

select * from invoice;

select invoice_id, total
from invoice
order by total desc limit 3;

-- que4
select billing_city as city, sum(total) as invoice_total
from invoice
GROUP BY city
order by invoice_total desc limit 1;-- prague sum:273.24

-- que5
select * from invoice;

select customer_id
from invoice
group by customer_id
order by sum(total) desc limit 1;-- customer_id = 5

select * from customer;

select first_name, last_name
from customer
where customer_id = 5;

-- combining these 2 seprate queries
select first_name, last_name
from customer
where customer_id = (
	select customer_id
	from invoice
	group by customer_id
	order by sum(total) desc limit 1
);
-- alternate method using inner join
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as invoice_total
from customer inner join invoice on customer.customer_id=invoice.customer_id
group by invoice.customer_id
order by invoice_total desc limit 1;


-- question set 2 : moderate
-- que1
select genre_id
from genre
where name ="Rock";-- genre_id=1

select * from track;

select track_id
from track
where genre_id=1;-- gives a column of tracks with rock genre

select invoice_id from invoice_line
where track_id in (
	select track_id
	from track
	where genre_id=1
);-- gives all the invoice_id of customers that listen to rock music

select customer_id from invoice
where invoice_id in(
	select invoice_id from invoice_line
	where track_id in (
		select track_id
		from track
		where genre_id=1)
)
union
select customer_id from invoice
where invoice_id in(
	select invoice_id from invoice_line
	where track_id in (
		select track_id
		from track
		where genre_id=1)
);-- gives unique customer_id of customers who listen to rock music.


select email, first_name, last_name
from customer
where customer_id in (
	select customer_id from invoice
	where invoice_id in(
		select invoice_id from invoice_line
		where track_id in (
			select track_id
			from track
			where genre_id=1)
		)
		union
	select customer_id from invoice
	where invoice_id in(
		select invoice_id from invoice_line
		where track_id in (
			select track_id
			from track
			where genre_id=1)
		)
)
order by email asc;-- answer for the question 1

-- alternate solution using inner join
select distinct customer.email, customer.first_name, customer.last_name, genre.name -- will only show unique entries if not used will show one customer multiple times !
from customer
	join invoice on customer.customer_id=invoice.customer_id
    join invoice_line on invoice.invoice_id=invoice_line.invoice_id
    join track on invoice_line.track_id=track.track_id
    join genre on track.genre_id=genre.genre_id
where genre.name like 'Rock'
order by email asc;-- applying multiple joins will result in a slower process. hence use nested queries with join for effecient query.


-- que2: using inner join
select artist.artist_id, artist.name, count(track.track_id)
from artist join album on artist.artist_id=album.artist_id
			join track on track.album_id=album.album_id
            join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by count(track.track_id) desc limit 10;


-- que3:
select name, milliseconds
from track
where milliseconds>= (select avg(milliseconds) from track)
order by milliseconds desc;-- dynamic query


-- question set 3: hard
-- que1:

create view best_selling_artist as
select artist.artist_id, artist.name, sum(invoice_line.unit_price*invoice_line.quantity)
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.artist_id
order by sum(invoice_line.unit_price*invoice_line.quantity) desc;

select * from best_selling_artist;

select customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_id, best_selling_artist.name, sum(invoice_line.unit_price*invoice_line.quantity)
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join best_selling_artist on best_selling_artist.artist_id=album.artist_id
group by 1, 2, 3, 4
order by 1 asc;

drop view best_selling_artist;


-- que2:
create view most_popular_genre as
select customer.country, count(invoice_line.quantity) as purchases, genre.name, genre.genre_id,
row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) as rowno-- row number function assigns a number to each row in serial number starting from 1,2,3... as per partition provided.
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice_line.invoice_id=invoice.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id=track.genre_id
group by 1, 3, 4
order by 1 asc, 2 desc;

drop view most_popular_genre;
select * from most_popular_genre
where rowno <= 1;

-- alternate method : using recurisive functions
with recursive 
	sales_per_country as (
		select count(*) as purchases_per_genre, customer.country, genre.name, genre.genre_id
        from customer
		join invoice on customer.customer_id=invoice.customer_id
		join invoice_line on invoice_line.invoice_id=invoice.invoice_id
		join track on track.track_id=invoice_line.track_id
		join genre on genre.genre_id=track.genre_id
        group by 2, 3, 4
        order by 2
	),
    max_genre_per_country as (
		select max(purchases_per_genre) as max_genre_number, country
        from sales_per_country
        group by 2
        order by 2)
select sales_per_country.*
from sales_per_country
join max_genre_per_country on sales_per_country.country=max_genre_per_country.country
where sales_per_country.purchases_per_genre=max_genre_per_country.max_genre_number;



-- que 3:
with customer_with_country as (
	select customer.customer_id, first_name, last_name, billing_country, sum(invoice.total) as total_spending,
    row_number() over (partition by billing_country order by sum(total) desc) as rowno
    from invoice
    join customer on customer.customer_id=invoice.customer_id
    group by 1, 2, 3, 4
    order by 4 asc, 5 desc)
select * from customer_with_country where rowno <=1;

-- alternate solution by recursive function
with recursive 
	customer_with_country as (
		select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
        from invoice
        join customer on customer.customer_id=invoice.customer_id
        group by 1, 4
        order by 1, 5 desc),
	country_max_spending as (
		select billing_country, max(total_spending) as max_spending
        from customer_with_country
        group by billing_country)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;

-- Rishabh mishra