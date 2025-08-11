use ds_july_2025;

select * from fifa limit 5;
# how many players are there in the dataset
select count(distinct Name) as players_count from fifa; # 15766
# How many nationalities do these players belong to?
select count(distinct Nationality) as Nation_cnt from fifa; # 161
# What is the total wage given to all players? What's the average and standard deviation?
select sum(wage) as toatalwage, round(avg(wage),2) as avg_wage, round(stddev(wage),2) as stddev_wage  from fifa ; #160073000	9618.04	22262.85

# Which nationality has the highest number of players, what are the top 3 nationalities by # of players?
select Nationality,count(distinct ID) as no_of_players from fifa group by Nationality order by no_of_players desc limit 3; 
#England	1475
#Germany	1151
#Spain	974
alter table fifa modify wage double;
# Which player has the highest wage? Who has the lowest?
select Name as max_paid from fifa where wage=(select max(wage) from fifa); #messi
select min(wage) from fifa;
select name as min_paid from fifa where wage=(select min(wage) from fifa); # min wagge is 1000 may plaers are getting paid 1000

alter table fifa modify overall integer;
#The player having the – best overall rating? Worst overall rating?
select Name as top_rated_player, overall as ratings from fifa where overall=(select max(overall) from fifa);
#L. Messi	94
#Cristiano Ronaldo	94
select Name as needs_improvement, overall as ratings from fifa where overall=(select min(overall) from fifa); # G. Nugent	46

#Club having the highest total of overall rating? Highest Average of overall rating?

select club, sum(overall) from fifa group by club 
order by sum(overall) desc limit 1; #FC Barcelona	2575

select club, avg(overall) from fifa group by club 
order by avg(overall) desc limit 1; #Juventus	82.2800

#What are the top 5 clubs based on the average 	ratings of their players and their corresponding 	averages?
select club, avg(overall) from fifa group by club 
order by avg(overall) desc limit 5; 

#What is the distribution of players whose preferred foot is left vs right?
select Preferred_Foot, count(distinct Name) as playerscnt, round(((count(distinct name)/(select count(distinct name) from fifa))*100),2) as percentage from fifa group by Preferred_Foot;
#Left	3758	23.84
# Right	12278	77.88

# Which jersey number is the luckiest?
select jersey_number from fifa where overall = (select max(overall) from fifa); # by ratings

#by popularity

select jersey_number,count(distinct name) from fifa group by jersey_number order by count(distinct name) desc limit 1;

# found 7 in both so  is the luckiest

#What is the frequency distribution of nationalities among players whose club name starts with M?
Select nationality, count(distinct id) as Player_Count from fifa where club like "M%" group by nationality ORDER BY Player_Count DESC ;

#How many players have joined their respective clubs in the date range 20 May 2018 to 10 April 2019 (both inclusive)?
alter table fifa add column dt datetime;
set sql_safe_updates=0;
UPDATE fifa
SET dt = STR_TO_DATE(joined, '%d-%m-%Y');
ALTER TABLE fifa DROP COLUMN joined;
ALTER TABLE fifa CHANGE COLUMN dt joined DATETIME;
SELECT COUNT(*) AS player_count
FROM fifa
WHERE Joined BETWEEN '2018-05-20' AND '2019-04-10'; #4543

# How many players have joined their respective clubs date wise?
select joined , count(distinct id) from fifa group by joined;
#How many players have joined their respective clubs yearly?
select year(joined), count(distinct id) from fifa group by year(joined);
