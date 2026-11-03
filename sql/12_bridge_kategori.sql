select distinct pesanan_berurutan.customer_unique_id, p.product_category_name
from
(select customer_unique_id, o.order_id,
row_number() over  (
partition by customer_unique_id 
order by o.order_purchase_timestamp, o.order_id 
) as urutan
from customers as s
left join olist_orders_dataset as o
on s.customer_id = o.customer_id
where order_status = 'delivered') as pesanan_berurutan
left join olist_order_items_dataset as i
on pesanan_berurutan.order_id = i.order_id
left join olist_products_dataset as p
on i.product_id = p.product_id 
where urutan = 2