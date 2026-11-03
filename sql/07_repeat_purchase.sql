-- A: Pelanggan dengan minimal 2 pesanan, semua status
-- Preview: maksimal 5 pelanggan, bukan total pelanggan repeat
select c.customer_unique_id, count(o.order_id)
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id 
group by c.customer_unique_id
HAVING COUNT(o.order_id) > 1
limit 5

-- B: Pelanggan dengan minimal 2 pesanan delivered
-- Preview: maksimal 5 pelanggan, bukan total pelanggan repeat
select c.customer_unique_id, count(o.order_id)
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id
having COUNT(o.order_id) > 1
limit 5

select count(*) 
from (select c.customer_unique_id, count(o.order_id) 
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id 
where o.order_status = 'delivered'
group by c.customer_unique_id
having COUNT(o.order_id) > 1
) as repeat_a;

-- C: Urutan pesanan per pelanggan dengan ROW_NUMBER
select  c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
row_number() over (partition by c.customer_unique_id order by o.order_purchase_timestamp, o.order_id )
as urutan
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id
where c.customer_unique_id in ('004288347e5e88a27ded2bb23747066c',
  '00a39521eb40f7012db50455bf083460')
order by c.customer_unique_id, urutan;

--C: Tanpa Partition
select  c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
row_number() over (order by o.order_purchase_timestamp, o.order_id )
as urutan
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id
where c.customer_unique_id in ('004288347e5e88a27ded2bb23747066c',
  '00a39521eb40f7012db50455bf083460')
order by c.customer_unique_id, urutan;

--C: Nomor urut pesanan per pelanggan, semua status
select u.urutan, count(*)
from (select  c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
row_number() over (partition by c.customer_unique_id order by o.order_purchase_timestamp, o.order_id )
as urutan
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id) as u
group by u.urutan
order by u.urutan;

--D: Tanggal pesanan sebelumnya dengan LAG
select count(*) as jumlah_pelanggan,
case when jeda_hari = 0 then '0_hari'
when jeda_hari <= 7 then '1-7_hari'
when jeda_hari <= 30 then '8-30_hari'
when jeda_hari <= 90 then '31-90_hari'
when jeda_hari <= 180 then '91-180_hari'
else 'Lebih_Dari_180_hari'
end as rentang_jeda,
min(jeda_hari) as urutan_rentang
from (select  c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
row_number() over (partition by c.customer_unique_id order by o.order_purchase_timestamp, o.order_id )
as urutan,
lag(o.order_purchase_timestamp) over (partition by c.customer_unique_id order by o.order_purchase_timestamp, o.order_id)
as tanggal_pembelian_sebelumnya,
o.order_purchase_timestamp::date - (LAG(o.order_purchase_timestamp) OVER (partition by c.customer_unique_id order by o.order_purchase_timestamp, o.order_id))::date AS jeda_hari
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id
where o.order_status = 'delivered') as jeda_pesanan
where urutan = 2
group by rentang_jeda; 

--Untuk Power BI
select u.urutan, count(*)
from (select  c.customer_unique_id, o.order_id, o.order_purchase_timestamp,
row_number() over (partition by c.customer_unique_id order by o.order_purchase_timestamp, o.order_id )
as urutan
from customers as c 
join olist_orders_dataset as o
on c.customer_id  = o.customer_id
where o.order_status = 'delivered') as u
group by u.urutan
order by u.urutan;

















