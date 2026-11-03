# Olist Customer Behavior Analysis

Analisis perilaku pelanggan e-commerce Olist (Brasil) dengan SQL: sebaran pelanggan, repeat purchase, segmentasi RFM, dan hubungan keterlambatan pengiriman dengan skor review.

## Tujuan dan pertanyaan bisnis

Proyek portofolio ini menjawab beberapa pertanyaan bisnis:

- Di mana pelanggan Olist berada dan bagaimana sebarannya?
- Berapa banyak pelanggan yang kembali membeli (repeat purchase)?
- Siapa segmen pelanggan paling potensial menurut RFM (Recency, Frequency, Monetary)?
- Apakah keterlambatan pengiriman berhubungan dengan skor review?

## Dataset

Olist Brazilian E-Commerce Public Dataset, Kaggle:
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Data mentah (CSV) tidak disertakan di repo ini; unduh langsung dari Kaggle lalu impor ke PostgreSQL. Data bersifat historis dengan tanggal acuan analisis 30 Agustus 2018.

Catatan: script 01 hanya membuat tabel customers; tabel Olist lainnya diimpor dari CSV Kaggle lewat DBeaver sebelum menjalankan script analisis.

## Alat

- PostgreSQL 18 + DBeaver (analisis SQL)
- Power BI (dashboard interaktif)

## Rencana struktur repo

- `sql/` - script analisis bernomor sesuai urutan pengerjaan (01-12)
- `data-raw/` - CSV dari Kaggle (tidak diunggah)
- `results/` - hasil query
- `docs/` - dokumentasi pendukung
- `olist_dashboard_v2.pbix` - dashboard Power BI

## Alur analisis

1. `01_create_tables.sql` - pembuatan tabel
2. `02_customer_exploration.sql` - eksplorasi pelanggan dan sebaran geografis
3. `03_orders_exploration.sql` - eksplorasi pesanan dan keterlambatan pengiriman
4. `04_table_relationships.sql` - relasi antar tabel (termasuk customer_id vs customer_unique_id)
5. `05_payments_checks.sql` - pemeriksaan pembayaran
6. `06_reviews_checks.sql` - pemeriksaan review
7. `07_repeat_purchase.sql` - repeat purchase: dua definisi, GROUP BY, HAVING, subquery, ROW_NUMBER, LAG
8. `08_rfm_analysis.sql` - segmentasi RFM
9. `09_delivery_reviews_analysis.sql` - keterlambatan vs skor review
10. `10_audit_konsistensi.sql` - audit konsistensi hasil
11. `11_dashboard_repeat.sql` - tabel pelanggan_rfm untuk dashboard
12. `12_bridge_kategori.sql` - tabel bridge kategori pesanan kedua

## Temuan utama

- Dari 93.358 pelanggan dengan pesanan delivered, 2.801 (3,0%) pernah membeli lebih dari sekali. Angka ini adalah proporsi repeat sepanjang data, bukan retention rate berbasis kohort.
- Median jeda pembelian pertama ke kedua adalah 29 hari (khusus pelanggan repeat).
- Segmentasi RFM (acuan 30 Agustus 2018): median Recency 219 hari, median Monetary R$107,78 (nilai pembayaran tercatat, bukan keuntungan).
- Keterlambatan pengiriman berkaitan dengan skor review yang lebih rendah: pesanan tepat waktu rata-rata 4,29, pesanan terlambat 2,27. Ini hubungan korelatif, bukan bukti sebab-akibat.

## Dashboard

Dashboard interaktif Power BI (`olist_dashboard_v2.pbix`) berisi:

- Sebaran kelompok pelanggan (repeat vs sekali beli)
- Distribusi jeda pembelian pertama ke kedua
- Kategori pada pesanan kedua
- Matriks segmen RFM
- Kartu KPI: total pelanggan, pelanggan repeat, persen repeat, median jeda

Tabel `pelanggan_rfm` terhubung ke tabel bridge kategori dengan filter dua arah. Pilihan pada satu visual memfilter atau menyorot visual lain; kartu KPI mengikuti pilihan aktif (kartu tidak memfilter visual lain).

## Rekomendasi bisnis (usulan)

Usulan uji campaign untuk mendorong pembelian kembali:

- Sasaran: 1.094 pelanggan pada data historis - pernah repeat, Recency di atas median, Monetary minimal median.
- Kandidat materi: kategori cama_mesa_banho, dibeli 185 pelanggan pada pesanan kedua segmen tersebut (pembanding: moveis_decoracao, 140 pelanggan).
- Cara menilai: bagi acak pelanggan ke kelompok penerima dan kelompok pembanding, amati dalam waktu yang sama, bandingkan persentase yang membeli lagi di kategori apa pun dan pantau nilai penjualan.

Batasan: campaign masih berupa usulan dan belum dijalankan; kandidat kategori bukan bukti minat; keuntungan belum bisa disimpulkan tanpa data biaya dan margin; penerapan nyata memerlukan data terbaru dan transaksi setelah campaign.

## Definisi dan catatan data

- Repeat purchase memakai definisi B: minimal 2 pesanan berstatus delivered (2.801 pelanggan). Definisi A mencakup semua status pesanan (2.997 pelanggan).
- Monetary adalah total nilai pembayaran tercatat (payment_value), bukan keuntungan. Satu pelanggan tidak diketahui nilainya dan dipisahkan, bukan dianggap nol.
- Label RFM (di atas/di bawah median) adalah median dataset, bukan ambang churn atau profitabilitas yang tervalidasi.
- 829 pelanggan repeat berjeda 0 hari kalender antara pesanan pertama dan kedua, sehingga jeda nol tidak otomatis berarti kunjungan kembali di hari lain.
