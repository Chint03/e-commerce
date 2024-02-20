-- Case 1. 
-- Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar? 
-- Gunakan is_valid = 1 untuk memfilter data transaksi.

select
	extract(month from order_date) Bulan,
    sum(after_discount) Total_Transaksi
from order_detail
where extract(year from order_date) = 2021 
      and is_valid = 1
group by Bulan
order by Total_Transaksi desc
limit 1;

	
-- Case 2. 
-- Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar? 
-- Gunakan is_valid = 1 untuk memfilter data transaksi.

select
	s.category,
	sum(o.after_discount) Total_Transaksi
from order_detail o
join sku_detail s on o.sku_id = s.id
where extract(year from o.order_date) = 2022
and o.is_valid = 1
group by s.category
order by Total_Transaksi desc
limit 1;


-- Case 3.
-- Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. 
-- Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami 
-- penurunan nilai transaksi dari tahun 2021 ke 2022. 
-- Gunakan is_valid = 1 untuk memfilter data transaksi.

select
	category,
	max(case when Tahun = 2021 then Total_Transaksi end) Total_2021,
	max(case when Tahun = 2022 then Total_Transaksi end) Total_2022,
    round(((max(case when Tahun = 2022 then Total_Transaksi end) 
    - max(case when Tahun = 2021 then Total_Transaksi end))
    /(max(case when Tahun = 2021 then Total_Transaksi end))) * 100, 2) 
    as Persentase,
case
    when 
	max(case when Tahun = 2021 then Total_Transaksi end) 
    < max(case when Tahun = 2022 then Total_Transaksi end) then 'Meningkat'
    when 
	max(case when Tahun = 2021 then Total_Transaksi end) 
    > max(case when Tahun = 2022 then Total_Transaksi end) then 'Menurun'
    else 'Tidak Berubah' end  Keterangan
 from (
    select
        s.category,
        extract(year from o.order_date) Tahun,
        round(sum(o.after_discount),0) Total_Transaksi
    from order_detail o
    join sku_detail s on o.sku_id = s.id
    where
        o.is_valid = 1 and
        extract(year from o.order_date) in (2021, 2022)
    group by s.category, extract(year from o.order_date)
    ) TransaksiPerKategori
	group by category
    order by Keterangan;
	

-- Case 4.
-- Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order). 
-- Gunakan is_valid = 1 untuk memfilter data transaksi.

select
    payment_method,
    count(distinct id) Total_Pembayaran
from (
    select
        o.id,
        p.payment_method
    from order_detail o
    join payment_detail p on o.payment_id = p.id
    where o.is_valid = 1 and 
		extract(year from o.order_date) = 2022
    ) OrderPayments
group by payment_method
order by Total_Pembayaran desc
limit 5;

-- Case 5. 
-- Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
-- 1. Samsung
-- 2. Apple
-- 3. Sony
-- 4. Huawei
-- 5. Lenovo
-- Gunakan is_valid = 1 untuk memfilter data transaksi.

with Pemesanan as (
    select  distinct o.id, s.sku_name,
        case
            when lower(s.sku_name) like '%samsung%' then 'Samsung'
            when lower(s.sku_name) like '%sony%' then 'Sony'
            when lower(s.sku_name) like '%huawei%' then 'Huawei'
            when lower(s.sku_name) like '%lenovo%' then 'Lenovo'
            when lower(s.sku_name) like '%apple%'  then 'Apple'
			when lower(s.sku_name) like '%iphone%' then 'Apple'
            when lower(s.sku_name) like '%imac%' then 'Apple'
            when lower(s.sku_name) like '%macbook%' then 'Apple'
        end as Nama_Produk,
        o.qty_ordered as Total_Pemesanan,
        o.after_discount as Total_Transaksi
    from order_detail o
    join sku_detail s on (s.id = o.sku_id)
    where o.is_valid = 1)
select  Nama_Produk,
		sum(Total_Pemesanan) as Total_Pemesanan, 
        sum(Total_Transaksi) as Total_Transaksi
from Pemesanan
where Nama_Produk is not null
group by Nama_Produk
order by Total_Transaksi desc;
