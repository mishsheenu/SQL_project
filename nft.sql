select * from pricedata;
show tables;
#1.How many sales occurred during this time period? 
select sum(usd_price) total_sales from pricedata  WHERE event_date BETWEEN '2018-01-01' AND '2021-12-31';

#2.Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.
select name, eth_price, event_date,  sum(usd_price) most_expensive  from pricedata group by name, eth_price, event_date  order by most_expensive desc limit 5;

#3. Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.
select event_date,usd_price,  avg(usd_price) over ( order by event_date  rows between 49 preceding and current row) as moving_average from pricedata; 

#4.Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.
select name, avg(usd_price) avg_price from pricedata group by name order by avg_price desc;

#5.Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. 
#Order by the count of transactions in ascending order.
select dayname(event_date) dayname , sum(usd_price) numberofsales , avg(eth_price) eth from pricedata group by  dayname order by  count(usd_price) desc;

#6. Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
# Here’s an example summary:
#“CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”
alter table pricedata add column summary varchar(255);
update pricedata 
set summary = concat( name , "was sold for ", usd_price,  " to", buyer_address, "from", seller_address);

#Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.
Create view 1919_purchases as select usd_price sales from pricedata where buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";
select * from 1919_purchases;
select * from pricedata;
#Create a histogram of ETH price ranges. Round to the nearest hundred value. 
select floor(eth_price/100)*100 as price , count(*) from pricedata group by price order by price;  


#Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” 
#with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. The table should have a name column,
# a price column called price, and a status column. Order the result set by the name of the NFT, and the status, in ascending order. 
select name, max(usd_price) price, "highest" status from pricedata  group by name union
select name, min(usd_price) price, "lowest" status from pricedata group by name 
ORDER BY name, status ASC;

#What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format.
select name,monthname(event_date) months, year(event_date) years, sum(usd_price) price from pricedata group by name , months, years order by price asc;

#Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).
select monthname(event_date) monthname,sum(round(usd_price, -2)) total_sales from pricedata group by monthname order by total_sales asc;

#Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.
select  count(case  when buyer_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685" then 1 end ) buyer_count,
count(case when seller_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685" then 1 end ) seller_count from pricedata;

SELECT COUNT(*) AS transaction_count FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685' or seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

#Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 #- Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 #- Take the daily average of remaining transactions
 #a) First create a query that will be used as a subquery. Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
 #b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value which is just the daily average of the filtered data.	
CREATE TEMPORARY TABLE temp_pricedata AS
SELECT event_date, usd_price, AVG(usd_price) OVER (PARTITION BY event_date) AS avg_usd_price
FROM pricedata;
select * from temp_pricedata;
SELECT event_date,AVG(usd_price) AS new_avg_usd_price FROM
( SELECT event_date,usd_price, avg_usd_price FROM temp_pricedata WHERE usd_price >= 0.1 * avg_usd_price) AS filtered_data GROUP BY event_date;












