#create a table with union
create table stores as
(select 'Manchester' store, manchester.* from manchester
union
select 'Birmingham' store, birmingham.* from birmingham
union
select 'Leeds' store, leeds.* from leeds
union
select 'London' store, london.* from london
union
select 'York' store, york.* from york);

create view stores_data as
(select p.store,
quarter(STR_TO_DATE(p.date,'%d/%m/%Y')) quarter,
p.products_sold,
SUBSTRING_INDEX(p.c_product,' - ',1) customer_type,
SUBSTRING_INDEX(p.c_product,' - ',-1) product
from
#pivot
(select stores.store,stores.date,stores.`New - Saddles` products_sold, 'New - Saddles' c_product from stores
union
select stores.store,stores.date,stores.`New - Mudguards` products_sold, 'New - Mudguards' c_product from stores
union
select stores.store,stores.date,stores.`New - Wheels` products_sold, 'New - Wheels' c_product from stores
union
select stores.store,stores.date,stores.`New - Bags` products_sold, 'New - Bags' c_product from stores
union
select stores.store,stores.date,stores.`Existing - Saddles` products_sold, 'Existing - Saddles' c_product from stores
union
select stores.store,stores.date,stores.`Existing - Mudguards` products_sold, 'Existing - Mudguards' c_product from stores
union
select stores.store,stores.date,stores.`Existing - Wheels` products_sold, 'Existing - Wheels' c_product from stores
union
select stores.store,stores.date,stores.`Existing - Bags` products_sold, 'Existing - Bags' c_product from stores) p);

create view stores_data_customer_product as 
select customer_type, product, store, sum(products_sold) products_sold from stores_data 
group by 1,2,3;

create view stores_data_product_quarter as 
select product, quarter, sum(products_sold) products_sold from stores_data 
group by 1,2;


