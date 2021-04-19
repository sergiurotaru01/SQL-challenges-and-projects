create temporary table aminfo
select Client, `Client ID`, `Account Manager`, STR_TO_DATE(`From Date`,'%d/%m/%Y') `From Date`
from preppindata.`2021week5`;

create temporary table traininginfo
select Client, Training, `Contact Email`, `Contact Name`
from preppindata.`2021week5`;

drop temporary table mostrecentdate;
create temporary table mostrecentdate
select Client, max(`From Date`) `Most Recent Date`
from aminfo
group by Client;


select a.Client, a.`Client ID`, a.`Account Manager`, a.`From Date`, t.Training, t.`Contact Email`, t.`Contact Name` from aminfo a
inner join mostrecentdate m on a.`From Date`= m.`Most Recent Date` and a.Client=m.Client
inner join traininginfo t on a.Client=t.Client