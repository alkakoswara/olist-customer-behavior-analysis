--Untuk Power BI repeat
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

select 
case when jumlah_pesanan = 1 then 'Sekali_Beli'
else 'Repeat' 
end as segmen,
count(*) as jumlah_pelanggan
from(
select customer_unique_id, count(o.order_id) as jumlah_pesanan
from customers as c
join olist_orders_dataset as o
on c.customer_id  = o.customer_id
where o.order_status = 'delivered'
group by c.customer_unique_id
)
group by segmen

SELECT rfm.*, jeda.jeda_hari,
	case when rfm.frequency = 1 then  'sekali_beli'
		else 'repeat'
end as kelompok_f,
	case when rfm.recency_hari <= 219 then  'hingga_median'
		else 'di_atas_median'
end as kelompok_r,
	case when rfm.monetary is null then  'belum_diketahui'
	when rfm.monetary >= 107.78 then 'minimal_median'
		else 'di_bawah_median'
end as kelompok_m,
	case when jeda_hari is null then null 
	when jeda_hari = 0 then '0_hari'
	when jeda_hari <= 7 then '1-7_hari'
	when jeda_hari <= 30 then '8-30_hari'
	when jeda_hari <= 90 then '31-90_hari'
	when jeda_hari <= 180 then '91-180_hari'
else 'Lebih_Dari_180_hari'
end as rentang_jeda
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(*) AS frequency,
        MAX(o.order_purchase_timestamp) AS pembelian_terakhir,
        DATE '2018-08-30' - MAX(o.order_purchase_timestamp)::date AS recency_hari,
        SUM(p.total_bayar) AS monetary
    FROM customers AS c
    JOIN olist_orders_dataset AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN (
        SELECT order_id, SUM(payment_value) AS total_bayar
        FROM olist_order_payments_dataset
        GROUP BY order_id
    ) AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS rfm
LEFT JOIN (
    SELECT customer_unique_id, jeda_hari
    FROM (
        SELECT
            c.customer_unique_id,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp, o.order_id
            ) AS urutan,
            o.order_purchase_timestamp::date - (
                LAG(o.order_purchase_timestamp) OVER (
                    PARTITION BY c.customer_unique_id
                    ORDER BY o.order_purchase_timestamp, o.order_id
                )
            )::date AS jeda_hari
        FROM customers AS c
        JOIN olist_orders_dataset AS o
            ON c.customer_id = o.customer_id
        WHERE o.order_status = 'delivered'
    ) AS jeda_pesanan
    WHERE urutan = 2
) AS jeda
    ON rfm.customer_unique_id = jeda.customer_unique_id;



select count(*) as total,
       count(jeda_hari) as punya_jeda,
       count(rentang_jeda) as punya_label
from (
SELECT rfm.*, jeda.jeda_hari,
	case when rfm.frequency = 1 then  'sekali_beli'
		else 'repeat'
end as kelompok_f,
	case when rfm.recency_hari <= 219 then  'hingga_median'
		else 'di_atas_median'
end as kelompok_r,
	case when rfm.monetary is null then  'belum_diketahui'
	when rfm.monetary >= 107.78 then 'minimal_median'
		else 'di_bawah_median'
end as kelompok_m,
	case when jeda_hari is null then null 
	when jeda_hari = 0 then '0_hari'
	when jeda_hari <= 7 then '1-7_hari'
	when jeda_hari <= 30 then '8-30_hari'
	when jeda_hari <= 90 then '31-90_hari'
	when jeda_hari <= 180 then '91-180_hari'
else 'Lebih_Dari_180_hari'
end as rentang_jeda,
case when jeda_hari is null then null 
	when jeda_hari = 0 then 1
	when jeda_hari <= 7 then 2
	when jeda_hari <= 30 then 3
	when jeda_hari <= 90 then 4
	when jeda_hari <= 180 then 5
else 6
end as urutan_rentang
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(*) AS frequency,
        MAX(o.order_purchase_timestamp) AS pembelian_terakhir,
        DATE '2018-08-30' - MAX(o.order_purchase_timestamp)::date AS recency_hari,
        SUM(p.total_bayar) AS monetary
    FROM customers AS c
    JOIN olist_orders_dataset AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN (
        SELECT order_id, SUM(payment_value) AS total_bayar
        FROM olist_order_payments_dataset
        GROUP BY order_id
    ) AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS rfm
LEFT JOIN (
    SELECT customer_unique_id, jeda_hari
    FROM (
        SELECT
            c.customer_unique_id,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp, o.order_id
            ) AS urutan,
            o.order_purchase_timestamp::date - (
                LAG(o.order_purchase_timestamp) OVER (
                    PARTITION BY c.customer_unique_id
                    ORDER BY o.order_purchase_timestamp, o.order_id
                )
            )::date AS jeda_hari
        FROM customers AS c
        JOIN olist_orders_dataset AS o
            ON c.customer_id = o.customer_id
        WHERE o.order_status = 'delivered'
    ) AS jeda_pesanan
    WHERE urutan = 2
) AS jeda
    ON rfm.customer_unique_id = jeda.customer_unique_id
) as t;

select * 
from (
SELECT rfm.*, jeda.jeda_hari,
	case when rfm.frequency = 1 then  'sekali_beli'
		else 'repeat'
end as kelompok_f,
	case when rfm.recency_hari <= 219 then  'hingga_median'
		else 'di_atas_median'
end as kelompok_r,
	case when rfm.monetary is null then  'belum_diketahui'
	when rfm.monetary >= 107.78 then 'minimal_median'
		else 'di_bawah_median'
end as kelompok_m,
	case when jeda_hari is null then null 
	when jeda_hari = 0 then '0_hari'
	when jeda_hari <= 7 then '1-7_hari'
	when jeda_hari <= 30 then '8-30_hari'
	when jeda_hari <= 90 then '31-90_hari'
	when jeda_hari <= 180 then '91-180_hari'
else 'Lebih_Dari_180_hari'
end as rentang_jeda,
case when jeda_hari is null then null 
	when jeda_hari = 0 then 1
	when jeda_hari <= 7 then 2
	when jeda_hari <= 30 then 3
	when jeda_hari <= 90 then 4
	when jeda_hari <= 180 then 5
else 6
end as urutan_rentang
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(*) AS frequency,
        MAX(o.order_purchase_timestamp) AS pembelian_terakhir,
        DATE '2018-08-30' - MAX(o.order_purchase_timestamp)::date AS recency_hari,
        SUM(p.total_bayar) AS monetary
    FROM customers AS c
    JOIN olist_orders_dataset AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN (
        SELECT order_id, SUM(payment_value) AS total_bayar
        FROM olist_order_payments_dataset
        GROUP BY order_id
    ) AS p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS rfm
LEFT JOIN (
    SELECT customer_unique_id, jeda_hari
    FROM (
        SELECT
            c.customer_unique_id,
            ROW_NUMBER() OVER (
                PARTITION BY c.customer_unique_id
                ORDER BY o.order_purchase_timestamp, o.order_id
            ) AS urutan,
            o.order_purchase_timestamp::date - (
                LAG(o.order_purchase_timestamp) OVER (
                    PARTITION BY c.customer_unique_id
                    ORDER BY o.order_purchase_timestamp, o.order_id
                )
            )::date AS jeda_hari
        FROM customers AS c
        JOIN olist_orders_dataset AS o
            ON c.customer_id = o.customer_id
        WHERE o.order_status = 'delivered'
    ) AS jeda_pesanan
    WHERE urutan = 2
) AS jeda
    ON rfm.customer_unique_id = jeda.customer_unique_id
) as t
where jeda_hari is not null
limit 5;


	
	
	
	