-- 01. Latihan awal: jumlah pesanan delivered dan pembelian terakhir per pelanggan;
--preview 5 baris.
select c.customer_unique_id, count(*) as frequency, max(order_purchase_timestamp) as pembelian_terakhir
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id
limit 5;

-- 02. Tanggal acuan historis: sehari setelah pembelian delivered paling akhir, 
--yaitu 2018-08-30.
select max(o.order_purchase_timestamp)
from olist_orders_dataset as o
where o.order_status = 'delivered';

-- 03. Pemeriksaan RFM pelanggan dengan catatan pembayaran tidak tersedia; 
--Monetary belum diketahui, bukan 0.
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' and c.customer_unique_id = '830d5b7aaa3b6f1e9ad63703bec97d23'
group by c.customer_unique_id
limit 5;

-- 04. Audit jumlah pesanan delivered tanpa pasangan di tabel pembayaran; 
--hasil pemeriksaan: 1.
select count(*)
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' and p.order_id is null;

-- 05. Identifikasi pesanan delivered tanpa catatan pembayaran.
select c.customer_unique_id, o.order_id 
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' and p.order_id is null;

-- 06. Sebaran jumlah pelanggan berdasarkan frequency.
select rfm.frequency, count(*) as jumlah_pelanggan
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm
group by rfm.frequency 
order by rfm.frequency;

-- 07. Kelompok F: sekali_beli untuk frequency 1, repeat untuk frequency minimal 2.
select case when rfm.frequency = 1 then  'sekali_beli'
else 'repeat'
end as kelompok_f,
count(*) as jumlah_pelanggan
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm
group by kelompok_f;

-- 08. Kelompok R: Recency hingga 219 hari dan di atas 219 hari; 
--batas relatif terhadap median, bukan aktif/tidak aktif.
select 
case when rfm.recency_hari <= 219 then  'hingga_median'
else 'di_atas_median'
end as kelompok_r,
count(*) as jumlah_pelanggan
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm
group by kelompok_r;

-- 09. Median Monetary: 107.78 dari nilai pembayaran yang tersedia; 
--NULL tidak masuk perhitungan median.
select percentile_cont(0.5) within group (order by rfm.monetary) as median_m
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm;

-- 10. Kelompok M: minimal median, di bawah median, dan belum diketahui; 
--NULL tidak dianggap 0.
select 
case when rfm.monetary is null then  'belum_diketahui'
when rfm.monetary >= 107.78 then 'minimal_median'
else 'di_bawah_median'
end as kelompok_m,
count(*) as jumlah_pelanggan
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm
group by kelompok_m;

-- 11. Preview tiga label RFM per pelanggan; bukan total populasi.
select rfm.customer_unique_id,
case when rfm.frequency = 1 then  'sekali_beli'
else 'repeat'
end as kelompok_f,
case when rfm.recency_hari <= 219 then  'hingga_median'
else 'di_atas_median'
end as kelompok_r,
case when rfm.monetary is null then  'belum_diketahui'
when rfm.monetary >= 107.78 then 'minimal_median'
else 'di_bawah_median'
end as kelompok_m
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm
limit 5;

-- 12. Distribusi kombinasi label R-F-M; 
--hasil pemeriksaan: 9 kombinasi, total 93.358 pelanggan.
select count(*) as jumlah_pelanggan,
case when rfm.frequency = 1 then  'sekali_beli'
else 'repeat'
end as kelompok_f,
case when rfm.recency_hari <= 219 then  'hingga_median'
else 'di_atas_median'
end as kelompok_r,
case when rfm.monetary is null then  'belum_diketahui'
when rfm.monetary >= 107.78 then 'minimal_median'
else 'di_bawah_median'
end as kelompok_m
from(
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm
group by kelompok_f, kelompok_r, kelompok_m;

select *
from (
select c.customer_unique_id, count(*) as frequency, 
max(order_purchase_timestamp) as pembelian_terakhir,
date '2018-08-30' - max(o.order_purchase_timestamp)::date as recency_hari,
sum(p.total_bayar) as monetary
from customers as c 
join olist_orders_dataset as o
on c.customer_id = o.customer_id
left join (select order_id, sum(payment_value) as total_bayar
from olist_order_payments_dataset
group by order_id) as p 
on o.order_id = p.order_id
where o.order_status = 'delivered' 
group by c.customer_unique_id) as rfm;



