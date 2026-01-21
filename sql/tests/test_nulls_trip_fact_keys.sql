-- Null check for critical foreign keys
SELECT
  SUM(CASE WHEN vendor_id IS NULL THEN 1 ELSE 0 END) AS null_vendor_id,
  SUM(CASE WHEN pickup_location_id IS NULL THEN 1 ELSE 0 END) AS null_pickup_location_id,
  SUM(CASE WHEN dropoff_location_id IS NULL THEN 1 ELSE 0 END) AS null_dropoff_location_id
FROM nyc_dw.trip_fact;
