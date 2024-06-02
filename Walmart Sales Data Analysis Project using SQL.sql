create database if not exists salesDataWalmart;

create table if not exists sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
)
;

-- -----------------------------------------------------------------------
-- Feature Engineering --

-- time_of_day

select
	time,
    (CASE 
		when `time` between "00:00:00" and "12:00:00" then "Morning"
        when `time` between "12:01:00" and "16:00:00" then "Afternoon"
        else "Evening"
    END
    ) as time_of_day
from sales;

-- -----------------------------------------------------------------------

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (
	CASE 
		when `time` between "00:00:00" and "12:00:00" then "Morning"
        when `time` between "12:01:00" and "16:00:00" then "Afternoon"
        else "Evening"
    END
);

-- day_name --

select
	date,
    DAYNAME(date) as day_name
from sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name --

select 
	date,
    MONTHNAME(date)
from sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales 
SET month_name = MONTHNAME(date);

-- ---------------------------------------------------------------------------
-- Generic Questions --------

-- How many unique cities does the data have?

select 
	DISTINCT city
from sales;

-- In which city is each branch?

select 
	DISTINCT branch
from sales;


select 
	DISTINCT city,
    branch
from sales;

-- -----------------------------------------------------------------------------------
-- Product Question -----

-- How many unique product lines does the data have?

select
	DISTINCT product_line
from sales;

-- WHat is the most common payment method?

select
	payment_method,
	count(payment_method) as cnt
from sales
group by payment_method
order by cnt desc;

-- WHat is the most selling product line?

select
	product_line,
	count(product_line) as cnt
from sales
group by product_line
order by cnt desc;

-- What is the total revenue by month?

select
	month_name as month,
    sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc;

-- What month had the largest COGS?

select 
	month_name as month,
    SUM(COGS) as cogs
from sales
group by month_name
order by cogs desc;

-- Which product line had the largest revenue?

select 
	product_line,
    SUM(total) as total_revenue
from sales
group by product_line
order by total_revenue desc;

-- What is the city with the largest revenue?

select 
	city,
    branch,
    SUM(total) as total_revenue
from sales
group by city, branch
order by total_revenue desc;

-- What product line had the largest VAT?

select 
	product_line,
    AVG(VAT) as avg_tax
from sales
group by product_line
order by avg_tax desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if it's greater than average sales?



-- Which branch sold more products than average product sold?

select 
	branch,
    SUM(quantity) as qty
from sales
group by branch
having SUM(quantity) > (select avg(quantity) from sales);

-- What is the most common product line by gender?

select
	gender,
    product_line,
    count(gender) as total_cnt
from sales
group by gender, product_line
order by total_cnt desc;

-- What is the average rating of each product?

select
	round(avg(rating), 2) as avg_rating,
    product_line
from sales
group by product_line
order by avg_rating desc;

-- -----------------------------------------------------------------------------
-- Sales Questions------------------------------------------------------------------

-- What is the number of sales made in each time of the day per weekday?

select
	time_of_day,
    count(*) as total_sales
from sales
where day_name = 'Monday'
group by time_of_day
order by total_sales desc;

-- Which of the customers types brings the most revenue?

select
	customer_type,
    round(sum(total), 2) as total_rev
from sales
group by customer_type
order by total_rev desc;

-- Which city has the largest tax percent/VAT (Value Added Tax)?

select
	city,
    round(avg(VAT), 2) as VAT
from sales
group by city
order by VAT desc;

-- Which customer type pays the most in VAT?

select
	customer_type,
    round(avg(VAT), 2) as VAT
from sales
group by customer_type
order by VAT desc;


-- -----------------------------------------------------------------------------------------
-- Customer Information Questions -----------------------------------------------------------


-- How many unique customer types does the data have?

select
	count(distinct(customer_type))
from sales;

-- How many unique payment methods does the data have?

select 
	distinct payment_method
from sales;

-- What is most common customer type?

select
	customer_type
from sales;
    
-- Which customer type buys the most?

select 
	customer_type,
    count(*) as customer_count
from sales
group by customer_type;

-- What is the gender of most of the customers?

select
	gender,
    count(*) as gender_count
from sales
group by gender
order by gender_count desc;

-- WHat is the gender distribution by branch?

select 
	gender,
    count(*) as gender_count
from sales
where branch = 'B'
group by gender
order by gender_count desc;

-- WHat time of the day do customers gives most rating?

select 
	time_of_day,
    avg(rating) as avg_rating
from sales
group by time_of_day
order by avg_rating desc;

-- Which time of the day do customers gives most ratings per branch?

select
	time_of_day,
    avg(rating) as avg_rating
from sales
where branch = 'B'
group by time_of_day
order by avg_rating desc;

-- Which day of the week has the best avg ratings?

select
	day_name,
    avg(rating) as avg_rating
from sales
group by day_name
order by avg_rating desc;

-- Which day of the week has the best average ratings per branch?

select
	day_name,
    avg(rating) as avg_rating
from sales
where branch = 'C'
group by day_name
order by avg_rating desc;