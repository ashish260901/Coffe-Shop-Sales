-- CONVERT DATE (transaction_date) COLUMN TO PROPER DATE FORMAT
UPDATE coffee_shop_sales 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%Y-%m-%d');

-- ALTER DATE (transaction_date) COLUMN TO DATE DATA TYPE
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- CONVERT TIME (transaction_time)  COLUMN TO PROPER DATE FORMAT
UPDATE coffee_shop_sales 
SET 
    transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

-- ALTER TIME (transaction_time) COLUMN TO DATE DATA TYPE
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- DATA TYPES OF DIFFERENT COLUMNS
DESCRIBE coffee_shop_sales;

-- TOTAL SALES
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5; -- for month of (CM-May)

-- TOTAL SALES KPI - Month on Month DIFFERENCE AND Month on Month GROWTH
SELECT 
    MONTH(transaction_date) AS month,                                                      -- Number of Month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,                               
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)         -- Month Sales Difference   (facilitates access to previous rows based on the offset argument)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)   -- Division by Per Month Sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage               -- Percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- TOTAL ORDERS
SELECT 
    COUNT('transaction_id') AS Total_Orders
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5; -- for month of (CM-May)

-- TOTAL ORDERS KPI - MONTH ON MONTH DIFFERENCE AND MONTH ON MONTH  GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT('transaction_id')) AS total_orders,
    (COUNT('transaction_id') - LAG(COUNT('transaction_id'), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT('transaction_id'), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)                  -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- TOTAL QUANTITY SOLD
SELECT 
    SUM(transaction_qty) AS Total_Quantity_Sold
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 6;                      -- for month of (CM-June)

-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (5,6)                   -- for May and June
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000,
                    1),
            'K') AS total_sales,
    CONCAT(ROUND(COUNT('transaction_id') / 1000, 1),
            'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),
            'K') AS total_quantity_sold
FROM
    coffee_shop_sales
WHERE
    transaction_date = '2023-05-18';                   -- For 18 May 2023

-- SALES ANALYSIS BY STORE LOCATION
SELECT 
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS Day_Type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000,
                    1),
            'K') AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 6
GROUP BY CASE
    WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
    ELSE 'Weekdays'
END;

-- SALES BY STORE LOCATION
SELECT 
    store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000,
                    2),
            'K') AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 6                      -- June
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- SALES TREND OVER PERIOD
SELECT 
    CONCAT(ROUND(AVG(total_sales) / 1000, 1), 'K') AS Average_Sales
FROM
    (SELECT 
        SUM(transaction_qty * unit_price) AS Total_Sales
    FROM
        coffee_shop_sales
    WHERE
        MONTH(transaction_date) = 5                  -- May
    GROUP BY transaction_date) AS Internal_Query;

-- DAILY SALES FOR MONTH SELECTED
SELECT 
    DAY(transaction_date) AS Day_of_Month,
    ROUND(SUM(unit_price * transaction_qty), 1) AS total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    Day_of_Month,
    CASE 
        WHEN Total_Sales > Avg_Sales THEN 'Above Average'
        WHEN Total_Sales < Avg_Sales THEN 'Below Average'
        ELSE 'Average'
    END AS Sales_Status,
    Total_Sales
FROM (
    SELECT 
        DAY(transaction_date) AS Day_of_Month,
        SUM(unit_price * transaction_qty) AS Total_Sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS Avg_Sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5                                 -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS Sales_Data
ORDER BY 
    Day_of_Month;

-- SALES BY PRODUCT CATEGORY
SELECT 
    product_category,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- SALES BY PRODUCTS (TOP 10)
SELECT 
    product_type,
    SUM(unit_price * transaction_qty) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5 and product_category = 'Coffee'
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

-- SALES BY DAY | HOUR  | MONTH
SELECT 
    SUM(unit_price * transaction_qty) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity_Sold,
    COUNT(*)
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5                   -- May
        AND DAYOFWEEK(transaction_date) = 1       -- Sunday
        AND HOUR(transaction_time) = 14;          -- Hour (14)

-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY CASE
    WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
    WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
    WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
    WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
    WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
    WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
    ELSE 'Sunday'
END;

-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);