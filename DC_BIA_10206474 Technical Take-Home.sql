/* Directions:
Please evaluate the 4 prompts below. We will work to schedule a panel interview for the following weeks where you will walk through each of your answers, with extra time focusing on the business case (Prompt 4). Please send your answers to the first three prompts back to Jon (jkinder@E15group.com) at least 24 hours prior to your panel interview.

Note: Your panel interview will include technical and non-technical team members who will assume the role of a stakeholder. You may provide your findings in any format you wish, as long as they can be communicated clearly.

If you have any questions or issues, please reach out to Jon.
*/


/* Prompt 1:
You inherited the following query, which is meant to retrieve the number of orders placed in Q1 of 2021, as well as the number of orders placed in Q1 of 2021 that were later returned, regardless of the return date. However, your stakeholder believes the number of orders with returns is higher than expected. Please troubleshoot the query, explain any issues (if any), and provide a corrected query along with the actual number of orders and returned orders if different.
*/

/*SELECT
    COUNT(o.order_id) AS orders,
    COUNT(r.order_id) AS returned_orders
FROM
    INTERVIEWS.DC_BIA_10206474.RETURNS r
    RIGHT JOIN INTERVIEWS.DC_BIA_10206474.ORDERS o ON r.order_id = o.order_id
WHERE
    o.order_date BETWEEN '2021-01-01'
    AND '2021-03-31';*/
--Orders 399 Returned_orders 230

/*The correct way to write this query joins RETURNS(Table1) and ensures that all returned orders are counted including orders that are also contained within the ORDERS table. It is also essential to generate a distinct count in order to avoid duplicates, maintain accurate metrics, and ensure data integrity.  This count will ensure that null values from RETURNS are not included.

A RIGHT JOIN includes all orders, some of which were completed, are duplicates, and returns with in the RETURNS table.  We are looking for the actual number of orders and number of returned orders. We must handle duplicates within returns and not when counting ALL orders.
    */
    
-- Count the total number of orders in Q1 2021
WITH total_orders AS (
    SELECT 
        COUNT(order_id) AS total_orders
    FROM 
        INTERVIEWS.DC_BIA_10206474.ORDERS
    WHERE 
        order_date BETWEEN '2021-01-01' AND '2021-03-31'
),

-- Count the number of returned orders from Q1 2021
returned_orders AS (
    SELECT 
        COUNT(DISTINCT o.order_id) AS returned_orders
    FROM 
        INTERVIEWS.DC_BIA_10206474.ORDERS o
    JOIN 
        INTERVIEWS.DC_BIA_10206474.RETURNS r ON o.order_id = r.order_id
    WHERE 
        o.order_date BETWEEN '2021-01-01' AND '2021-03-31'
)

-- Combine the results
SELECT 
    (SELECT total_orders FROM total_orders) AS orders,
    (SELECT returned_orders FROM returned_orders) AS returned_orders;

    
    /* Prompt 2:
    The following query is designed to pull in all orders placed in July 2020, displaying their Order ID, Category, Sale, and, if returned, the return amount (since returns may not always be for the full amount). Your stakeholder has noted that when they sum the Sales numbers, the total appears too high. Additionally, they have indicated that the data is difficult to work with. Please troubleshoot the query, identify any issues (if any), and provide a corrected query with fixes.
    */
/*SELECT
    o.category,
    o.order_id,
    o.SALES,
    r.return_amount
FROM
    INTERVIEWS.DC_BIA_10206474.ORDERS o
    LEFT JOIN INTERVIEWS.DC_BIA_10206474.RETURNS r ON o.order_id = r.order_id
WHERE
    o.order_date BETWEEN '2020-07-01'
    AND '2020-07-31'
    AND r.return_date >= '2020-07-01';*/

/*Issues:
1. Join conidtion on the 'return_date' excludes orders without returns
2. Left join will cause duplication of sales figures in the case of multiple returns for a single order
*/

SELECT
    o.category,
    o.order_id,
    TO_NUMBER(REPLACE(o.SALES, '$', '')) AS SALES,
    COALESCE(TO_NUMBER(REPLACE(r.return_amount, '$', '')), 0) AS return_amount
FROM
    INTERVIEWS.DC_BIA_10206474.ORDERS o
    LEFT JOIN (
        SELECT order_id, SUM(TO_NUMBER(REPLACE(return_amount, '$', ''))) AS return_amount
        FROM INTERVIEWS.DC_BIA_10206474.RETURNS
        GROUP BY order_id
    ) r ON o.order_id = r.order_id
WHERE
    o.order_date BETWEEN '2020-07-01' AND '2020-07-31';

SELECT SUM(SALES) AS total_sales
FROM INTERVIEWS.DC_BIA_10206474.ORDERS
WHERE order_date BETWEEN '2020-07-01' AND '2020-07-31';

/*Corrections:
-Remove the condition on 'return_date' from the 'WHERE' clause
-Summarize the sales and returns data to avoid duplucations

Reasoning:
1. Subquery for Returns: Aggregates return amounts for each 'order_id' to avoid duplicating sales.
2. COALESCE Function: Ensures that 'return_amount' is '0' if no return exists for an order.

SUM() of Sales: Ensures that the correct calculation for total sales for orders placed in July for 2020.
*/


/* Prompt 3:
What order "Category" has the least returns by dollar value?  By number of orders? Please share your work.  
*/

SELECT
    o.category,
    SUM(COALESCE(TO_NUMBER(REPLACE(r.return_amount, '$', '')), 0)) AS total_return_amount
FROM
    INTERVIEWS.DC_BIA_10206474.ORDERS o
    LEFT JOIN INTERVIEWS.DC_BIA_10206474.RETURNS r ON o.order_id = r.order_id
GROUP BY
    o.category
ORDER BY
    total_return_amount ASC
LIMIT 1;

 /*Explanation:
-Coalesce and replace fuctions handle potential null values and remove dollar signs from
'return_amount' to convert it to a numeric type.
-Aggregates the total return amount by category
Orders the result to get the category with the least return amount.

The end result returns the Category with the least returns by dollar value 
*/

--Technology:$3782

SELECT
    o.category,
    COUNT(DISTINCT o.order_id) AS num_returned_orders
FROM
    INTERVIEWS.DC_BIA_10206474.ORDERS o
    LEFT JOIN INTERVIEWS.DC_BIA_10206474.RETURNS r ON o.order_id = r.order_id
WHERE
    r.return_amount IS NOT NULL
GROUP BY
    o.category
ORDER BY
    num_returned_orders ASC
LIMIT 1;

/*EXPLANATION:
-Counts the distinct orders with a return for each category
-Filters out orders without returns
-Orders the results with the least number of returned orders and returns the first value

The end result is the Category with the least returns by the number of orders.
*/

--Technology:15 orders



    /* Prompt 4: 20-Minute Case Study
    Your stakeholder intuitively understands their own business, yet they are not technical enough to draw insight or strategy from this dataset. Your task is to communicate high-level trends and opportunities demonstrating an understanding of the data. This is an open-ended task with multiple correct answers.
    
    You will be expected to communicate insights and opportunities clearly with the interviewing team, as well as how you arrived at your findings. The format will be discussional, much like a conversation with a stakeholder. You are encouraged to use whatever technologies you feel appropriate (such as Tableau, Excel, PowerPoint, etc).
    
    */