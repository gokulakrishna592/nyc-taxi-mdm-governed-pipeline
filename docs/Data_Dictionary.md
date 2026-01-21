# Data Dictionary
**Project:** NYC Taxi MDM Governed Pipeline  
**Purpose:** Define datasets, tables, columns, and key business meanings across S3 zones + MDM + dimensional model.

---

## 1. S3 Data Lake Zones
| Zone | Purpose | Example Path |
|------|---------|--------------|
| Raw | Original ingested datasets (no transformations) | `s3://<bucket>/raw/` |
| Processed | Cleaned + standardized datasets | `s3://<bucket>/processed/` |
| Curated | Analytics-ready datasets with business rules applied | `s3://<bucket>/curated/` |
| Master | Golden records + versioned master entities (MDM) | `s3://<bucket>/master/` |

---

## 2. Raw Layer Datasets

### 2.1 raw.taxi_trips
**Description:** NYC taxi trip-level raw dataset (batch ingested)

| Column | Type | Description |
|--------|------|-------------|
| `pickup_datetime` | timestamp | Trip pickup timestamp |
| `dropoff_datetime` | timestamp | Trip dropoff timestamp |
| `passenger_count` | int | Passenger count |
| `trip_distance` | decimal | Trip distance (miles) |
| `fare_amount` | decimal | Fare amount |
| `tip_amount` | decimal | Tip amount |
| `total_amount` | decimal | Total charged amount |
| `pickup_location_id` | int | Pickup zone identifier |
| `dropoff_location_id` | int | Dropoff zone identifier |
| `vendor_id` | int/string | Vendor identifier |

---

### 2.2 raw.taxi_zones
**Description:** Reference dataset defining taxi zones

| Column | Type | Description |
|--------|------|-------------|
| `zone_id` | int | Unique zone identifier |
| `zone_name` | string | Zone name |
| `borough` | string | Borough name |
| `service_zone` | string | Service zone classification |

---

### 2.3 raw.vendor_master
**Description:** Reference dataset defining taxi vendors

| Column | Type | Description |
|--------|------|-------------|
| `vendor_id` | int/string | Unique vendor identifier |
| `vendor_name` | string | Vendor name |

---

## 3. Processed Layer Datasets

### 3.1 processed.taxi_trips
**Description:** Cleaned + standardized trip dataset

| Column | Type | Description |
|--------|------|-------------|
| `pickup_datetime` | timestamp | Standardized pickup timestamp |
| `dropoff_datetime` | timestamp | Standardized dropoff timestamp |
| `trip_distance` | decimal | Validated trip distance |
| `total_amount` | decimal | Validated total amount |
| `pickup_location_id` | int | Cleaned pickup zone id |
| `dropoff_location_id` | int | Cleaned dropoff zone id |
| `vendor_id` | int/string | Cleaned vendor id |

---

## 4. Curated Layer Datasets

### 4.1 curated.fact_trips_source
**Description:** Analytics-ready trip dataset used to populate the fact table

| Column | Type | Description |
|--------|------|-------------|
| `trip_id` | string/int | Unique trip identifier (generated if needed) |
| `pickup_datetime` | timestamp | Pickup timestamp |
| `dropoff_datetime` | timestamp | Dropoff timestamp |
| `pickup_location_id` | int | Pickup zone id |
| `dropoff_location_id` | int | Dropoff zone id |
| `vendor_id` | int/string | Vendor id |
| `fare_amount` | decimal | Fare amount |
| `tip_amount` | decimal | Tip amount |
| `total_amount` | decimal | Total amount |

---

## 5. Master Zone (MDM Golden Records)

### 5.1 master.zone_master
**Description:** Golden records for taxi zones with SCD Type 2 versioning

| Column | Type | Description |
|--------|------|-------------|
| `zone_id` | int | Business key for zone |
| `zone_name` | string | Golden zone name |
| `borough` | string | Golden borough |
| `service_zone` | string | Golden service zone |
| `effective_start_date` | date | SCD2 start date |
| `effective_end_date` | date | SCD2 end date (NULL if current) |
| `is_current` | boolean | TRUE if current version |
| `record_hash` | string | Hash for change detection |

---

### 5.2 master.vendor_master
**Description:** Golden records for vendors with SCD Type 2 versioning

| Column | Type | Description |
|--------|------|-------------|
| `vendor_id` | int/string | Business key for vendor |
| `vendor_name` | string | Golden vendor name |
| `effective_start_date` | date | SCD2 start date |
| `effective_end_date` | date | SCD2 end date (NULL if current) |
| `is_current` | boolean | TRUE if current version |
| `record_hash` | string | Hash for change detection |

---

## 6. Dimensional Model (Amazon Redshift)

### 6.1 dim.zone_dim
**Description:** Zone dimension derived from current master zone records

| Column | Type | Description |
|--------|------|-------------|
| `zone_sk` | int | Surrogate key |
| `zone_id` | int | Business key |
| `zone_name` | string | Zone name |
| `borough` | string | Borough |
| `service_zone` | string | Service zone |
| `is_current` | boolean | Current master record indicator |

---

### 6.2 dim.vendor_dim
**Description:** Vendor dimension derived from current master vendor records

| Column | Type | Description |
|--------|------|-------------|
| `vendor_sk` | int | Surrogate key |
| `vendor_id` | int/string | Business key |
| `vendor_name` | string | Vendor name |
| `is_current` | boolean | Current master record indicator |

---

### 6.3 fact.fact_trips
**Description:** Fact table storing taxi trips for analytics

| Column | Type | Description |
|--------|------|-------------|
| `trip_sk` | int | Surrogate key |
| `pickup_datetime` | timestamp | Pickup timestamp |
| `dropoff_datetime` | timestamp | Dropoff timestamp |
| `zone_pickup_sk` | int | FK to zone_dim |
| `zone_dropoff_sk` | int | FK to zone_dim |
| `vendor_sk` | int | FK to vendor_dim |
| `fare_amount` | decimal | Fare |
| `tip_amount` | decimal | Tip |
| `total_amount` | decimal | Total |

---

## 7. Key Relationships
| From | To | Relationship |
|------|----|--------------|
| `fact_trips.zone_pickup_sk` | `zone_dim.zone_sk` | Many-to-one |
| `fact_trips.zone_dropoff_sk` | `zone_dim.zone_sk` | Many-to-one |
| `fact_trips.vendor_sk` | `vendor_dim.vendor_sk` | Many-to-one |

---

## 8. Notes
- Master data is versioned using **SCD Type 2** to preserve historical accuracy.
- Dimensions are derived using **current master records** (`is_current = TRUE`).
- Curated trip data is the trusted source for analytics fact creation.
