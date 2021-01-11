# Grocery-Shopping-Behavior [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
Final Project for Marketing Analytics
Final project for Big Data I

## Content

  * [Installations](#installations)
    + [Modules](#modules)
    + [Data Source](#data-source)
  * [Project Motivation](#project-motivation)
    + [Background](#background)
    + [Business Goal](#business-goal)
  * [File Description](#file-description)
    + [Database_Building](#database-building)
    + [SQL_Queries](#sql-queries)
    + [Results](#results)
    + [Visualizations](#visualizations)

## Installations
### Modules
**pip install these modules**
- pandas: data processing
- numpy: linear algebra
- seaborn: data visualization
- matplotlib: data visualization

**for database**
- pymysql
- mysql
- sqlalchemy

### Data Source
- **Households**
  - hh_id: long integer (PK)
  - hh_race: integer   
    - 1: White Caucasian 
    - 2: African American 
    - 3: Asian
  - is_latinx: Integer indicating whether
    - 1 Yes 
    - 2 No
  - hh_income: Integer indicating the income bracket.
    - 3: Under $5k yearly income 
    - 4: $5k ‐ $7.9k 
    - 6: $8k ‐ $9.9k 
    - 8: $10k ‐ $11.9k 
    - 10: $12k – $14.9k 
    - 11: $15k – $19.9k -
    - 13: $20k – $24.9k 
    - 15: $25k – $29.9k 
    - 16: $30k – $34.9k 
    - 17: $35k – $39.9k 
    - 18: $40k – $44.9k 
    - 19: $45k – $49.9k 
    - 21: $50k – $59.9k 
    - 23: $60k – $69.9k 
    - 26: $70k – $99.9k 
    - 27: $100.0k or more
  - hh_size: integer indicating the number of members composing the household.
    - 1: Single member 
    - 2: Two members
    - 3: Three members 
    - …
    - 9: Nine or more members
  - hh_zip_code: 5 digits zipcode coded as integer
  - hh_state: 2 character abbreviation of the state
  - hh_residence_type:
    - 1: One family house 
    - 2: One family house – condo 
    - 3: Two family house 
    - 4: Two family house ‐ condo 
    - 5: Three family house 
    - 6: Three family house –condo 
    - 7: Trailer 
    - 8: Not reported
- **Products**
  - brand_at_prod_id 
  - department_at_prod_id 
  - prod_id (PK) 
  - group_at_prod_id 
  - module_at_prod_id 
  - amount_at_prod_id 
  - units_at_prod_id
- **Trips**
  - hh_id (FK) 
  - TC_date 
  - TC_retailer_code 
  - TC_retailer_code_store_code  
  - TC_retailer_code_store_zip3 
  - TC_total_spent
  - TC_id (PK)
- **Purchases**
  - TC_id (FK) 
  - quantity_at_TC_prod_id 
  - total_price_paid_at_TC_prod_id 
  - coupon_value_at_TC_prod_id 
  - deal_flag_at_TC_prod_id 
  - prod_id (FK)
  
The datasets for database building are too large, hence they cannot be pushed. If you are interested in practicing, please email me.

## Project Motivation
### Background 
Grocery is a rigid demand, even during challenging economic periods. In 2019, America's average household spent a little over eight thousand dollars a year on food. By analyzing the demographics of loyal customers and their shopping behavior. We can provide data-driven insights for grocery stores on retaining customers and how to settle the supply-chain.

### Business Goal
By creating a relational database, and then query from it. I aim to understand analyze the shopping behaviors by answering these questions:
- **Loyalism**
  - How many households are loyal to single retailer or among two retailers?
  - Among these loyal customers, are their demographics remarkably different? (Household size, race, annual income)
  - Where do these loyal customers live? (By state)
  - What retailers have more loyal customers?
- **Relationship with time**
  - Does the average number of items purchased correlated to seasons? (different months)
  - Does the average number of shopping trips correlated to seasons? (different months)
  - Does the average days between two consecutive shopping trips correlated to seasons? (different months)
- **Private labeled products**
  - Is the expenditure share in private labeled products constant across months?
  - Does the share in private labeled products correlated with household income level?
  
## File Description
### Database_Building
- load_data.py
  A Python script to connect Python with MySQL database and load the data into the database.
- mysql-change-password.sql
  A SQL code to reset your username and password.
- Create_Datebase.sql
  A SQL script to create the relational database.
### SQL_Queries
- sql-queries.sql
  SQL queries to obtain the information we need for analysis.
### Results
The folder has datasets that we need to do data visualizations. All the datasets were exported by SQL.
### Visualizations
- data_visualizations.ipynb
  A Python notebook for data visualizations.

## License
This project is licensed under [MIT License](https://github.com/git/git-scm.com/blob/master/MIT-LICENSE.txt).

## Author
[Zhaoyi Wang](https://github.com/ZhaoyiW)
