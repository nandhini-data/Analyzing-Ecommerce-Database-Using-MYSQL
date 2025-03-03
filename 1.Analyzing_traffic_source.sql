use mavenfuzzyfactory;
SELECT 
    *
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 1000 AND 2000;

-- 1.ANALYZING TRAFFICE SOURCES

SELECT 
    website_sessions.utm_content,
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS session_to_order_convrsn_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY website_sessions.utm_content
ORDER BY sessions DESC;



SELECT 
    *
FROM
    orders
WHERE
    website_session_id BETWEEN 1000 AND 2000;

-- Task 1:Find where the bulk of website session are coming from.

SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(website_session_id) AS web_session
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY 1 , 2 , 3
ORDER BY web_session DESC;

/* Bulk of our website session are coming from gsearch  source 
and nonbrand campaign
for further analysis we can drill through gsearch and nonbrand */

SELECT 
    COUNT(website_sessions.website_session_id) AS sessions,
    COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS seesion_to_order_cvr
FROM
    website_sessions
        LEFT JOIN
    orders ON orders.website_session_id = website_sessions.website_session_id
WHERE
    website_sessions.created_at < '2012-04-14'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand';
        
SELECT 
    *
FROM
    orders;

SELECT 
    website_session_id,
    created_at,
    MONTH(created_at),
    WEEK(created_at),
    YEAR(created_at)
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 100000 AND 115000;

SELECT 
    WEEK(created_at) AS week,
    YEAR(created_at) AS year,
    COUNT(DISTINCT website_session_id)
FROM
    website_sessions
WHERE
    website_session_id BETWEEN 100000 AND 115000
GROUP BY week , year;
 
-- Pivoting data with count and case 

SELECT 
    order_id, primary_product_id, items_purchased, created_at
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000;

SELECT 
    items_purchased, COUNT(DISTINCT order_id) AS order_count
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
GROUP BY items_purchased;

SELECT 
    primary_product_id,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 1 THEN order_id
            ELSE NULL
        END) AS orders_w_1_items,
    COUNT(DISTINCT CASE
            WHEN items_purchased = 2 THEN order_id
            ELSE NULL
        END) AS orders_w_2_items,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders
WHERE
    order_id BETWEEN 31000 AND 32000
GROUP BY 1;


-- Task 3:Traffic source trending

SELECT 
    MIN(DATE(created_at)) AS week_started_at,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-12'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at) , WEEK(created_at);

-- Task 4:Pull the conversion type from session to order,by device type

select * from website_sessions;
select * from orders;

SELECT 
    website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-05-11'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
group by 1;

-- Task 5:Can you pull weekly trend for both desktop and mobile 


select min(date(created_at)) as start_date,
count(distinct case when device_type ='desktop' then website_session_id else null end) as desktop_sessions,
count(distinct case when device_type='mobile' then website_session_id else null end)as mob_sessions
from website_sessions
where created_at <'2012-06-09'
and created_at >'2012-04-15'
and utm_source ='gsearch'
and utm_campaign ='nonbrand'
group by yearweek(created_at);

