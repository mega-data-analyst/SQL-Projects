# The list of players with highest number of man of the matches

select
player_name,
count(*) as mom 
from ipl.match m inner join ipl.player p on m.Man_of_the_Match=p.Player_Id
group by Player_Name
order by mom desc;

# The count of matches won by each team

select
team_name,
count(*) as match_wins 
from ipl.match m inner join ipl.team t on m.Match_Winner=t.Team_Id
group by Team_Name
order by match_wins desc;

# The count of matches played in each venue

select
venue_name,
count(*) as venue_matches 
from ipl.match m inner join ipl.venue v on m.Venue_Id=v.Venue_Id
group by venue_name
order by venue_matches desc;

# The count of matches played in each team

select
team_name,
count(*) as match_played 
from ipl.match m inner join ipl.team t on m.Team_1=t.Team_Id or m.Team_2=t.Team_Id
group by Team_Name
order by match_played desc;

# The count of matches in which toss by each team

select
team_name,
count(*) as toss_wins 
from ipl.match m inner join ipl.team t on m.Toss_Winner=t.Team_Id
group by Team_Name
order by toss_wins desc;

# The number of players in IPL from each country

select
c.Country_Name,
count(*) as player_count,
group_concat(player_name) as playerlist 
from ipl.player p inner join ipl.country c on p.Country_Name =c.Country_Id
group by Country_Name
order by player_count desc;

# City name, country name of each venue, sorted by countries - India,UAE and others

select 
venue_name,
City_Name,
Country_Name
from ipl.venue v inner join ipl.city c on v.City_Id = c.City_Id
inner join ipl.country co on c.Country_id = co.Country_Id
order by case
when country_name= 'India' then 1
when country_name= 'U.A.E' then 2
else 3
end;

# Total venues in the countries

select 
Country_Name,
count(*) as no_of_venues
from ipl.venue v inner join ipl.city c on v.City_Id = c.City_Id
inner join ipl.country co on c.Country_id = co.Country_Id
group by country_name
order by no_of_venues desc;

# Joining all tables together

select 
Match_Date,
t.Team_Name as Team1,
t2.Team_Name as Team2,
t3.Team_Name as TossWinner,
t4.Team_Name as MatchWinner,
Venue_Name  
from ipl.match m inner join ipl.team t on m.team_1= t.team_id
inner join ipl.team t2 on m.team_2= t2.team_id
inner join ipl.team t3 on m.toss_winner= t3.team_id
inner join ipl.team t4 on m.match_winner= t4.team_id
inner join ipl.venue v on m.venue_id= v.venue_id ;

# Man of the series,orange cap player and purple cap player in each season

select
season_year as year,
p.Player_Name as man_of_the_series,
p1.Player_Name as orange_cap,
p2.Player_Name as purple_cap
from ipl.season s inner join ipl.player p on s.Man_of_the_Series = p.Player_Id 
inner join ipl.player p1 on s.Orange_Cap = p1.player_id
inner join ipl.player p2 on s.Purple_Cap = p2.Player_Id;

# The list of players who bat and bowl in different hands
  
select
player_name,
b.batting_hand as batting_hand,
bo.bowling_skill as bowling_skill
from ipl.player p inner join ipl.batting_style b on p.Batting_hand = b.Batting_Id 
inner join ipl.bowling_style bo on p.Bowling_skill = bo.Bowling_Id
where (b.batting_hand like '%Right%' and  bo.bowling_skill like '%Left%') or
(b.batting_hand like '%Left%' and  bo.bowling_skill like '%Right%');

# Highest run scoring matches in ipl

select
match_date,
t.Team_name as team1,
t2.Team_name as team2, 
sum(runs_scored) as total_runs
from ipl.batsman_scored bs  
inner join ipl.match m on bs.match_id = m.match_id
inner join ipl.Team t on m.team_1 = t.team_id
inner join ipl.Team t2 on m.team_2 = t2.team_id 
group by match_date,team1,team2
order by total_runs desc;

# Highest run-scoring players in ipl

select
Player_Name,
sum(Runs_scored) as totalruns
from ipl.ball_by_ball b inner join ipl.batsman_scored bs on
b.Ball_Id = bs.Ball_Id and b.Over_Id = bs.Over_Id and b.Innings_No = bs.Innings_No
and b.Match_Id = bs.Match_Id 
inner join ipl.player p on b.Striker = p.Player_Id
group by player_name
order by totalruns desc;

# The player with most number of sixes in ipl

select
Player_Name,
count(runs_scored) as no_of_sixes
from ipl.ball_by_ball b inner join ipl.batsman_scored bs on
b.Ball_Id = bs.Ball_Id and b.Over_Id = bs.Over_Id and b.Innings_No = bs.Innings_No
and b.Match_Id = bs.Match_Id 
inner join ipl.player p on b.Striker = p.Player_Id
where Runs_Scored = 6
group by player_name
order by no_of_sixes desc;

# The list of players who captained most number of matches

select
Player_name,
count(Role_Desc) as captainedmatches
from ipl.player_match pm inner join ipl.player p on pm.Player_Id = p.player_id
inner join ipl.rolee r on pm.Role_Id = r.Role_Id
where role_desc like 'captain%'
group by player_name
order by captainedmatches desc;

# The count of captains from each team

select
Team_Name,
count(distinct Player_Name ) as no_of_captains,
group_concat( distinct player_name) as playerList
from ipl.player_match pm inner join ipl.player p on pm.Player_Id = p.player_id
inner join ipl.rolee r on pm.Role_Id = r.Role_Id
inner join ipl.team t on pm.Team_Id = t.Team_Id
where role_desc like 'captain%'
group by Team_Name
order by no_of_captains desc;