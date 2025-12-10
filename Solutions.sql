Create DATABASE pizza;
use pizza;
select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

-- DATA EXPLORATION
-- 1.1 total number of orders placed

select count(order_id) from orders;

-- 1.2

select sum(o.quantity*p.price) as "Total_Revenue_Generated"
from order_details o
join pizzas p
on o.pizza_id=p.pizza_id;

-- 1.3. highest priced pizza

select pt.name,max(price) as "highest_priced" 
from pizzas p
join pizza_types pt on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by max(price) desc
limit 1;

-- 1.4. most common pizza size

select p.size,count(o.order_details_id)
from pizzas p
join order_details o on o.pizza_id=p.pizza_id
group by p.size
order by count(o.order_id);

-- SALES ANALYSIS
-- 2.1. most ordered pizza type with quantity

select p.name,sum(o.quantity)
from pizzas p
join order_details o on o.pizza_id=p.pizza_id
join pizza_types pt on pt.pizza_type_id=p.pizza_type_id
group by p.name
order by sum(o.quantity) desc
limit 5;

-- 2.2. distribution of order by hours of day 

select *,
sum(hourly_orders) over () as total_orders,
hourly_orders*100/sum(hourly_orders) over () as pct_contribution_of_orders
from 
(
select left(time,2) as 'hours',count(order_id) as 'hourly_orders'
from orders
group by hours
order by 2 desc)
as a;

-- 2.3. most ordered pizza type with Revenue 

select pt.name,sum(o.quantity*p.price) as "Total_Revenue_Generated"
from pizzas p
join order_details o on o.pizza_id=p.pizza_id
join pizza_types pt on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by Total_Revenue_Generated desc
limit 3;

-- Operational Insights
-- 3.1. percentage contribution of each pizza type with total revenue 

with cte as
(
select pt.name,sum(o.quantity*p.price) as "Rev"
from pizzas p
join order_details o on o.pizza_id=p.pizza_id
join pizza_types pt on pt.pizza_type_id=p.pizza_type_id
group by pt.name
order by rev desc
)
select *,
sum(rev) over () as Total_revenue,
rev* 100/sum(rev) over () as Rev_Percentage_contribution
from cte;

-- 3.2 cummulative/total revenue generated over time

select *,
round(sum(Revenue_Generated) over (order by date asc),0) as Cumm_Revenue_Generated
from
(
select od.date,
round(sum(o.quantity*p.price),0) as "Revenue_Generated"
from order_details o
join pizzas p on o.pizza_id=p.pizza_id
join orders od on o.order_id=od.order_id
group by od.date
)as a;

-- 3.3 most odered pizza_type group by revenue and pizza category
 
select *
from
(
select *,
dense_rank() over (partition by category order by revenue desc) as category_distribution
from
(
select pt.name,Sum(p.price*o.quantity) as 'Revenue',pt.category
from pizzas p
join order_details o on o.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.name,pt.category
order by revenue desc
) as a
) as b
where category_distribution <=3;

-- Category wise anaylysis
-- 4.1 total quantity of each pizza ordered

select sum(o.quantity) as "Total Quantity",pt.category
from order_details o
join pizzas p on o.pizza_id=p.pizza_id
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category;

-- 4.2 category wise distribution of pizza

select pt.category,count(Distinct pt.name) as pizza_type,count(distinct p.pizza_id) as pizza_distribution
from pizzas p
join pizza_types pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category
order by count(pt.name);

-- 4.3 group orders by date and calc avg no. of pizza ordered per day

select
avg(Sum_of_pizzas_ordered) as 'Avg_number_of_pizzas_ordered'
from
(
select sum(ord.quantity) as 'Sum_of_pizzas_ordered',o.date
from orders o
join order_details ord on o.order_id=ord.order_id
group by o.date
order by o.date
) as a;