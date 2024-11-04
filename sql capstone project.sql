-- creating a database named as 'amazon'

create database amazon;
use amazon;

-- created a table name 'amazon_sales' and inserted the data using table import wizard 

-- feature engineering
-- adding 3 more columns(time_of_day, day_name and month_name) to the table using the alter and update function.

alter table amazon_sales
add column time_of_day varchar(50);

update amazon_sales
set time_of_day= CASE -- using Case statement for the categorisation of day into morning, afternoon and evening
   when hour(amazon_sales.Time) >=0 and hour (amazon_sales.Time) < 12 then 'Morning'
   when hour(amazon_sales.Time) >=12 and hour (amazon_sales.Time) < 18 then 'Afternoon'
   else 'Evening'
END;

alter table amazon_sales
add column day_name varchar(50);

update amazon_sales
set day_name = date_format(amazon_sales.Date,'%a');

update amazon_sales
set Date = STR_TO_DATE(Date, '%d-%m-%Y'); -- converting date column into required date format

alter table amazon_sales
add column month_name varchar(50);

update amazon_sales
set month_name = date_format(amazon_sales.Date,'%b');


select * from amazon_sales;

-- EDA(Exploratory Data Analysis) - it is done to answer the listed questions and aims of this project.

-- Business Questions to answer --

/* 1. What is the count of distinct cities in the dataset? */
select count(distinct city) as distinct_cities from amazon_sales;
/* There are 3 distinct cities present in the dataset.*/

/* 2. For each branch, what is the corresponding city?*/
select branch, city from amazon_sales 
group by branch,city;
/* The corresponding city for each branch is 'A'-'Yangon', 'B'-'Mandalay' and 'C'-'Naypyitaw'.*/

/* 3. What is the count of distinct product lines in the dataset?*/
select count(distinct product_line) as no_of_distinct_product_line from amazon_sales;
/* The count of distinct product line present in the dataset is 6.*/

/* 4. Which payment method occurs most frequently?*/
select payment, count(payment) as most_fre_payment from amazon_sales
group by payment
order by most_fre_payment desc
limit 1;
/* The payment method which occurs most frequently is 'Ewallet'.*/

/* 5. Which product line has the highest sales?*/
select Product_line, count(invoice_id) as sales_count from amazon_sales
group by Product_line
order by sales_count desc
limit 1;
/* The product line having highest sales is 'Fashion accessories'.*/

/* 6. How much revenue is generated each month?*/
select month_name, sum(Unit_price * Quantity) as monthly_revenue 
from amazon_sales
group by month_name
order by monthly_revenue desc;
/* The revenue generated for each month present in the dataset are 'Jan' - '110754.16',
'Mar' - '104243.33' and 'Feb' - '92589.88' respectively. */

/* 7. In which month did the cost of goods sold reach its peak?*/
select month_name, sum(cogs) as total_cogs
from amazon_sales
group by month_name 
order by total_cogs desc
limit 1;
/* In 'Jan' month the cost of goods sold are at its peak.*/

/* 8. Which product line generated the highest revenue?*/
select Product_line, sum(quantity * unit_price) as total_sales
from amazon_sales
group by product_line 
order by total_sales desc
limit 1;
/* The product line which generated the highest revenue is 'Food and beverages'.*/

/* 9. In which city was the highest revenue recorded?*/
select city, sum(quantity * unit_price) as total_city_sales 
from amazon_sales
group by city
order by total_city_sales desc
limit 1;
/* The city which recorded the highest revenue is 'Naypyitaw'.*/

/* 10. Which product line incurred the highest Value Added Tax?*/
select Product_line, sum(cast(Tax_5 as decimal(10, 2))) as Total_VAT
from amazon_sales
group by Product_line
order by Total_VAT desc
limit 1;
/* The product line which incurred the highest VAT is 'Food and beverages'.*/

/* 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."*/
select product_line, sum(quantity * unit_price) as total_revenue,
CASE
   when sum(quantity * unit_price) < (select avg(quantity * unit_price) from amazon_sales) then 'Bad'
   else 'Good'
END as kind_of_sales
from amazon_sales
group by product_line
order by total_revenue desc;
/* Since all the product lines has good kind of sales hence we can say that they 
all are having the sales above the average line.*/

/* 12. Identify the branch that exceeded the average number of products sold.*/
select branch, sum(quantity) as total_quantity
from amazon_sales
group by branch
having sum(quantity) > (select avg(quantity) from amazon_sales);
/* All the branches worked above average clearly evident from the result.*/

/* 13. Which product line is most frequently associated with each gender?*/
select gender, product_line, count(*) as frequency
from amazon_sales
group by gender, product_line
having count(*) = (
			select max(sub.frequency)
            from (
                  select gender, product_line, count(*) as frequency
                  from amazon_sales
                  group by gender, product_line
                  ) as sub
		   where sub.gender = amazon_sales.gender
           group by sub.gender
	)
order by gender;
/* The product lines that are most frequently associated with each gender are
 'Fashion accessories' and 'Health and beauty' with 'Female' and 'Male' respectively.*/

/* 14. Calculate the average rating for each product line.*/
select product_line, avg(Rating) as avg_rating
from amazon_sales
group by product_line;
/* The average rating for each product line is shown in the output.*/

/* 15. Count the sales occurrences for each time of day on every weekday.*/
select day_name, time_of_day, count(invoice_id) as sales_occurences
from amazon_sales
where day_name not in ('Sat', 'Sun')
group by day_name, time_of_day
order by day_name, time_of_day;
/* The count of sales occurences for each time of day on every weekday is shown below in the output.*/

/* 16. Identify the customer type contributing the highest revenue.*/
select customer_type, sum(quantity * unit_price) as customer_type_revenue
from amazon_sales
group by customer_type
order by customer_type_revenue desc
limit 1;
/* The customer type 'Member' in the dataset contributing the highest revenues.*/

/* 17. Determine the city with the highest VAT percentage.*/
select city, avg(tax_5/total * 100) as vat_percentage
from amazon_Sales
group by city
order by vat_percentage desc
limit 1;
/* The city with highest vat percentage is 'Yangon' with vat percenatge (~4.77)*/

/* 18. Identify the customer type with the highest VAT payments.*/
select customer_type, sum(tax_5) as total_vat
from amazon_sales
group by customer_type
order by total_vat desc
limit 1;
/* 'Member' is the customer type in the dataset with the highest VAT payments*/

/* 19. What is the count of distinct customer types in the dataset?*/
select count(distinct customer_type) as distinct_customer_types 
from amazon_sales;
/* There are 2 distinct types of customer in the dataset.*/

/* 20. What is the count of distinct payment methods in the dataset?*/
select count(distinct payment) as distinct_payment_methods 
from amazon_sales;
/* The count of distinct payment methods is 3 and they are ewallet, credit card and cash*/

/* 21. Which customer type occurs most frequently?*/
select customer_type, count(*) as frequency
from amazon_sales
group by customer_type
order by frequency desc
limit 1;
/* The customer type which occurs most frequently is member*/

/* 22. Identify the customer type with the highest purchase frequency*/
select customer_type, count(*) as purchase_frequency
from amazon_sales
group by customer_type
order by purchase_frequency desc
limit 1;
/* The customer type having the highest purchase frequency is 'Member'*/

/* 23. Determine the predominant gender among customers*/
select gender, count(*) as gender_count
from amazon_sales
group by gender
order by gender_count desc
limit 1;
/* The predominant gender among the customers is 'female'*/

/* 24. Examine the distribution of genders within each branch*/
select branch, gender, count(*) as dist_of_gender
from amazon_sales
group by branch, gender
order by branch, dist_of_gender desc;
/* the distribution of genders within branch is shown in the output*/

/* 25. Identify the time of day when customers provide the most ratings*/
select time_of_day, count(rating) as rating_count
from amazon_sales
group by time_of_day
order by rating_count desc
limit 1;
/* The time of day when customers provide most ratings is 'Afternoon'*/

/* 26. Determine the time of day with the highest customer ratings for each branch*/
select branch, time_of_day, avg(rating) as avg_rating
from amazon_sales
group by branch, time_of_day
order by avg_rating desc;
/* The time of day with the highest customer ratings for each branch is shown below in the output*/

/* 27. Identify the day of the week with the highest average ratings*/
select day_name, avg(rating) as avg_rating
from amazon_sales
group by day_name
order by avg_rating desc
limit 1;
/* The day of the week with the highest avg rating is 'Monday'*/

/* 28. Determine the day of the week with the highest average ratings for each branch.*/
select branch, day_name, avg(rating) as avg_rating
from amazon_sales
group by branch, day_name
order by avg_rating desc;
/* The highest avg ratings for each branch is on the following days given below*/