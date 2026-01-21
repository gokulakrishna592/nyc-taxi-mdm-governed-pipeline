/* =====================================================
   Object: nyc_dw.zone_dim
   Purpose: Zone dimension derived from taxi_zones golden records
   Author: Gokul
   ===================================================== */

CREATE TABLE IF NOT EXISTS nyc_dw.zone_dim (
  location_id        INTEGER NOT NULL,
  borough            VARCHAR(50),
  zone_name          VARCHAR(100),
  service_zone       VARCHAR(50),

  mdm_source_system  VARCHAR(30) DEFAULT 'taxi_zones_golden',
  mdm_record_status  VARCHAR(20) DEFAULT 'ACTIVE',
  mdm_last_updated   TIMESTAMP DEFAULT GETDATE(),

  PRIMARY KEY (location_id)
)
DISTSTYLE ALL
SORTKEY(location_id);
