select order_id, 
	order_delivered_customer_date - order_purchase_timestamp  
from olist_orders_dataset
where order_delivered_customer_date is not null 
limit 10;

select order_id, 
	order_delivered_customer_date - order_estimated_delivery_date  
from olist_orders_dataset
where order_delivered_customer_date is not null 
limit 10;

select order_id, 
	order_delivered_customer_date - order_estimated_delivery_date  
from olist_orders_dataset
where order_delivered_customer_date::date > order_estimated_delivery_date::date 
limit 10;

select count(*) 
from olist_orders_dataset
where order_delivered_customer_date::date > order_estimated_delivery_date::date 
and order_status = 'delivered';

select count(*)
from olist_orders_dataset
where order_status = 'delivered'
	and order_delivered_customer_date is not null
	and order_estimated_delivery_date is not null;

select 6.534*100/96.470;






