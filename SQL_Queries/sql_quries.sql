# Part 2&3

# a. How many:
## a.1. Store shopping trips are recorded in your database?  
select count(TC_id) as total_trips from trips;

## Answer: there are 7596145 store shopping trips in total.


## a.2. Households appear in your database?
select count(hh_id) as total_households from households;
select count(distinct hh_id) from trips;
## Answer: there are 39577 households in total.


## a.3. Stores of different retailers appear in our data base?
select TC_retailer_code, count(distinct TC_retailer_code_store_code) as total_stores from trips
where TC_retailer_code_store_code is not null and TC_retailer_code is not null
group by TC_retailer_code;

## Answer: there are 863 retailers in total.


## a.4. Different products are recorded?
select count(prod_id) from products;

## Answer: there are 4231283 different products are recorded in total.


## a.4.i. Products per category and products per module
select group_at_prod_id, count(prod_id) as product_per_category  from products 
where group_at_prod_id is not null
group by group_at_prod_id;

## Answer: there are 118 rows returned.


select module_at_prod_id, count(prod_id) as product_per_module  from products 
where module_at_prod_id is not null
group by module_at_prod_id;

## Answer: there are 1224 rows returned


## a.4.ii. Plot the distribution of products and modules per department

select count(distinct module_at_prod_id) from products ; ##1224
select count(distinct department_at_prod_id) from products ; ## 11

select department_at_prod_id as department, count(prod_id) as total_prod_per_department from products 
where department_at_prod_id is not null group by department_at_prod_id;

select department_at_prod_id as department, count(distinct module_at_prod_id) as total_module_per_department from products  
where department_at_prod_id is not null group by department_at_prod_id;


## a.5 Transactions?
## a.5.i Total transactions and transactions realized under some kind of promotion
select count(TC_id) as total_transaction from trips;

## Answer : there are 7596145 transactions in total

select count(distinct TC_id) from purchases where coupon_value_at_TC_prod_id <> 0;

## Answer: there are 1138047 transactions realized under some kind of promotion


## b.1. How many households do not shop at least once on a 3 month periods.
with t1 as
(select distinct hh_id, extract(year_month from TC_date) as monthly_date
 from trips),
t2 as
(select *,
row_number() over(partition by hh_id order by monthly_date desc) as rank_decreasing 
 from t1),
t3 as
(select hh_id, monthly_date, rank_decreasing+1 as new_rank 
 from t2)
select t3.hh_id, t2.monthly_date, t3.monthly_date, 
period_diff(t3.monthly_date, t2.monthly_date) as month_gap 
from t3 
left join t2
on t2.hh_id = t3.hh_id and t2.rank_decreasing = t3.new_rank
where period_diff(t3.monthly_date, t2.monthly_date) >= 3;

## b.1.i. Is it reasonable? 

## Answer: this is not reasonable because for a normal household, it's almost impossible to not shop in 3 months period. 


## b.1.ii. Why do you think this is occurring?

## Answer: The reason why this is occurring is that there might be someone who seldomly go shopping, 
## instead, they usually recieve donations from others(the charity, neighbors). Those data is kind of weird
## as a result, we decided to exclude those data!


## b.2. Loyalism: Among the households who shop at least once a month, which % of them 
#concentrate at least 80% of their grocery expenditure (on average) on single retailer? And among 2 retailers?  

## creating Loyality table which includes households who shop at least once a month on grocery
create table Loyality
with t1 as
(SELECT distinct hh_id, extract(year_month from TC_date) as monthly_date, TC_date
from trips),
t2 as
(select *, 1 as count1, 
row_number() over(partition by hh_id order by monthly_date desc) as rank_decreasing 
from t1),
t3 as
(select hh_id, count(count1) as shopping_total_month from t2 group by hh_id),
t4 as
(select hh_id, shopping_total_month from t3
where shopping_total_month >=12),
t6 as
(select t4.hh_id, t4.shopping_total_month, t5.TC_id, t5.TC_retailer_code from t4 
inner join dta_at_TC t5
using(hh_id)),
t7 as
(select TC_id, total_price_paid_at_TC_prod_id, prod_id from dta_at_TC_upc),
t8 as
(select * from t6
inner join t7 using(TC_id)),
t9 as 
(select department_at_prod_id, prod_id from products)
 select * from t8
 inner join t9 using(prod_id)  
 where department_at_prod_id regexp '(GROCERY)';

## creating the loyality_month table which adds month based on table loyality
create table loyality_month
with t1 as
(SELECT distinct hh_id, TC_id, month(TC_date) monthly
from trips)
select hh_id, prod_id, TC_id, monthly, loyality.TC_retailer_code, 
total_price_paid_at_TC_prod_id from loyality 
inner join t1
using(hh_id, TC_id);


## creating monthly_total_spend_per_retailer table which includes total monthly spend in each retailer of each household
create table monthly_total_spend_per_retailer
select distinct hh_id, monthly, TC_retailer_code, sum(total_price_paid_at_TC_prod_id) as monthly_spend_per_retailer
from loyality_month group by hh_id, monthly, TC_retailer_code;




## Assumptions: when a household concentrate at least 80% of their grocery expenditure on single retailer or two retailers 
## at least in 11 months, then we call this household is loyal.  We choose 11 months becasue if we restrict the condition as the 
## whole year(12 months), there are only 13 households which are difficult to visualize and analyze.

## counting the amount of households who are loyal to one retailers in 11 months.
with t1 as
(select hh_id, sum(monthly_spend_per_retailer)/12 as avg_total_spend 
from monthly_total_spend_per_retailer group by hh_id),
t2 as 
(select * from monthly_total_spend_per_retailer 
left join t1 using(hh_id) where monthly_spend_per_retailer/avg_total_spend >=0.8),
t3 as
(select hh_id, count(hh_id) as count1 from t2
group by hh_id)
select count(count1)/39577 from t3
where count1>=11; ## 94

## Answer: there are 94 households who are loyal to single retailer, which accounts for 0.24 % of the total(39577) households.

## creating single_retailer table, which join the household table for further analysis
create table single_retailer	
with t1 as
(select hh_id, sum(monthly_spend_per_retailer)/12 as avg_total_spend 
from monthly_total_spend_per_retailer group by hh_id),
t2 as 
(select * from monthly_total_spend_per_retailer 
left join t1 using(hh_id) where monthly_spend_per_retailer/avg_total_spend >=0.8),
t3 as
(select hh_id, count(hh_id) as count1 from t2
group by hh_id),
t4 as
(select * from t3
where count1>=11)
select * from households
inner join t4 using(hh_id);



## creating two_retailer table, which meets the above conditions and joins the household table for further analysis
create table two_retailer
with t1 as    
(select *,
row_number() over(partition by hh_id, monthly order by monthly_spend_per_retailer desc) as ranking
from monthly_total_spend_per_retailer),
t2 as
(select hh_id, monthly, monthly_spend_per_retailer, ranking+1 as new_ranking from t1),
t3 as
(select  t1.hh_id, t1.monthly, TC_retailer_code, ranking, new_ranking, 
t1.monthly_spend_per_retailer as monthly_spend_per_retailer_1,
t2.monthly_spend_per_retailer as monthly_spend_per_retailer_2
from t1
left join t2 on
t1.ranking = t2.new_ranking and t1.hh_id = t2.hh_id and
t1.monthly= t2.monthly), 
t4 as
(select distinct hh_id, monthly, TC_retailer_code,
monthly_spend_per_retailer_1+monthly_spend_per_retailer_2 as spend_of_two_retailer,
1 as count2
from t3 where ranking=2 and new_ranking=2),
t5 as
(select hh_id, sum(monthly_spend_per_retailer)/12 as avg_total_spend 
from monthly_total_spend_per_retailer group by hh_id),
t6 as 
(select * from t4 
left join t5 using(hh_id) where spend_of_two_retailer/avg_total_spend >=0.8),
t7 as
(select hh_id, count(hh_id) as count2 from t6
group by hh_id),
t8 as
(select * from t7 where count2>=11)
select * from households
inner join t8 using(hh_id);

select count(*)/39577 from two_retailer;

## Answer: there are 246 households who are loyal to two retailers, which accounts for 0.62 % of the total(39577) households.


## b.2.i. Are their demographics remarkably different? Are these people richer? Poorer?
## Attached in PDF documents

## b.2.ii. What is the retailer that has more loyalists?
## Single retailer
with t1 as
(select distinct hh_id, TC_retailer_code from single_retailer
inner join monthly_total_spend_per_retailer using (hh_id))
select  TC_retailer_code, count(TC_retailer_code) as total_loyality 
from t1 group by TC_retailer_code order by total_loyality desc;

## Two retailers
with t1 as
(select distinct hh_id, TC_retailer_code from two_retailer
inner join monthly_total_spend_per_retailer using (hh_id))
select  TC_retailer_code, count(TC_retailer_code) as total_loyality 
from t1 group by TC_retailer_code order by total_loyality desc;

## b.2.iii. Where do they live? Plot the distribution by state.
## Attached in PDF documents


# b.3 Plot with the distribution:
## b.3.i. Average number of items purchased on a given month.
with t1 as
(SELECT distinct hh_id, TC_id, extract(year_month from TC_date) as monthly
from trips),
t2 as
(select TC_id, quantity_at_TC_prod_id from purchases),
t3 as
(select sum(quantity_at_TC_prod_id) as total_items_hh, monthly, hh_id from t2
left join t1 using(TC_id) 
group by monthly, hh_id)
select monthly, avg(total_items_hh) as avg_items from t3 group by monthly;


## b.3.ii. Average number of shopping trips per month.
with t1 as
(select extract(year_month from TC_date) as monthly, hh_id, TC_id 
from trips),
t2 as
(select monthly, hh_id, count(TC_id) as n_of_trips
from t1 group by monthly, hh_id)
select monthly, avg(n_of_trips) as avg_trips from t2 group by monthly;


## b.3.iii. Average number of days between 2 consecutive shopping trips.
with t1 as
(select distinct hh_id, TC_date, extract(year_month from TC_date) as monthly
 from trips),
t2 as
(select *,
row_number() over(partition by hh_id order by TC_date desc) as rank_decreasing 
 from t1),
t3 as
(select hh_id, TC_date, monthly, rank_decreasing+1 as new_rank 
 from t2),
 t4 as
(select t3.hh_id, t3.monthly, datediff(t3.TC_date, t2.TC_date) as purchase_gap 
from t3 
left join t2
on t2.hh_id = t3.hh_id and t2.rank_decreasing = t3.new_rank)
select monthly, avg(purchase_gap) as avg_gap from t4 group by monthly;



# c. Answer and reason the following questions: (Make informative visualizations)
## c.1. Is the number of shopping trips per month correlated with the average number of items purchased?
with t1 as
(select hh_id, TC_id, concat(year(TC_date), date_format(TC_date,'%m')) as monthly_date from trips),
t2 as 
(select hh_id, monthly_date, count(TC_id) as count1 from t1
group by hh_id, monthly_date order by hh_id)
select hh_id, avg(count1) as avg_trips from t2
group by hh_id;


## joining three tables(purchase, trips, products)
create table purchase_trip_prod
select hh_id, TC_id, prod_id, TC_date, quantity_at_TC_prod_id, total_price_paid_at_TC_prod_id
from purchases
left join dta_at_TC
using (TC_id)
left join dta_at_prod_id
using(prod_id);



## c.2. Is the average price paid per item correlated with the number of items purchased?
select hh_id, TC_id, sum(total_price_paid_at_TC_prod_id)/sum(quantity_at_TC_prod_id) as avg_price_per_item 
from purchase_trip_prod group by TC_id, hh_id;

select TC_id, hh_id, sum(quantity_at_TC_prod_id)/count(TC_id) as avg_num_items
from purchase_trip_prod group by TC_id, hh_id;


## c.3. Private Labeled products are the products with the same brand as the supermarket. In the data set they appear labeled as ‘CTL BR

## c.3.i. What are the product categories that have proven to be more “Private labelled”
select department_at_prod_id as category, count(brand_at_prod_id) as num_private_category from products
where brand_at_prod_id regexp '(CTL BR)'
group by department_at_prod_id;  



## c.3.ii. Is the expenditure share in Private Labeled products constant across months?
select department_at_prod_id as category, count(brand_at_prod_id) as num_private_category from products 
where brand_at_prod_id regexp '(CTL BR)'
group by department_at_prod_id;


## creating table which includes private labeled products
create table private_labeled
select hh_id, TC_id, prod_id, quantity_at_TC_prod_id, total_price_paid_at_TC_prod_id,
 brand_at_prod_id, department_at_prod_id, month(TC_date) as monthly from purchase_trip_prod
left join dta_at_prod_id
using(prod_id);


with t1 as
(select monthly, sum(total_price_paid_at_TC_prod_id) as total_monthly_spend from 
private_labeled group by monthly),
t2 as 
(select monthly, sum(total_price_paid_at_TC_prod_id) as total_monthly_labeled_spend from 
private_labeled where brand_at_prod_id regexp '(CTL BR)' group by monthly)
select monthly, total_monthly_labeled_spend/total_monthly_spend as ratio_labeled 
from t1 
inner join t2 using(monthly) order by monthly;



## c.3.iii. Cluster households in three income groups, Low, Medium and High. Report the average monthly expenditure on grocery. 
## Study the % of private label share in their monthly expenditures. Use visuals to represent the intuition you are suggesting

## creating table all_grocery clustering households in three income groups with grocery 
create table all_grocery
with t1 as 
(select hh_id, if(hh_income<=10,"low",if(hh_income<=20,"medium","high")) as income_level from households),
t2 as
(select hh_id, TC_id, month(TC_date) as monthly from trips),
t3 as
(select * from t2
left join t1 using(hh_id)),
t4 as 
(select TC_id, prod_id, total_price_paid_at_TC_prod_id from purchases),
t5 as 
(select * from t4 
left join t3 using(TC_id)),
t6 as 
(select prod_id, brand_at_prod_id, department_at_prod_id from products),
t7 as
(select * from t5
left join t6 using(prod_id)) 
select total_price_paid_at_TC_prod_id, monthly, income_level,brand_at_prod_id 
from t7
where department_at_prod_id regexp '(grocery)';


## getting the average monthly spend on all grocery of different income levels
with t1 as 
(select monthly, income_level, sum(total_price_paid_at_TC_prod_id)/12 as avg_monthly_spend 
from all_grocery group by monthly, income_level order by income_level, monthly),
t2 as 
(select income_level, sum(avg_monthly_spend) as total_spend from t1 group by income_level)
select * from t2;


## getting the average monthly spend on private labeled grocery of different income levels
with t1 as 
(select monthly, income_level, sum(total_price_paid_at_TC_prod_id)/12 as avg_monthly_spend 
from all_grocery where brand_at_prod_id regexp 'CTL BR' group by monthly, income_level 
order by income_level, monthly), 
t2 as 
(select income_level, avg_monthly_spend from t1)
select income_level, sum(avg_monthly_spend) as avg_spend_private from t2 group by income_level;



