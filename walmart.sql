use walmart;
SET SQL_SAFE_UPDATES = 0;

select * from  sales;
alter table sales change cutomer customer varchar(50) not null;
# feature engineering
alter table sales add column Days varchar(15);
update sales
set days  = (
CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
		ELSE "Evening" 
	END)
;

alter table sales change days time_ofthe_day varchar(15) not null;
alter table sales add column day_name varchar(20) not null;
update sales 
set day_name = dayname(date);
alter table sales add column month_name varchar(30) not null;
update sales
set month_name = monthname(date);
#EDA
 select count( distinct(city)) from sales;
 select distinct(city) from sales;
 select distinct(branch), city  from sales;
 select distinct(product_line) from sales;
 select* from sales;
 SELECT payment FROM sales
GROUP BY payment ORDER BY COUNT(*) DESC LIMIT 1;
select product_line from sales group by product_line order by count(*) desc limit 1;
select month_name,(sum(cogs) + sum(gross_income)) as total_revenue from sales group by month_name;
select month_name, sum(cogs) from sales group by month_name order by sum(cogs) desc limit 1;
select product_line , sum(total) from sales group by product_line order by sum(total) desc limit 1;
select city , (sum(cogs) + sum(gross_income) )as total_revenue from sales group by city  order by total_revenue desc limit 1;
select product_line , sum(vat) from sales group by product_line order by sum(vat) desc limit 1;
alter table sales add column product_category varchar(25);

SET @avg_total = (SELECT AVG(total) FROM sales);


UPDATE sales 
SET product_category = 
    CASE 
        WHEN total >= @avg_total THEN 'Good'
        ELSE 'Bad'
    END;
select * from sales;
select branch, sum(quantity) from sales group by branch having sum(quantity) > avg(quantity) order by sum(quantity) desc limit 1;
#What is the most common product line by gender?
SELECT gender, product_line, COUNT(gender) total_count
FROM sales GROUP BY gender, product_line ORDER BY total_count DESC limit 1;
#What is the average rating of each product line?
select product_line, round (avg(rating),3) as rating from sales group by product_line ;


#Number of sales made in each time of the day per weekday
SELECT day_name, time_ofthe_day, COUNT(invoice_id) AS total_sales
FROM sales GROUP BY day_name, time_ofthe_day HAVING day_name NOT IN ('Sunday','Saturday');

# Identify the customer type that generates the highest revenue.
select customer, sum(total) revenue from sales group by customer order by revenue desc limit 1;

 #Which city has the largest tax percent/ VAT (Value Added Tax)?
 select city , sum(vat) from sales group by city order by sum(vat) desc limit 1;
 
 #Which customer type pays the most in VAT?
 select customer, sum(vat) from sales group by customer order by sum(vat) desc limit 1;
 
 #Customer Analysis

-- 1.How many unique customer types does the data have?
select count(distinct(customer )) from sales;

-- 2.How many unique payment methods does the data have?
select count(distinct payment) from sales;


-- 3.Which is the most common customer type?
select customer,count(customer) from sales group by customer order by count(customer) desc	;

-- 4.Which customer type buys the most?
select customer , count(quantity) qty from sales group by customer order by qty desc; 
# or
select customer , sum(total) most_buys from sales group by customer order by most_buys desc limit 1;

-- 5.What is the gender of most of the customers?
select gender, count(customer) from sales group by gender order by count(customer) desc limit 1;
 
-- 6.What is the gender distribution per branch?
select branch, count(gender) gender from sales group by branch order by gender desc;

-- 7.Which time of the day do customers give most ratings?

SELECT time_ofthe_day, SUM(rating) AS total_rating FROM sales GROUP BY time_ofthe_day ORDER BY total_rating DESC LIMIT 1;

-- 8.Which time of the day do customers give most ratings per branch?
select branch, time_ofthe_day, SUM(rating) AS total_rating  from sales group by time_ofthe_day, branch  ORDER BY total_rating DESC LIMIT 1;

-- 9.Which day of the week has the best avg ratings?

select day_name , avg(rating) rating from sales group by day_name order by  rating desc limit 1;

-- 10.Which day of the week has the best average ratings per branch?
select branch, day_name, avg(rating) rating from sales group by branch, day_name order by rating desc limit 1;








 
 
 









