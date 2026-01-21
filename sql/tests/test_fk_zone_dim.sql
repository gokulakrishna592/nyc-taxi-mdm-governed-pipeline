-- Referential integrity: pickup_location_id must exist in zone_dim
SELECT COUNT(*) AS missing_zone_dim
FROM nyc_dw.trip_fact f
LEFT JOIN nyc_dw.zone_dim z
  ON f.pickup_location_id = z.location_id
WHERE z.location_id IS NULL;
