# Master Data Management (MDM) Documentation
**Project:** NYC Taxi MDM Governed Pipeline  
**Domain Masters:** Taxi Zones, Vendor Master  
**Purpose:** Create trusted “golden records” for master entities and publish them for analytics consumption.

---

## 1. What is Master Data in this Project?
Master Data represents **core reference entities** used repeatedly across analytical and operational datasets.

### Master Entities
| Entity | Why it matters | Used by |
|-------|-----------------|---------|
| Taxi Zone | Standardizes pickup/dropoff location identity | trip fact joins, zone analytics |
| Vendor | Standardizes vendor identity and attributes | trip fact joins, vendor analytics |

Master data is published into the **S3 Master Zone** and used to build dimensional tables in **Amazon Redshift**.

---

## 2. Master Data Sources
The MDM layer ingests reference/master datasets (batch) and aligns them into canonical schemas.

### Inputs
- Taxi Zones reference dataset
- Vendor reference dataset

### Landing
- **S3 Raw Zone**: stores the ingested master datasets as received.

---

## 3. Standardization & Staging
Master datasets are standardized using Glue/Spark transformations to ensure consistency.

### Standardization actions
- Schema normalization (column names + data types)
- Trimming whitespace and normalizing text casing
- Handling nulls and invalid values
- Canonical attribute mapping

### Canonical Fields (Example)
**Zone Master**
- `zone_id`
- `zone_name`
- `borough`
- `service_zone`

**Vendor Master**
- `vendor_id`
- `vendor_name`

---

## 4. Matching & Deduplication
Master records may contain duplicates or conflicting versions. The pipeline resolves these using matching rules.

### Match Rules (Examples)
- **Exact match** on:
  - `zone_id`
  - `vendor_id`
- **Fuzzy match** on:
  - normalized(`zone_name`)
  - normalized(`vendor_name`)

### Output
- Candidate clusters (possible duplicates)
- Match confidence (rule-based)
- Deduplicated master candidates

---

## 5. Survivorship Rules (Golden Record Selection)
When multiple records represent the same entity, the pipeline chooses a single **golden record**.

### Survivorship Strategy (Rule-based)
1. Prefer non-null attributes
2. Prefer latest record based on `last_updated_ts`
3. Prefer curated/staged quality source over raw source  
   **Priority:** curated > processed > raw

### Golden Record Output
- One trusted record per master entity key

---

## 6. Versioning & History Tracking (SCD Type 2)
To preserve history of master data changes over time, the project implements **Slowly Changing Dimension Type 2**.

### Why SCD Type 2?
- Maintains historical correctness of analytics
- Enables time-travel reporting and auditing
- Ensures dimensional consistency

### SCD2 Columns
| Column | Meaning |
|--------|---------|
| `effective_start_date` | When this version becomes active |
| `effective_end_date` | When this version expires (NULL for current) |
| `is_current` | TRUE for active record |
| `record_hash` / `version_number` | Change detection / version tracking |

### Master Tables (Example)
- `master.zone_master`
- `master.vendor_master`

---

## 7. Publishing Master Data
After deduplication + survivorship + SCD2 versioning, master data is published to:

- **S3 Master Zone**: `s3://.../master/`
- Consumed downstream into:
  - `zone_dim` (current golden records)
  - `vendor_dim` (current golden records)

---

## 8. Consumption into Analytics (Dimensional Model)
The serving layer uses the master zone outputs to build dimensions and join with trip facts.

### Derived Dimensional Tables
- `zone_dim` derived from `master.zone_master` (current records only)
- `vendor_dim` derived from `master.vendor_master` (current records only)
- `fact_trips` derived from curated taxi trips

---

## 9. Governance Controls for Master Data
Master data publication is gated by governance rules:

### Controls
- Freshness checks (master must be updated within threshold)
- Data quality checks (null checks, key uniqueness, validity checks)
- Audit logging for every pipeline execution (`run_id` tracked)

### Outcome
Only master datasets that pass governance checks are published into the **master zone** and downstream analytics.
