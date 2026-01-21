/* =====================================================
   Object: nyc_dw.vendor_dim
   Purpose: Vendor dimension derived from MDM vendor master
   Author: Gokul
   ===================================================== */

CREATE TABLE IF NOT EXISTS nyc_dw.vendor_dim (
  vendor_id          INTEGER NOT NULL,
  vendor_name        VARCHAR(50),

  mdm_source_system  VARCHAR(30) DEFAULT 'vendor_master_manual',
  mdm_record_status  VARCHAR(20) DEFAULT 'ACTIVE',
  mdm_last_updated   TIMESTAMP DEFAULT GETDATE(),

  PRIMARY KEY (vendor_id)
)
DISTSTYLE ALL
SORTKEY(vendor_id);
