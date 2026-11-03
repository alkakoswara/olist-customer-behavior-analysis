-- Menampilkan 5 pesanan delivered 
--untuk memeriksa selisih hari kalender antara tanggal tiba dan tanggal estimasi.
-- selisih_hari = tanggal tiba - tanggal estimasi.
select order_id, order_estimated_delivery_date, order_delivered_customer_date,
(order_delivered_customer_date)::date  - (order_estimated_delivery_date) ::date as selisih_hari,
case 
when (order_delivered_customer_date)::date - (order_estimated_delivery_date)::date is null then 'belum_diketahui'
when (order_delivered_customer_date)::date - (order_estimated_delivery_date)::date > 0 then 'terlambat'
else 'tepat_waktu'
end as status_pengiriman
from olist_orders_dataset
where order_status = 'delivered'
limit 5;

-- Menampilkan Status Pengiriman
select status_pengiriman, count(*)
from (
select 
case 
when (order_delivered_customer_date)::date - (order_estimated_delivery_date)::date is null then 'belum_diketahui'
when (order_delivered_customer_date)::date - (order_estimated_delivery_date)::date > 0 then 'terlambat'
else 'tepat_waktu'
end as status_pengiriman
from olist_orders_dataset as s
where order_status = 'delivered'
) as t
group by status_pengiriman;


-- 1. Ringkasan review per pesanan, satu baris per order_id.
-- Semua skor dalam pesanan dirata-rata; jumlah baris review tetap dicatat.
-- Ringkasan ini digunakan agar setiap pesanan berbobot sama pada analisis utama.
select avg(review_score) as skor_review, 
order_id, 
count(*) as jumlah_baris_review
from olist_order_reviews_dataset
group by order_id;

-- 2. Audit jumlah baris ringkasan review.
-- Hasil sesi ini: 98.673, sesuai jumlah order_id berbeda pada audit sebelumnya.
-- Cakupan: seluruh pesanan yang ada di tabel reviews, belum khusus delivered.
select count(*)
from (
select avg(review_score) as skor_review, 
order_id, 
count(*) as jumlah_baris_review
from olist_order_reviews_dataset
group by order_id
) as ringkasan;

-- 3. Preview 5 pesanan delivered beserta ringkasan review-nya.
-- LEFT JOIN mempertahankan pesanan tanpa pasangan review; kolom review menjadi NULL, bukan 0.
select o.order_id, r.skor_review, r.jumlah_baris_review
from olist_orders_dataset as o
left join (
select avg(review_score) as skor_review, 
order_id, 
count(*) as jumlah_baris_review
from olist_order_reviews_dataset
group by order_id
) as r on o.order_id = r.order_id
where o.order_status = 'delivered'
limit 5;

-- 4. Audit jumlah baris setelah orders LEFT JOIN ringkasan review.
-- Hasil sesi ini: 96.478, sama dengan jumlah pesanan delivered sebelum JOIN
select count(*)
from (
select o.order_id, r.skor_review, r.jumlah_baris_review
from olist_orders_dataset as o
left join (
select avg(review_score) as skor_review, 
order_id, 
count(*) as jumlah_baris_review
from olist_order_reviews_dataset
group by order_id
) as r on o.order_id = r.order_id
where o.order_status = 'delivered'
) as gabungan;

-- 5. Preview 5 pesanan delivered dengan skor dan label keterlambatan.
-- Selisih = tanggal tiba - tanggal estimasi, berdasarkan hari kalender (::date).
-- NULL: belum_diketahui; positif: terlambat; nol atau negatif: tepat_waktu.
select o.order_id, r.skor_review, r.jumlah_baris_review,
case 
when (o.order_delivered_customer_date)::date - (o.order_estimated_delivery_date)::date is null then 'belum_diketahui'
when (o.order_delivered_customer_date)::date - (o.order_estimated_delivery_date)::date > 0 then 'terlambat'
else 'tepat_waktu'
end as status_pengiriman
from olist_orders_dataset as o
left join (
select avg(review_score) as skor_review, 
order_id, 
count(*) as jumlah_baris_review
from olist_order_reviews_dataset
group by order_id
) as r on o.order_id = r.order_id
where o.order_status = 'delivered'
limit 5;


-- 6. Analisis utama: membandingkan rata-rata skor per kelompok status_pengiriman.
-- COUNT(*) menghitung semua pesanan; COUNT(skor_review) menghitung yang punya skor.
-- AVG(skor_review) melewati NULL, bukan menggantinya dengan 0.
-- Hasil sesi ini: tepat_waktu 4,29 (89.443 pesanan berskor), terlambat 2,27 (6.381 pesanan berskor).
-- Kelompok belum_diketahui berisi 8 pesanan dan ditampilkan untuk pemeriksaan.
-- Temuan menunjukkan hubungan, belum membuktikan keterlambatan sebagai penyebab skor rendah.
select status_pengiriman,
count(*) as jumlah_pesanan,
count(skor_review) as pesanan_ada_skor,
avg(skor_review) as rata_rata_skor
from (
select o.order_id, r.skor_review, r.jumlah_baris_review,
case 
when (o.order_delivered_customer_date)::date - (o.order_estimated_delivery_date)::date is null then 'belum_diketahui'
when (o.order_delivered_customer_date)::date - (o.order_estimated_delivery_date)::date > 0 then 'terlambat'
else 'tepat_waktu'
end as status_pengiriman
from olist_orders_dataset as o
left join (
select avg(review_score) as skor_review, 
order_id, 
count(*) as jumlah_baris_review
from olist_order_reviews_dataset
group by order_id
) as r on o.order_id = r.order_id
where o.order_status = 'delivered'
) as t
group by status_pengiriman;











