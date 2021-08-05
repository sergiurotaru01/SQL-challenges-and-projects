alter table sergiu.Keywords_csv, sergiu.Shopping_List_and_Ingredients_csv rename to keywords,shopping_list;

create or replace view shopping_list_keywords as

--Add an 'E' in front of every E number.
--Stack Animal Ingredients and E Numbers on top of each other.
with keywords_stacked as
(SELECT "Animal Ingredients"
keywords from sergiu.keywords
union all
select REGEXP_REPLACE("E Numbers", '(\d{3})', 'E\1') keywords
FROM sergiu.keywords),

--Get every ingredient and E number onto separate rows.
--Does exist a better solution for split all in Vertica?
keywords_for_join as(
select lower(keywords) keywords from (
select split_part (keywords,', ',1) keywords from keywords_stacked union all
select split_part (keywords,', ',2) keywords from keywords_stacked union all
select split_part (keywords,', ',3) keywords from keywords_stacked union all
select split_part (keywords,', ',4) keywords from keywords_stacked union all
select split_part (keywords,', ',5) keywords from keywords_stacked union all
select split_part (keywords,', ',6) keywords from keywords_stacked union all
select split_part (keywords,', ',7) keywords from keywords_stacked union all
select split_part (keywords,', ',8) keywords from keywords_stacked union all
select split_part (keywords,', ',9) keywords from keywords_stacked union all
select split_part (keywords,', ',10) keywords from keywords_stacked union all
select split_part (keywords,', ',11) keywords from keywords_stacked union all
select split_part (keywords,', ',12) keywords from keywords_stacked union all
select split_part (keywords,', ',13) keywords from keywords_stacked union all
select split_part (keywords,', ',14) keywords from keywords_stacked union all
select split_part (keywords,', ',15) keywords from keywords_stacked union all
select split_part (keywords,', ',16) keywords from keywords_stacked ) a
where a.keywords<>''),

--Append the keywords onto the product list.
--Check whether each product contains any non-vegan ingredients.
shopping_list_joined as (
SELECT *,
regexp_ilike("Ingredients/Allergens",keywords) contains
FROM sergiu.shopping_list sl
join keywords_for_join kj on 1=1)

select * from shopping_list_joined;

--Output 1: Non Vegan List
--Write a calculation to concatenate all the keywords into a single comma-separated list for each product, e.g. "whey, milk, egg".
--Solution in Vertica - Listagg. Simpler than Tableau Prep solution (pivot rows to columns, concatenate with ifnull calculations). Group_concat in MySQL.
select "?Product", Description,
listagg(keywords)
from shopping_list_keywords
where contains is true
group by "?Product", Description;

--Output 2: Vegan List
select "?Product", Description from (
select "?Product", Description,
max(contains) contains
from shopping_list_keywords
group by "?Product", Description) c
where contains is false;




