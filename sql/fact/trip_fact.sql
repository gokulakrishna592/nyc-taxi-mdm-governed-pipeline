/* =====================================================
   Object: nyc_dw.trip_fact
   Purpose: Fact table for NYC Yellow Taxi trips analytics
   Joins: vendor_dim + zone_dim
   Author: Gokul
   ===================================================== */

CREATE TABLE IF NOT EXISTS nyc_dw.trip_fact (
  trip_id               BIGINT IDENTITY(1,1),
  vendor_id             INTEGER NOT NULL,
  pickup_location_id    INTEGER NOT NULL,
  dropoff_location_id   INTEGER NOT NULL,

  pickup_datetime       TIMESTAMP,
  dropoff_datetime      TIMESTAMP,

  passenger_count       INTEGER,
  trip_distance         DECIMAL(10,2),

  fare_amount           DECIMAL(10,2),
  total_amount          DECIMAL(10,2),

  mdm_source_system     VARCHAR(30) DEFAULT 'nyc_taxi_trips',
  mdm_record_status     VARCHAR(20) DEFAULT 'ACTIVE',
  mdm_last_updated      TIMESTAMP DEFAULT GETDATE(),

  PRIMARY KEY(trip_id)
)
DISTSTYLE AUTO;
