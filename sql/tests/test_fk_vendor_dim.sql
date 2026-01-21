-- Referential integrity: vendor_id must exist in vendor_dim
SELECT COUNT(*) AS missing_vendor_dim
FROM nyc_dw.trip_fact f
LEFT JOIN nyc_dw.vendor_dim v
  ON f.vendor_id = v.vendor_id
WHERE v.vendor_id IS NULL;
