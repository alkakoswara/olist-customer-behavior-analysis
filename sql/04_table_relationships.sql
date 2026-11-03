select SUM(price)
from olist_order_items_dataset  

select SUM(freight_value)
from olist_order_items_dataset

select count(DISTINCT (order_id, order_item_id))
from olist_order_items_dataset

select count(*)
from olist_order_items_dataset 
where order_item_id is null or order_id is null

select count(*)
FROM olist_order_items_dataset as i   
LEFT JOIN olist_orders_dataset AS o
  ON i.order_id  = o.order_id
  where o.order_id is null 
  
select o.order_status, COUNT(*)
FROM olist_orders_dataset as o   
LEFT JOIN olist_order_items_dataset AS i
  ON o.order_id  = i.order_id
  where i.order_id is null
 group by o.order_status
  
  
  