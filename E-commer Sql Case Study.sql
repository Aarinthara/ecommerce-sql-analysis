/* e-commerce company sql case study
   author : aarinthara babu
   database : ecommerce
   objective : customer, product and sales analysis using sql
*/



/* section 0 : database setup and data overview */

create database ecommerce;

use ecommerce;

select * from customers;
select * from order_data;
select * from orderdetails;
select * from products;

describe customers;
describe order_data;
describe orderdetails;
describe products;



/* section 1 : date format correction
   question 1 : convert order_date into date format
*/

update order_data
set order_date = str_to_date(order_date,'%Y-%m-%d');

alter table order_data
modify column order_date date;



/* section 2 : top customer locations
   question 2 : identify top 3 cities with highest number of customers
*/

select
location,
count(*) as number_of_customers
from customers
where location is not null
group by location
order by count(*) desc
limit 3;



/* section 3 : customer order distribution
   question 3 : classify customers based on number of orders
*/

select
count(order_id) as number_of_orders,
case
    when count(order_id) between 2 and 4 then 'occasional shoppers'
    when count(order_id) > 4 then 'regular customers'
    else 'one-time buyer'
end as terms
from order_data
group by customer_id;



select
number_of_orders,
count(customercount) as customercount
from
(
    select
    count(order_id) as number_of_orders,
    customer_id as customercount
    from order_data
    group by customer_id
    order by count(order_id)
) t
group by number_of_orders;



/* section 4 : premium product identification
   question 4 : products with avg quantity = 2 but high revenue
*/

select
product_id,
avg(quantity) as avgquantity,
sum(price_per_unit * quantity) as totalrevenue
from orderdetails
group by product_id
having avg(quantity) = 2
order by totalrevenue desc;



/* section 5 : category wise customer reach
   question 5 : unique customers per product category
*/

select
p.category,
count(distinct o.customer_id) as unique_customers
from order_data o
join orderdetails od
on o.order_id = od.order_id
join products p
on od.product_id = p.product_id
group by p.category
order by unique_customers desc;



/* section 6 : month on month sales growth
   question 6 : percentage change in total sales month wise
*/

select
months,
totalsales,
round(
    (totalsales - lag(totalsales) over(order by months)) /
    lag(totalsales) over(order by months) * 100,2
) as percentagechange
from
(
    select
    date_format(order_date,'%Y-%m') as months,
    sum(total_amount) as totalsales
    from order_data
    group by months
) t
group by months;



/* section 7 : average order value trend
   question 7 : month on month change in average order value
*/

select
month,
round(avgordervalue,2),
round(
    (avgordervalue - lag(avgordervalue) over(order by month)),2
) as changeinvalue
from
(
    select
    date_format(order_date,'%Y-%m') as month,
    avg(total_amount) as avgordervalue
    from order_data
    group by date_format(order_date,'%Y-%m')
) t
group by month
order by changeinvalue desc;



/* section 8 : fast moving products
   question 8 : products with highest turnover rate
*/

select
product_id,
count(*) as salesfrequency
from orderdetails
group by product_id
order by count(*) desc
limit 5;



/* section 9 : low engagement products
   question 9 : products purchased by less than 40 percent customers
*/

select
od.product_id,
p.name,
count(distinct o.customer_id) as uniquecustomercount
from order_data o
join orderdetails od
on o.order_id = od.order_id
join customers c
on o.customer_id = c.customer_id
join products p
on od.product_id = p.product_id
group by od.product_id, p.name
having count(distinct o.customer_id) <
(
    0.4 * (select count(distinct customer_id) from customers)
);



/* section 10 : customer acquisition trend
   question 10 : month wise new customer growth
*/

select
date_format(firstordercustomer,'%Y-%m') as firstpurchasemonth,
count(*) as totalnewcustomers
from
(
    select
    customer_id,
    min(order_date) as firstordercustomer
    from order_data
    group by customer_id
) t
group by date_format(firstordercustomer,'%Y-%m')
order by date_format(firstordercustomer,'%Y-%m') asc;



/* section 11 : peak sales months
   question 11 : identify months with highest sales volume
*/

select
date_format(order_date,'%Y-%m') as month,
sum(total_amount) as totalsales
from order_data
group by date_format(order_date,'%Y-%m')
order by sum(total_amount) desc
limit 3;



