# replace $ and "." and cast as integer
create temporary table golf_cleaned as 
(select `player name` player_name, 
cast(Replace(Replace(money,"$",""),".","") as unsigned) Money,
Events,
Tour
from preppindata.2021week6);

create temporary table metrics_per_player as
# create ranks on players
(select *, 
rank() over (partition by tour order by total_prize_money desc) rank_by_tour,
rank() over (order by total_prize_money desc) rank_overall,
rank() over (order by total_prize_money desc) - rank() over (partition by tour order by total_prize_money desc) rank_difference
from 
# create basic measures per players
(select player_name,
tour,
money total_prize_money,
events total_events,
money/events money_per_events,
count(player_name) players
from golf_cleaned
group by 
player_name,
tour,
money,
events,
money/events) a);

# aggregate measures per tour
create temporary table metrics_per_tour as
(select 
tour,
sum(total_prize_money) total_prize_money,
sum(total_events) total_events,
avg(money_per_events) money_per_events,
avg(rank_difference) rank_difference,
sum(players) players
from metrics_per_player
group by tour)

# Pivot columns to rows. Make measures to be one column.
# Unfortunately, MySQL does not have PIVOT function. Generally, union (all) is used as a solution for pivot data. 
# But here I used temporary tables and union does not work on temp. tables. As workaround, I created a temporary table and insert data into.
Create temporary table for_union
(tour varchar(4),
measure varchar(50),
value decimal(15,2));
insert into for_union 
select tour, "total_prize_money" measure, total_prize_money value from metrics_per_tour;
insert into for_union
select tour, "total_events" measure, total_events value from metrics_per_tour;
insert into for_union
select tour, "money_per_events" measure, money_per_events value from metrics_per_tour;
insert into for_union
select tour, "rank_difference" measure, rank_difference value from metrics_per_tour;
insert into for_union
select tour, "players" measure, players value from metrics_per_tour;

# Pivot the data so that we have a column for each tour. Pivot rows to columns.
# Unfortunately, MySQL does not have PIVOT function, so in order to rotate data from rows into columns
# we have to use a CASE expression along with an aggregate function.
select 
measure,
sum(case when tour='PGA' then value else 0 end) PGA,
sum(case when tour='LPGA' then value else 0 end) LPGA
from for_union
group by measure;
 
