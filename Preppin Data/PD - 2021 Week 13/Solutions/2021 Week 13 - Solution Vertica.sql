--table sergiu.PL_Statistics added in Vertica from Tableau Prep output, write to database option
--union done in Tableau Prep

create view sergiu.pl_stats_all as
(select a.*,
a."Open Play Goals"/a.Appearances as "Open Play Goals/Appearances"
from 
(select 
Name,
"Position",
sum(Appearances) Appearances,
sum("Headed goals") "Headed goals",
sum("Goals with right foot") "Goals with right foot" ,
sum("Goals with left foot") "Goals with left foot",
sum(Goals) as "Total Goals",
sum(Goals-COALESCE("Penalties scored",0)-COALESCE("Freekicks scored",0)) as "Open Play Goals"
from sergiu.pl_statistics
where position<>'Goalkeeper' and Appearances<>0
group by name, position) a );

--create view sergiu.top_20_overall as
select *,
RANK() over (order by "Open Play Goals" desc) as Rank_Overall
from sergiu.pl_stats_all
order by RANK() over (order by "Open Play Goals" desc) asc
limit 20;

--create view sergiu.top_20_by_position as
select a.* from (
select *,
RANK() over (partition by "Position" order by "Open Play Goals" desc) as Rank_by_Position
from sergiu.pl_stats_all) a
where a.Rank_by_Position<=20 ;

