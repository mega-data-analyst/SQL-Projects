select *
from movies.film ;

# list of hit films which won oscars

select *
from movies.film
where BoxOfficeDollars > BudgetDollars and OscarWins > 0;


# list of films which is second part of that movie series

select
title,oscarwins
from movies.film
where title regexp ' 2| II' && title not regexp ' III' ;

# Text title,Alphanumeric title and numeric title

select 
title,
case
when title not regexp '[0-9]' then 'Text Title'
when title regexp '[a-z]'  then 'Alphanumeric Title'
else 'Numeric Title'
end TitleDesc
from movies.film;

# Short film,Avg length film,Long film

select
title,
runtimeminutes,
if(runtimeminutes < 100,'Short Film',if(runtimeminutes < 160,'Avg Length Film','Long Film')) as MovieType
from movies.film;

# Classic blockbuster and blockbuster 

select 
title,
boxofficedollars,
oscarwins,
case
when boxofficedollars > 1e9 and oscarwins > 0 then 'Classic Blockbuster'
when boxofficedollars > 1e9 then 'Blockbuster'
else 'others'
end as MovieType
from movies.film;

# Top 10 Highest Grossing Films (BoxofficeDollars) of all time

select 
title,
BoxofficeDollars
from movies.film 
order by BoxofficeDollars desc limit 10; 

# Top 5 Youngest Female Actors List

select
concat(FirstName,' ',FamilyName) as FullName,
DoB,
Gender
from movies.actor
where Gender= 'Female'
order by DoB desc limit 5 ;

# Movies list by highest to lowest oscars,then by BoxofficeDollars in desc

select
title,
oscarwins,
BoxOfficeDollars
from movies.film 
order by oscarwins desc,BoxOfficeDollars desc;

# The count of hit films which won oscar and avg boxofficedollars of oscar winning films only

select
count(case when boxofficedollars > budgetdollars and oscarwins > 0 then 1 end) as HitOscars,
avg(case when oscarwins > 0 then boxofficedollars end) as avgBO_wins
from movies.film;

# The count of films by oscarwins

select
oscarwins,
count(*) as no_of_films
from movies.film
group by OscarWins
order by OscarWins;

# Average runtime by Genre 

select
genre,
avg(runtimeminutes) as avgruntime
from movies.film f inner join movies.genre g on f.GenreID=g.GenreID
group by genre 
order by avgruntime desc;

# The list of actors who are also directors

select
a.FullName,
d.FullName
from movies.actor a inner join movies.director d on a.Fullname=d.fullname;

# The list of actors only(not directors)

select
a.FullName,
d.FullName
from movies.actor a left join movies.director d on a.Fullname=d.fullname
where d.FullName is null;

# The list of directors only(not actors)

select
a.FullName,
d.FullName
from movies.actor a right join movies.director d on a.Fullname=d.fullname
where a.FullName is null;

# The count of different genres directed by each director,sorted by most versatile Director
  
select 
d.FullName as director,
count(distinct genre) as genre_count,
count(*) as no_of_films,
group_concat(distinct genre)
from movies.film f inner join movies.director d on f.directorID =  d.DirectorID
inner join movies.genre g on f.GenreID=g.GenreID
group by director
order by genre_count desc;

# The count of hit,flop film by genre

select 
genre,
count(*) as no_of_films,
count(case when BoxOfficeDollars > BudgetDollars then 1 end) as Hits,
count(case when BoxOfficeDollars < BudgetDollars then 1 end) as Flops,
count(case when BoxOfficeDollars is null or BudgetDollars is null then 1 end) as checknulls
from movies.film f inner join movies.genre g on f.genreID=g.GenreID
group by Genre;

# Highest grossing film of each director
 
 with dm as
 (select 
 title,
 Fullname,
 BoxOfficeDollars,
 row_number() over(partition by Fullname order by boxofficedollars desc) as rw
 from movies.film f inner join movies.director d on f.directorID=d.directorID)
 select * 
 from dm where rw=1 ;

# Top 3 films by runtimeminutes in each genre
 
with dw as
(select
title,
genre,
runtimeminutes,
row_number() over(partition by genre order by Runtimeminutes desc) as rw
from movies.film f inner join movies.genre g on f.GenreID=g.GenreID)
select 
title,
genre,
runtimeminutes
from dw 
where rw <= 3;

 # Youngest actor by gender
 
with de as
(select 
fullname as actor,
dob,
gender,
row_number() over(partition by gender order by dob desc) as rw
from movies.actor)
select 
actor, 
dob,
gender
from de where rw = 1 ;

# The list of films with runtime more than avgruntime of all films in that genre

with gavg as
(select
title,
runtimeminutes,
genre,
avg(runtimeminutes) over(partition by genre) as avgruntime
from movies.film f inner join movies.genre g on f.GenreID=g.GenreID)
select *
from gavg where runtimeminutes > avgruntime; 

# The list of films in each year with runtime more than avgruntime of all films in that year

with gavg as
(select
title,
runtimeminutes,
year(releasedate) as year,
avg(runtimeminutes) over(partition by year(releasedate)) as avgruntime
from movies.film f inner join movies.genre g on f.GenreID=g.GenreID)
select *
from gavg where runtimeminutes > avgruntime; 
