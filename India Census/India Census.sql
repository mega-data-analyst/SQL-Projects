select * from indiacensus..Data1;

select * from indiacensus..Data2;

-- number of rows into our dataset

select COUNT(*) from indiacensus..Data1;

select COUNT(*) from indiacensus..Data2;

-- dataset from Jharkhand and Bihar

select * from indiacensus..Data1 
where State in ('Jharkhand','Bihar');

-- population of India

select SUM(population) as Population from indiacensus..Data2;

-- avg growth 

select 
state,
AVG(growth)*100 as avg_growth 
from indiacensus..Data1
group by State;

-- avg sex ratio

select 
state,
round(AVG(sex_ratio),0) as avg_sex_ratio
from indiacensus..Data1
group by state
order by avg_sex_ratio desc;

-- avg literacy rate

select 
state,
round(AVG(Literacy),0) as avg_literacy_ratio
from indiacensus..Data1
group by state
having round(AVG(Literacy),0) > 90
order by avg_literacy_ratio desc;

-- top 3 state showing highest growth ratio

select 
top 3 state,
AVG(growth)*100 as avg_growth 
from indiacensus..Data1
group by State
order by avg_growth desc;

-- bottom 3 state showing lowest sex ratio

select 
top 3 state,
round(AVG(sex_ratio),0) as avg_sex_ratio
from indiacensus..Data1
group by state
order by avg_sex_ratio;

-- top and bottom 3 states in literacy state

drop table if exists top_literacy_state
create table top_literacy_state 
(state nvarchar(255),
literacy float);

insert into top_literacy_state
select 
state,
round(AVG(Literacy),0) as avg_literacy_ratio
from indiacensus..Data1
group by state
order by avg_literacy_ratio desc;

select top 3 * from top_literacy_state
order by literacy desc;

drop table if exists bottom_literacy_state
create table bottom_literacy_state 
(state nvarchar(255),
literacy float);

insert into bottom_literacy_state
select 
state,
round(AVG(Literacy),0) as avg_literacy_ratio
from indiacensus..Data1
group by state
order by avg_literacy_ratio;

select top 3 * from bottom_literacy_state
order by literacy;

-- union operator

select * from (select top 3 * from top_literacy_state
order by literacy desc) a
union
select * from (select top 3 * from bottom_literacy_state
order by literacy) b;

-- states starting with letter a or b

select distinct State from indiacensus..Data1 
where state like 'a%' or state like 'b%'

-- states starting with letter a and ending with m

select distinct State from indiacensus..Data1 
where state like 'a%' and state like '%m'

-- joining both table

select 
a.district,
a.State,
sex_ratio,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District;
		
-- total males and females by district

with cte as
(select 
a.district,
a.State,
sex_ratio/1000 as sex_ratio,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District)
select
district,
state,
population,
round(population/(sex_ratio + 1),0) as males,
round((population *sex_ratio)/(sex_ratio+1),0) as females 
from cte;

-- total males and females by state

select
d.state,
sum(population) as total_population,
sum(d.males) as total_males,
sum(d.females) as total_females
from
(select
c.district,
c.state,
c.population,
round(c.population/(c.sex_ratio + 1),0) as males,
round((c.population * c.sex_ratio)/(c.sex_ratio+1),0) as females 
from
(select 
a.district,
a.State,
sex_ratio/1000 as sex_ratio,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District) c)d
group by d.state;

-- total literacy rate by district

with cte as
(select 
a.district,
a.State,
a.Literacy/100 as literacy_ratio,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District)
select
district,
state,
population,
round(literacy_ratio * population,0) as literate_people,
round(population* (1-literacy_ratio),0) as illiterate_people
from cte;

-- total literacy rate by state

select
state,
sum(d.population) as total_population,
sum(d.literate_people) as total_literate,
sum(d.illiterate_people) as total_illiterate
from
(select
c.district,
c.state,
c.population,
round(c.literacy_ratio * c.population,0) as literate_people,
round(c.population* (1- c.literacy_ratio),0) as illiterate_people
from
(select 
a.district,
a.State,
a.Literacy/100 as literacy_ratio,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District) c)d
group by state;

-- population in previous census by district

with cte as
(select 
a.district,
a.State,
a.Growth as growth_rate,
population as current_population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District)
select
district,
state,
current_population,
round(current_population/(1 + growth_rate),0) as previous_census
from cte;

-- population in previous census by state

select
d.state,
sum(d.current_population) as current_population,
sum(d.previous_census) as total_previous_census
from
(select
c.district,
c.state,
c.population as current_population,
round(c.population/(1 + c.growth_rate),0) as previous_census
from
(select 
a.district,
a.State,
a.Growth as growth_rate,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District) c)d
group by d.State;

-- population in previous census

select
sum(e.current_population) as total_current_population,
sum(e.total_previous_census) as total_previous_census
from
(select
d.state,
sum(d.current_population) as current_population,
sum(d.previous_census) as total_previous_census
from
(select
c.district,
c.state,
c.population as current_population,
round(c.population/(1 + c.growth_rate),0) as previous_census
from
(select 
a.district,
a.State,
a.Growth as growth_rate,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District) c)d
group by d.State)e;

-- population vs area

select 
round((g.total_area/g.total_current_population)* 1000000000,0) as current_areakm2,
round((g.total_area/g.total_previous_census)* 1000000000,0) as previous_areakm2
from
(select 
z.total_current_population,
z.total_previous_census,
v.total_area
from
(select '1' as keyy, x.* from
(select
sum(e.current_population) as total_current_population,
sum(e.total_previous_census) as total_previous_census
from
(select
d.state,
sum(d.current_population) as current_population,
sum(d.previous_census) as total_previous_census
from
(select
c.district,
c.state,
c.population as current_population,
round(c.population/(1 + c.growth_rate),0) as previous_census
from
(select 
a.district,
a.State,
a.Growth as growth_rate,
population
from indiacensus..Data1 a
join
indiacensus..Data2 b
on a.District = b.District) c)d
group by d.State) e) x) z
join
(select '1' as keyy, y.* from
(select sum(area_km2) total_area from indiacensus..Data2)y) v
on z.keyy = v.keyy)g;

-- window function

--top 3 districts from each state with highest literacy rate

with cte as
(select
district,
state,
literacy,
rank() over(partition by state order by literacy desc) as rnk
from indiacensus..Data1)
select
district,
state,
literacy
from cte
where rnk in (1,2,3)
order by state;

--bottom 3 districts from each state with highest literacy rate

with cte as
(select
district,
state,
literacy,
rank() over(partition by state order by literacy) as rnk
from indiacensus..Data1)
select
district,
state,
literacy
from cte
where rnk in (1,2,3)
order by state;