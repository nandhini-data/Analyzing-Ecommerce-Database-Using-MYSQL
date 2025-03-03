use mavenfuzzyfactory;

SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pageview_count
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000
GROUP BY 1
ORDER BY 2 DESC;

SELECT 
    *
FROM
    website_pageviews
WHERE
    website_pageview_id < 1000;


-- Temporary table first_pageview created.
create temporary table first_pageview
select 
website_session_id,min(website_pageview_id) as min_pageview
from website_pageviews
where website_pageview_id <1000
group by website_session_id;

SELECT 
    *
FROM
    first_pageview;

SELECT 
    first_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_pageview
        LEFT JOIN
    website_pageviews ON first_pageview.min_pageview = website_pageviews.website_session_id;

SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_pageview.website_session_id) AS session_hits
FROM
    first_pageview
        LEFT JOIN
    website_pageviews ON first_pageview.min_pageview = website_pageviews.website_session_id
GROUP BY 1
ORDER BY 2 DESC;

-- Task 1:Pull the most viewed website pages,ranked by session volume

SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pageviews
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY 2 DESC;

-- Task 2:Pull all entry pages and rank them on entry volume

SELECT 
    *
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12';


SELECT 
    *
FROM
    first_pageview;

SELECT 
    website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pageview.website_session_id) AS session_hitting_page
FROM
    first_pageview
        LEFT JOIN
    website_pageviews ON first_pageview.min_pageview = website_pageviews.website_pageview_id
GROUP BY 1;

-- Landing page performance and testing
-- Step 1: find the first_website_pageview_id for relevant session
-- Step 2: identify the landing page for each session
-- step 3:counting pageviews for each session to identify "bounces"
-- step 4: summarizing total sessions and bounced session by LP

create temporary table first_pageviews_demo
select website_pageviews.website_session_id,min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
inner join website_sessions
on website_sessions.website_session_id=website_pageviews.website_session_id
and website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 1 ;

SELECT 
    *
FROM
    first_pageviews_demo;

create temporary table sessions_w_landing_page_demo
select 
first_pageviews_demo.website_session_id,
website_pageviews.pageview_url as landing_page
from first_pageviews_demo
left join website_pageviews
on website_pageviews.website_pageview_id =first_pageviews_demo.min_pageview_id;

SELECT 
    *
FROM
    sessions_w_landing_page_demo;

create temporary table bounced_session_only
select 
sessions_w_landing_page_demo.website_session_id,
sessions_w_landing_page_demo.landing_page,
count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from
sessions_w_landing_page_demo
left join website_pageviews
on website_pageviews.website_session_id =sessions_w_landing_page_demo.website_session_id
group by 1,2
having count(website_pageviews.website_pageview_id)=1;

SELECT 
    *
FROM
    bounced_session_only;

-- Final output
SELECT 
    sessions_w_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_session_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_session_only.website_session_id) / COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS bounce_rate
FROM
    sessions_w_landing_page_demo
        LEFT JOIN
    bounced_session_only ON sessions_w_landing_page_demo.website_session_id = bounced_session_only.website_session_id
GROUP BY sessions_w_landing_page_demo.landing_page;
 
 -- Task 3:Pull the bounce rate for traffic landing on the homepage
 -- step 1:Finding the first website_pageview_id for relevant sessions
 -- step 2:Identifying the landing page of each session
 -- step 3: counting pageviews for each session , to identify bounces
 -- step 4: summarizing by counting total session and bounced session
 
create temporary table first_pageviews_1
select website_session_id,min(website_pageview_id) as min_pageview_id
from website_pageviews
where created_at <'2012-06-14'
group by website_session_id;
SELECT 
    *
FROM
    first_pageviews_1;

create temporary table sessions_w_home_landing_page
select 
first_pageviews_1.website_session_id,
website_pageviews.pageview_url as landing_page
from first_pageviews_1
left join website_pageviews
on website_pageviews.website_pageview_id = first_pageviews_1.min_pageview_id
where website_pageviews.pageview_url ='/home';

SELECT 
    *
FROM
    sessions_w_home_landing_page;

create temporary table bounced_sessions
select sessions_w_home_landing_page.website_session_id,
sessions_w_home_landing_page.landing_page,
count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from sessions_w_home_landing_page
left join website_pageviews
on website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id
group by sessions_w_home_landing_page.website_session_id,sessions_w_home_landing_page.landing_page
having count(website_pageviews.website_pageview_id) =1;

SELECT 
    *
FROM
    bounced_sessions;

SELECT 
    sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id AS bounced_website_session_id
FROM
    sessions_w_home_landing_page
        LEFT JOIN
    bounced_sessions ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY sessions_w_home_landing_page.website_session_id;


-- Final output of the task calculating bounce_rates
select
count(distinct sessions_w_home_landing_page.website_session_id) as total_sessions,
count(distinct bounced_sessions.website_session_id) as bounced_sessions,
count(distinct bounced_sessions.website_session_id)/count(distinct sessions_w_home_landing_page.website_session_id) as bounce_rate
from sessions_w_home_landing_page
left join bounced_sessions
on sessions_w_home_landing_page.website_session_id =bounced_sessions.website_session_id;
