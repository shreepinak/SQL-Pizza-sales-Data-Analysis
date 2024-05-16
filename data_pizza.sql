create database Pizza_Planet;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

# -- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS total_orders
FROM
    orders;

# -- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id;
    
# -- Identify the highest-priced pizza.
SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;

# -- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS total_order
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY size
ORDER BY total_order DESC
LIMIT 1;

# -- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name,
    COUNT(od.order_details_id) AS total_order,
    SUM(quantity) AS qty
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY name
ORDER BY total_order DESC
LIMIT 5;

# -- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_qty
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_qty DESC;

# -- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS total_hrs,
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

# -- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

# -- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_orders), 0)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS total_orders
    FROM
        orders o
    JOIN order_details od ON od.order_id = o.order_id
    GROUP BY o.order_date) AS avg_orders;
    
# -- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(p.price * od.quantity), 2) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

# -- Calculate the percentage contribution of each pizza type category to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity) / (SELECT 
                    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
                FROM
                    pizzas p
                        JOIN
                    order_details od ON od.pizza_id = p.pizza_id) * 100,
            2) AS per_cont
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY per_cont DESC;

# -- Analyze the cumulative revenue generated over date.
select order_date, round(sum(revenue) over (order by order_date),2) as cum_rev
from
(select o.order_date ,ROUND(SUM(p.price * od.quantity), 2) AS revenue
from orders o
join order_details od on od.order_id=o.order_id
join pizzas p on p.pizza_id=od.pizza_id
group by order_date) as sales;

# -- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name, revenue, rn
from
(select category, name , revenue, 
rank() over (partition by category order by revenue desc) as rn
from
(select pt.category,pt.name,ROUND(SUM(p.price * od.quantity), 2) AS revenue
from pizza_types pt
join pizzas p on p.pizza_type_id=pt.pizza_type_id
join order_details od on od.pizza_id=p.pizza_id
group by pt.category,pt.name) as a) as b
where rn<=3;
