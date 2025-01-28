CREATE OR REPLACE TABLE `bigquerysandbox-449016.kf_analisa.kf_analisa` AS
WITH price_with_margin AS (
  SELECT 
    ft.transaction_id,
    ft.date,
    ft.branch_id,
    kc.branch_name,
    kc.kota,
    kc.provinsi,
    kc.rating as rating_cabang,
    ft.customer_name,
    ft.product_id,
    p.product_name,
    p.price as actual_price,
    ft.discount_percentage,
    -- Calculate gross profit percentage based on price ranges
    CASE 
      WHEN p.price <= 50000 THEN 10
      WHEN p.price > 50000 AND p.price <= 100000 THEN 15
      WHEN p.price > 100000 AND p.price <= 300000 THEN 20
      WHEN p.price > 300000 AND p.price <= 500000 THEN 25
      WHEN p.price > 500000 THEN 30
    END as persentase_gross_laba,
    -- Calculate net sales (price after discount)
    ROUND(p.price * (1 - ft.discount_percentage/100), 2) as nett_sales,
    -- Calculate net profit
    ROUND(
      p.price * (1 - ft.discount_percentage/100) * 
      CASE 
        WHEN p.price <= 50000 THEN 0.10
        WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
        WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
        WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
        WHEN p.price > 500000 THEN 0.30
      END,
      2
    ) as nett_profit,
    ft.rating as rating_transaksi
  FROM `bigquerysandbox-449016.kf_final_transaction.kf_final_transaction` ft
  LEFT JOIN `bigquerysandbox-449016.kf_kantor_cabang.kf_kantor_cabang` kc
    ON ft.branch_id = kc.branch_id
  LEFT JOIN `bigquerysandbox-449016.kf_product.kf_product` p
    ON ft.product_id = p.product_id
)
SELECT 
  transaction_id,
  date,
  branch_id,
  branch_name,
  kota,
  provinsi,
  rating_cabang,
  customer_name,
  product_id,
  product_name,
  actual_price,
  discount_percentage,
  persentase_gross_laba,
  nett_sales,
  nett_profit,
  rating_transaksi
FROM price_with_margin
ORDER BY date, transaction_id;
