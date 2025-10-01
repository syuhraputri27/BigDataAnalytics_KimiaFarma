-- CTE presentase gross laba
WITH 
cte_pgl AS (
  SELECT 
    product_id,
    price,
    CASE 
      WHEN price <= 50000 THEN 0.10
      WHEN price > 50000 AND price <= 100000 THEN 0.15
      WHEN price > 100000 AND price <= 300000 THEN 0.20
      WHEN price > 300000 AND price <= 500000 THEN 0.25
      WHEN price > 500000 THEN 0.30
    END AS presentase_gross_laba
  FROM `kimia_farma.kf_product`
),
-- CTE nett sales (harga setelah diskon = price * (1-discount_percentage))
cte_ns AS ( 
  SELECT 
    transaction_id,
    discount_percentage, 
    price, 
    price*(1-discount_percentage) AS nett_sales
  FROM `kimia_farma.kf_final_transaction`
),
-- CTE nett profit (nett_profit = nett_sales * presentase_gross_laba)
cte_np AS (
  SELECT 
    ft.transaction_id, 
    cp.product_id, 
    cn.nett_sales, 
    cp.presentase_gross_laba,
    cn.nett_sales*cp.presentase_gross_laba AS nett_profit
  FROM cte_ns cn -- transaction_id
  INNER JOIN `kimia_farma.kf_final_transaction` ft -- transaction_id & product_id
  ON cn.transaction_id = ft.transaction_id
  INNER JOIN cte_pgl cp -- product_id
  ON ft.product_id = cp.product_id
)

SELECT 
  ft.transaction_id, 
  ft.date, 
  ft.branch_id, 
  kc.branch_name, 
  kc.kota, 
  kc.provinsi,
  ft.customer_name,
  ft.product_id,
  ft.price,
  ft.discount_percentage,
  cte_ns.nett_sales,
  cte_pgl.presentase_gross_laba,
  cte_np.nett_profit,
  ft.rating AS transaction_rating,
  kc.rating AS cabang_rating,
  p.product_name
FROM `kimia_farma.kf_final_transaction` ft
INNER JOIN `kimia_farma.kf_kantor_cabang` kc
ON ft.branch_id = kc.branch_id
INNER JOIN `kimia_farma.kf_product` p
ON ft.product_id = p.product_id
INNER JOIN cte_pgl
ON p.product_id = cte_pgl.product_id
INNER JOIN cte_ns
ON ft.transaction_id = cte_ns.transaction_id
INNER JOIN cte_np
ON ft.transaction_id = cte_np.transaction_id;

