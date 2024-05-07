select * from OLYMPICS_HISTORY_NOC_REGIONS;
select * from olympics_history;

--1 How many olympics games have been held?
select count(distinct games) as total_olympic_games from olympics_history;


--2 List down all Olympics games held so far.
select distinct year, season, city from olympics_history
order by year;


--3 SQL query to fetch total no of countries participated in each olympic games.
select * from olympics_history;


with all_countries as
(select games, nr.region
from olympics_history oh
join OLYMPICS_HISTORY_NOC_REGIONS nr on oh.noc = nr.noc
group by games, nr.region)
select games, count(region)
from all_countries
group by games
order by games;


--4 Write a SQL query to return the Olympic Games which had the highest participating
--countries and the lowest participating countries.

select * from olympics_history;

with all_countries as
(select games, region
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
group by games, region),
   tot_countries as
   (select games, count(region) as total_countries from
   all_countries
   group by games)
select distinct
concat(first_value(games) over(order by total_countries), '-',
first_value(total_countries) over(order by total_countries)) as lowest_countries,
concat(first_value(games) over(order by total_countries desc), '-',
first_value(total_countries) over(order by total_countries desc)) as highest_countries
from tot_countries;


--6 SQL query to return the list of countries who have been part of every Olympics games.

select * from olympics_history;
select * from olympics_history_noc_regions
order by region;


with countries as 
(select region as country, games
from olympics_history oh
join olympics_history_noc_regions nr on oh.noc = nr.noc
group by region, games),
    tot_games as
	(select count(distinct games) as total_olympic_games from olympics_history),
	participated_countries as
	(select country, count(games) as total_participated_games
	from countries
	group by country)
select * from participated_countries pc
join tot_games tg on pc.total_participated_games = tg.total_olympic_games;


--7 SQL query to fetch the list of all sports which have been part of every summer olympics.
select * from olympics_history;

with games as
(select sport, count(distinct games) as no_of_games from olympics_history
where season = 'Summer'
group by sport),
      tot_games as
	  (select count(distinct games) as total_games from olympics_history where season = 'Summer')
select sport, gm.no_of_games, tg.total_games
from games gm
join tot_games tg on gm.no_of_games = tg.total_games;


--8 Using SQL query, Identify the sport which were just played once in all of olympics.
select * from olympics_history;

with t1 as
(select  distinct games, sport
from olympics_history
order by games),
 t2 as
 (select sport, count(games) as  no_of_games
  from t1
  group by sport)
select t1.games, t2.*
from t1 join t2 on t1.sport = t2.sport
where t2.no_of_games = 1;


--9 Write SQL query to fetch the total no of sports played in each olympics.

select * from olympics_history;
-- solution 1
select games, count(distinct sport) as no_of_sports
from olympics_history
group by games
order by no_of_sports desc;

-- solution 2
 with t1 as
      	(select distinct games, sport
      	from olympics_history),
        t2 as
      	(select games, count(1) as no_of_sports
      	from t1
      	group by games)
      select * from t2
      order by no_of_sports desc;

--SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.
 with t1 as
         (select name,sex, cast(case when age = 'NA' then '0' else age end as int) as age,
		  team, games, city, sport, event, medal
          from olympics_history),
     t2 as
	   (select *, rank() over(order by age desc) as rnk
	    from t1
	    where medal='Gold')
  select * 
  from t2
  where rnk = 1;

 
--Write a SQL query to get the ratio of male and female participants

select * from olympics_history;

select sum(case when sex = 'M' then 1 else 0 end )


--SQL query to fetch the top 5 athletes who have won the most gold medals.
with t1 as
        (select name, team, count(medal) as total_gold_medals
         from olympics_history
		 where medal = 'Gold'
         group by name, team
         order by total_gold_medals desc),
	 t2 as 
	    (select *, dense_rank() over(order by total_gold_medals desc) as rnk
		from t1
		)
 select * from t2
 where rnk <= 5;

-- SQL Query to fetch the top 5 athletes who have won the most medals 
--(Medals include gold, silver and bronze).

with t1 as
        (select name, team, count(medal) as total_medal
         from olympics_history
         where medal in ('Gold','Silver','Bronze')
         group by name, team),
	 t2 as 
	    (select *, dense_rank() over(order by total_medal desc) as rnk
		from t1)
 select name, team, total_medal from t2
 where rnk <= 5;
	 
--Write a SQL query to fetch the top 5 most successful countries in olympics.
--(Success is defined by no of medals won).
select * from olympics_history;

with t1 as
       (select region as country, count(medal) as total_medals
       from olympics_history oh
       join olympics_history_noc_regions nr on oh.noc = nr.noc
		where medal in ('Gold','Silver','Bronze')
       group by country),
	  t2 as
      (select *, dense_rank() over(order by total_medals desc) as rnk
      from t1)
 select * from t2
 where rnk <= 5;
 
--Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
 
 select * from olympics_history;
with t1 as 
       (select region as country, medal
       from olympics_history oh
       join olympics_history_noc_regions nr on oh.noc = nr.noc
		where medal in ('Gold','Silver','Bronze')),
	t2 as 
	   (select country, sum(case when medal = 'Gold' then 1 else 0 end) as Gold,
	           sum(case when medal = 'Silver' then 1 else 0 end) as Silver,
	            sum(case when medal = 'Bronze' then 1 else 0 end) as Bronze
			from t1
			group by country
	        order by 2 desc)
 select * from t2;
			
--Write a SQL query to list down the  total gold, silver and bronze medals won by each country 
--corresponding to each olympic games.
 
with t1 as 
       (select games, region as country, medal
       from olympics_history oh
       join olympics_history_noc_regions nr on oh.noc = nr.noc
		where medal in ('Gold','Silver','Bronze')
	   order by games),
	t2 as 
	   (select games, country, sum(case when medal = 'Gold' then 1 else 0 end) as Gold,
	           sum(case when medal = 'Silver' then 1 else 0 end) as Silver,
	            sum(case when medal = 'Bronze' then 1 else 0 end) as Bronze
			from t1
			group by games, country
	        order by games, country)
 select * from t2;


--Write a SQL query to list down the  total gold, silver and bronze medals won by each country 
--corresponding to each olympic games.
select * from olympics_history;

with t1 as
         (select games, region as country, medal
          from olympics_history oh
          join olympics_history_noc_regions nr on oh.noc = nr.noc
          where medal in ('Gold','Silver','Bronze')
          order by games)
 select games, country,
 sum(case when medal = 'Gold' then 1 else 0 end) as Gold,
 sum(case when medal = 'Silver' then 1 else 0 end) as Silver,
 sum(case when medal = 'Bronze' then 1 else 0 end) as Bronze
 from t1
 group by country, games
 order by games, country; 

--Write SQL query to display for each Olympic Games, which country won the highest gold, silver 
--and bronze medals.

select games, region as country, medal
from olympics_history oh join olympics_history_noc_regions nr
on oh.noc = nr.noc
where medal in ('Gold','Silver','Bronze')
order by games

--Write SQL Query to return the sport which has won India the highest no of medals
with t1 as
         (select sport, count(medal) as total_medals
          from olympics_history oh join olympics_history_noc_regions nr
          on oh.noc = nr.noc
          where region = 'India' and medal in ('Gold','Silver','Bronze')
          group by sport),
	 t2 as
	    (select *, dense_rank() over(order by total_medals desc) as rnk
	     from t1)
  select * from t2
  where rnk = 1;

--solution 2
with t1 as
        (select sport, COUNT(medal) as total_medals
         from olympics_history
        where team = 'India' and
        medal <> 'NA'
         group by sport),
     t2 as
	    (select *, rank() over(order by total_medals desc) as rnk
		from t1)
 select sport, total_medals from t2 
 where rnk = 1;


--Write an SQL Query to fetch details of all Olympic Games where India won medal(s) in hockey. 

select team, sport, games, count(medal) as total_medals
         from olympics_history
        where team = 'India' and
        medal <> 'NA' and sport = 'Hockey'
		group by games, team, sport
		order by total_medals desc;
         

select * from olympics_history;




























