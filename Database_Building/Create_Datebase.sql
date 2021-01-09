## creating tables
create database db_consumer_panel;
use db_consumer_panel;

create table households(
hh_id                       		int(8),
hh_race          					int,
hh_is_latinx        				int,
hh_zip_code             			int(5),
hh_state          					text,
hh_income             				int(2),
hh_size       						int,
hh_residence_type     				int,
primary key       					(hh_id)
);

create table trips(
hh_id                       		int(8),
TC_date          					date,
TC_retailer_code        			int(7),
TC_retailer_code_store_code         int(7),
TC_retailer_code_store_zip3         int(3),
TC_total_spent            			double,
TC_id        						int(7),
primary key       					(TC_id),
foreign key             			(hh_id) references households(hh_id)
);

create table products(
brand_at_prod_id                	text,
department_at_prod_id      			text,
prod_id           					int(15),
group_at_prod_id            		text,
module_at_prod_id      				text,
amount_at_prod_id          			double,
units_at_prod_id     				text,
primary key       					(prod_id)
);

create table purchases(
TC_id                       		int(7),
quantity_at_TC_prod_id      		int(3),
total_price_paid_at_TC_prod_id      double,
coupon_value_at_TC_prod_id          double,
deal_flag_at_TC_prod_id             int,
prod_id              				int(15),
foreign key             			(TC_id) references trips(TC_id),
foreign key       					(prod_id) references products(prod_id)
);

### count all tables's rows(the raw data)
select count(*)from products; ## 4231283
select count(*) from purchases; ## 38587942 
select count(*) from trips;  ## 7596145
select count(*) from households;  ## 39577






