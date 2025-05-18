-- View all records
SELECT * FROM walmart;

-- Count total records
SELECT COUNT(*) AS total_records FROM walmart;

-- 1️⃣ Number of Transactions by Payment Method
SELECT 
    payment_method,
    COUNT(*) AS total_transactions
FROM walmart
GROUP BY payment_method;

-- 2️⃣ Count of Unique Branches
SELECT COUNT(DISTINCT branch) AS total_branches FROM walmart;

-- 3️⃣ Minimum Quantity Sold
SELECT MIN(quantity) AS min_quantity_sold FROM walmart;

-- 4️⃣ Payment Method Analysis: Transactions and Total Quantity Sold
SELECT 
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(quantity) AS total_quantity_sold
FROM walmart
GROUP BY payment_method;

-- 5️⃣ Highest Rated Category per Branch
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE rank = 1;

-- 6️⃣ Busiest Day per Branch
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE rank = 1;

-- 7️⃣ Total Quantity Sold per Payment Method
SELECT 
    payment_method,
    SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;

-- 8️⃣ Rating Stats by City and Category
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- 9️⃣ Total Profit per Category
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- 🔟 Most Preferred Payment Method per Branch
WITH payment_rank AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM payment_rank
WHERE rank = 1;

-- 🔁 Invoice Distribution by Shift (Morning, Afternoon, Evening)
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, invoices DESC;

-- 🔻 Branches with Highest Revenue Drop from 2022 to 2023
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS revenue_2022,
    r2023.revenue AS revenue_2023,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_drop_pct
FROM revenue_2022 r2022
JOIN revenue_2023 r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_drop_pct DESC
LIMIT 5;
🔢 Q11: Best-Selling Product Line
SELECT 
    product_line,
    SUM(quantity) AS total_sold
FROM walmart
GROUP BY product_line
ORDER BY total_sold DESC
LIMIT 1;
🌆 Q13: City with Highest Average Purchase Amount
SELECT 
    city,
    AVG(total) AS avg_purchase
FROM walmart
GROUP BY city
ORDER BY avg_purchase DESC
LIMIT 1;
