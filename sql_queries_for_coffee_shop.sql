-- Creating Database

create database coffee_shop_sales;

-- Selecting database

use coffee_shop_sales;

-- Checking Table
select *
From coffee_shop_sales;

-- Checking Table discription


-- Making sure date is in dd-mm-yy and time  in hh-mm-ss
update coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date,'%m/%d/%Y');

update coffee_shop_sales
SET transaction_time = str_to_date(transaction_time,'%H:%i:%s');

-- Changing columns type to date and time
alter TABLE  coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

alter TABLE  coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- Checking table discription make sure changes are applied

describe `coffee_shop_sales`;

select * 
From coffee_shop_sales;


-- Correcting columns name
alter TABLE  `coffee_shop_sales`
CHANGE COLUMN  `ï»¿transaction_id` transaction_id INT;


-- Checking Table discription make sure changes are applied

describe `coffee_shop_sales`;

-- Looking for total sales and total sales for specific month

SELECT sum(unit_price * transaction_qty) AS Total_sales
FROM `coffee_shop_sales`;  -- Total Sales

SELECT ROUND(SUM(transaction_qty * unit_price),2) AS Total_sales
FROM `coffee_shop_sales` 
Where MONTH(transaction_date) = 5;  -- Total Sales for specific month

-- monrth on month sales growth for April and MAY

SELECT 
	MONTH(transaction_date) as Months,  
	ROUND(SUM(transaction_qty * unit_price),2) AS Total_sales, 
    (ROUND(SUM(transaction_qty * unit_price),2) - LAG(ROUND(SUM(transaction_qty * unit_price),2),1) over (order by Month(transaction_date)))
    / LAG(ROUND(SUM(transaction_qty * unit_price),2),1)
    
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
From coffee_shop_sales
Where MONTH(transaction_date) in (4,5)	
group by Months
order by Months;

-- Finding total orders in May

SELECT count(transaction_id)
From coffee_shop_sales
WHERE  MONTH(transaction_date) = 5;


-- monrth on month orders growth for April and MAY

select 
	MONTH(transaction_date) as months, 
	count(transaction_id) as TOTAL_orders,
    (count(transaction_id) - LAG(count(transaction_id),1) OVER(ORDER BY MONTH(transaction_date)))
    /(LAG(count(transaction_id),1)OVER(ORDER BY MONTH(transaction_date)) * 100) AS MOM_order_Increase
From coffee_shop_sales
WHERE MONTH(transaction_date_bkp) IN (4,5)
GROUP BY months
ORDER BY months;

-- Total Quantity sold in May

SELECT SUM(transaction_qty) AS TOTAL_QUANTITY
FROM coffee_shop_sales
WHERE MONTH(transaction_date_bkp) = 5;


-- TOTAL Quantity Growth MOM

SELECT 
	MONTH(transaction_date) AS MONTHS, 
    SUM(transaction_qty) AS TOTAL_QUANTITY, 
    (SUM(transaction_qty)- LAG(SUM(transaction_qty),1) OVER(ORDER BY MONTH(transaction_date)))/LAG(SUM(transaction_qty),1) OVER(ORDER BY MONTH(transaction_date)) AS MOM_quantity_Increase
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTHS
ORDER BY MONTHS;

-- Finding all the KPI for 18 May 2023

SELECT 
	concat(ROUND(sum(transaction_qty* unit_price)/1000),'K') AS TOTAL_SALES, 
    concat(sum(transaction_qty)/1000 , 'K') AS TOTAL_QUANTITY , 
    concat(COUNT(transaction_id)/1000 ,'K') AS TOTAL_ORDERS
FROM coffee_shop_sales
WHERE transaction_date = '2023-05-18'; -- For 18 May 2023

-- AVERAGE SALES IN A MONTH

SELECT AVG(tOTAL_sales) AS "Average sales"
FROM
(SELECT SUM(transaction_qty * unit_price) AS tOTAL_sales
FROM coffee_shop_sales
WHERE month(transaction_date) = 5
group by transaction_date)AS INTERNAL_QUERY;

-- DAily SALES for a MONTH
SELECT DAY(transaction_date) AS Day_of_month, ROUND(SUM(transaction_qty * unit_price),1) AS total_sales
FROM coffee_shop_sales
WHERE month(transaction_date) = 5
GROUP BY DAY(transaction_date)
order by DAY(transaction_date);

-- FINDING_above or below AVERAGE sales monthly
SELECt 
	transaction_date,
    CASE 
		WHEN TOTAL_sales > AVERAGE_SALES THEN 'ABOVE AVERAGE'
        WHEN TOTAL_sales < AVERAGE_SALES THEN 'BELOW AVERAGE'
        ELSE 'Average'
        END AS sales_status,
    round(TOTAL_sales,2) 
FROM
	(SELECT transaction_date,sum(transaction_qty * unit_price) AS TOTAL_sales, AVG(sum(transaction_qty * unit_price)) OVER ()  AS AVERAGE_SALES, transaction_qty , unit_price
	FROM coffee_shop_sales
	WHERE MONTH(transaction_date) = 5
	group by DAY(transaction_date) ) AS Internal_query;
    
-- WEEKdays SAles and WEEKEND sales for month of may

SELECT 
	CASE
    WHEN weekday(transaction_date) IN (1,7) THEN 'WEEKENDs'
    ELSE 'WEEKDAYS'
    END AS DAYTYPE,
	ROUND(sum(transaction_qty * unit_price)) AS TOTAL_SALES
FROM coffee_shop_sales
WHere month(transaction_date) = 5
group by 
	CASE
    WHEN weekday(transaction_date) IN (1,7) THEN 'WEEKENDs'
    ELSE 'WEEKDAYS'
    END
;
    
    
-- SALES BY STORE LOCATION

SELECT store_location, sum(transaction_qty * unit_price) AS TOTAL_SALES
FROM coffee_shop_sales
WHERE month(transaction_date) = 5
group by store_location
ORDER BY TOTAL_SALES DESC;


-- SALES BY PRODUCT CATEGORY

SELECT product_category, sum(transaction_qty * unit_price) AS TOTAL_SALES
FROM coffee_shop_sales
WHERE month(transaction_date) = 5
GROUP BY product_category
ORDER BY TOTAL_SALES DESC;

-- Top 10 SALES by PRODUCTS
SELECT product_type, sum(transaction_qty * unit_price) AS TOTAL_SALES
FROM coffee_shop_sales
WHERE month(transaction_date) = 5
GROUP BY product_type
ORDER BY TOTAL_SALES DESC
LIMIT 10 ;


-- Sales by day of week and hour

SELECT 	
	SUM(transaction_qty * unit_price) AS sales,  
	SUM(transaction_qty) as QTY, 
    COUNT(transaction_id) as Total_Orders
FROM coffee_shop_sales
WHERE 
	dayofweek(transaction_date) = 3
    AND
    MONTH(transaction_date) = 5
    AND
    hour(transaction_time) = 8;
    

-- TO GET SALES FROM MONDAY TO SATURDAY FOR MONTH OF MAY

SELECT 
	CASE
		WHEN dayofweek(transaction_date) = 2 THEN 'MONDAY'
		WHEN dayofweek(transaction_date) = 3 THEN 'Tuesday'
		WHEN dayofweek(transaction_date) = 4 THEN 'WEDNESDAY'
        WHEN dayofweek(transaction_date) = 5 THEN 'THURSDAY'
        WHEN dayofweek(transaction_date) = 6 THEN 'FRIDAY'
		WHEN dayofweek(transaction_date) = 6 THEN 'SATURDAY'
        ELSE 'SUNDAY'

        END AS day_of_week,
	ROUND(SUM(transaction_qty * unit_price)) AS sales,  
	SUM(transaction_qty) as QTY, 
    COUNT(transaction_id) as Total_Orders
FROM coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5 
Group BY
	CASE
		WHEN dayofweek(transaction_date) = 2 THEN 'MONDAY'
		WHEN dayofweek(transaction_date) = 3 THEN 'Tuesday'
		WHEN dayofweek(transaction_date) = 4 THEN 'WEDNESDAY'
        WHEN dayofweek(transaction_date) = 5 THEN 'THURSDAY'
        WHEN dayofweek(transaction_date) = 6 THEN 'FRIDAY'
		WHEN dayofweek(transaction_date) = 6 THEN 'SATURDAY'
        ELSE 'SUNDAY'
        END
Order BY dayofweek(transaction_date);


-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY

		select HOUR(transaction_time) AS HOUR_of_the_day, ROUND(SUM(transaction_qty*unit_price),2) AS Total_sales
		FROM coffee_shop_sales
		WHERE MONTH(transaction_date) = 5 
		group by HOUR(transaction_time)
		ORDER BY HOUR(transaction_time);

-- To get averge mom growth of all time

select Round(avg(Mom_growth),2)
From 
(
select 
	month(transaction_date) , 
    SUM(transaction_qty * unit_price), 
    ((SUM(transaction_qty * unit_price) - LAG(SUM(transaction_qty * unit_price),1) over(order by month(transaction_date)))/ LAG(SUM(transaction_qty * unit_price),1) over(order by month(transaction_date)))*100 AS Mom_growth
FROM coffee_shop_sales
group by month(transaction_date)

) 
AS internal_query;




