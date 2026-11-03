select count (*)
from olist_orders_dataset
where order_status = 'delivered' 
and order_delivered_customer_date::date > order_estimated_delivery_date::date

select customer_unique_id, product_id, count(distinct o.order_id) as jumlah_pesanan
from customers as c
left join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join olist_order_items_dataset as i
on o.order_id = i.order_id 
where o.order_status  = 'delivered'
group by customer_unique_id, product_id
having count(distinct o.order_id) >= 2;

select product_id, sum(jumlah_pesanan - 1) as jumlah_pembelian_repeat
from(
select customer_unique_id, product_id, count(distinct o.order_id) as jumlah_pesanan
from customers as c
left join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join olist_order_items_dataset as i
on o.order_id = i.order_id 
where o.order_status  = 'delivered'
group by customer_unique_id, product_id
having count(distinct o.order_id) >= 2
) as pasangan
group by product_id 
order by jumlah_pembelian_repeat desc


select count(*)
from olist_products_dataset

select customer_unique_id, o.order_id,
row_number() over  (
partition by customer_unique_id
order by o.order_purchase_timestamp, o.order_id 
) as urutan
from customers as s
left join olist_orders_dataset as o
on s.customer_id = o.customer_id
where order_status = 'delivered'


select customer_unique_id, order_id, urutan
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
where urutan = 2;

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
where urutan = 2;


select count(*) as pasangan,
       count(distinct customer_unique_id) as pelanggan
from (
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
) as t;

select product_category_name,
       count(*) as pesanan_kedua
from (
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
) as t
group by product_category_name
order by pesanan_kedua desc;





