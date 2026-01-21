/* =====================================================
   Object: nyc_dw.stg_yellow_trips
   Purpose: Stage raw yellow taxi data (clean types, keep governance cols)
   Author: Gokul
   ===================================================== */

-- Create staging table (optional if you already have raw -> fact directly)
CREATE TABLE IF NOT EXISTS nyc_dw.stg_yellow_trips (
  vendor_id              INTEGER,
  pickup_location_id     INTEGER,
  dropoff_location_id    INTEGER,
  pickup_datetime        TIMESTAMP,
  dropoff_datetime       TIMESTAMP,
  passenger_count        INTEGER,
  trip_distance          DECIMAL(10,2),
  fare_amount            DECIMAL(10,2),
  total_amount           DECIMAL(10,2),

  mdm_source_system      VARCHAR(30) DEFAULT 'nyc_taxi_trips',
  mdm_record_status      VARCHAR(20) DEFAULT 'ACTIVE',
  mdm_last_updated       TIMESTAMP DEFAULT GETDATE()
);

-- Example “basic quality” view (optional)
-- SELECT COUNT(*) AS stg_rows FROM nyc_dw.stg_yellow_trips;
