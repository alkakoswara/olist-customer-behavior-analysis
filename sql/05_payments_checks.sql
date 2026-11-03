select SUM(payment_value )
from olist_order_payments_dataset

select count(distinct (order_id, payment_sequential))
from olist_order_payments_dataset

select count(*)
from olist_order_payments_dataset
where order_id is null or payment_sequential  is null

select count(*)
from olist_order_payments_dataset as p
left join olist_orders_dataset as o
on p.order_id = o.order_id 
where o.order_id is null

select o.order_id, o.order_status
from olist_orders_dataset  as o
left join olist_order_payments_dataset as p
on o.order_id = p.order_id 
where p.order_id is null





