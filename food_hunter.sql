use food_hunter;

# all data in resturants table
select * from restaurants;

# show item name food_price and a=calories from food items table
select item_name, price, calories from food_items;

# orderids , customer ids and total price of all orders

select order_id, customer_id,total_price from orders;

# no. of restaurants

select count(distinct restaurant_id) as restaurant_cnt from restaurants;
# unique cuisines
select count(distinct cuisine) as unique_cuisine from restaurants; 

#unique dishes
select count(distinct item_name) as unique_dishes from food_items ;

SELECT * FROM food_hunter.orders_items;

# understanding monthly sales

select * from orders limit 50;

# is the sale really falling?
select concat(monthname(delivered_date)," ", year(delivered_date)) , sum(final_price) from orders 
group by monthname(delivered_date);

# there has been a siggnificant dro in the revenue from august
select * from orders limit 50;
# does giving lesser discounts affect the customer behaviour?

with tot_order as(
select concat(monthname(delivered_date)," ", year(delivered_date)) as mon , sum(total_price*(discount/100)) as total_discounts, 
count(order_id) as total_orders 
from orders 
group by (monthname(delivered_date))
)
select tot_order.mon, tot_order.total_discounts, tot_order.total_orders, disc.disc0_cnt ,  
(disc.disc0_cnt/tot_order.total_orders) as zero_disc_rat from tot_order join (select 
concat(monthname(delivered_date)," ", year(delivered_date)) as mon , count(order_id) as disc0_cnt
from orders where discount=0 group by monthname(delivered_date) 
) as disc on tot_order.mon=disc.mon;

# No the discounts are not afecting the , as the ratio is almost same througout

#check for the average ratings

select concat(monthname(delivered_date)," ", year(delivered_date)) as mon , avg(order_rating)
from orders 
group by monthname(delivered_date);

# clearly there seems to be an issue related to delivery quality

# let's check average time take for each delivery

select concat(monthname(delivered_date)," ", year(delivered_date)) as mon , avg(timestampdiff(minute,order_time,delivered_time)) as avg_delivery_time
from orders 
group by monthname(delivered_date);

# we can observe a drastic increase in average delivery time ,
#it is fine if any external factors like increased traffic jam time or re-routing could be the reason
 


