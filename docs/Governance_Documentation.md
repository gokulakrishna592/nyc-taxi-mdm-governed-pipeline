# Governance Documentation
**Project:** NYC Taxi MDM Governed Pipeline  
**Objective:** Ensure data is trusted, traceable, monitored, and controlled through governance gates before analytics consumption.

---

## 1. Governance Goals
This project enforces governance to ensure:
- **Accuracy:** data quality rules validate critical fields
- **Freshness:** master and curated datasets meet recency requirements
- **Lineage:** transformations are traceable from raw → curated → master → serving
- **Auditability:** every run is logged with a `run_id`
- **Ownership:** clear accountability for datasets and rules
- **Controlled publishing:** only compliant datasets move forward

---

## 2. Governance Control Points in the Pipeline
Governance is applied through the orchestration layer:

### Orchestration
- **AWS Step Functions** controls the end-to-end pipeline flow
- Each stage is executed only if governance conditions are met

### Governance Gates (Decision Points)
1. **Freshness Gate**
2. **Data Quality Gate**
3. **Audit Logging Gate**
4. **Publish Control (only if passed)**

---

## 3. Freshness Validation
Freshness ensures that the pipeline is not producing analytics from outdated master data.

### Freshness Rule (Example)
- Master data must be updated within a maximum allowed threshold.

**Threshold Example**
- `max_age_hours = 24`

### Freshness Output
- `FRESH` → pipeline continues
- `STALE` → pipeline stops or routes to failure path

---

## 4. Data Quality Validation
Quality checks validate that key fields are complete and logically valid before publishing.

### Core Quality Rules (Examples)
| Rule ID | Rule Name | Check Type | Example Logic |
|--------|-----------|------------|---------------|
| Q001 | Primary Key Not Null | Completeness | `zone_id IS NOT NULL` |
| Q002 | Uniqueness | Uniqueness | no duplicate `zone_id` |
| Q003 | Amount Validity | Validity | `total_amount >= 0` |
| Q004 | Timestamp Validity | Validity | `pickup_datetime <= dropoff_datetime` |
| Q005 | Referential Integrity | Integrity | pickup/dropoff zone exists in zone master |

### Quality Output
- `PASS` → publish to curated/master zones
- `FAIL` → stop pipeline / alert

---

## 5. Master Data Governance (MDM Controls)
The master zone is governed more strictly because it feeds all downstream analytics.

### MDM Governance Controls
- Deduplication and matching logic is applied
- Golden record survivorship rules are enforced
- SCD Type 2 history is maintained for changes

### Master Publishing Rules
Master datasets are published only if:
- freshness checks pass
- quality score >= threshold
- audit logging succeeds

---

## 6. Audit Logging & Lineage
Every pipeline run generates an audit record.

### Audit Fields (Example)
| Field | Description |
|------|-------------|
| `run_id` | unique pipeline execution identifier |
| `execution_ts` | pipeline execution timestamp |
| `freshness_status` | FRESH / STALE |
| `quality_status` | PASS / FAIL |
| `quality_score` | computed quality score |
| `source_path` | S3 raw input path |
| `target_path` | S3 curated/master output path |

### Lineage Summary
**Raw → Processed → Curated → Master → Redshift/Athena → QuickSight**

This ensures traceability from ingestion to reporting.

---

## 7. Ownership & Stewardship
Ownership ensures accountability for datasets and governance rules.

### Example Ownership Model
| Asset | Owner | Responsibility |
|------|-------|----------------|
| Raw datasets | Data Engineering | ingestion + storage |
| Curated datasets | Data Engineering | transformations + quality |
| Master datasets | Data Steward / MDM Owner | golden record integrity |
| Dashboards | Analytics Team | reporting + KPI accuracy |

---

## 8. Monitoring & Alerting
Monitoring ensures visibility into failures, performance, and compliance.

### Monitoring Tools
- **Amazon CloudWatch Logs**: execution logs for Step Functions, Glue, Lambda
- **CloudWatch Alarms**: alerts on failures or rule violations

### Example Alerts
- Step Functions execution failed
- Glue job failed
- Freshness gate returned STALE
- Quality gate returned FAIL

---

## 9. CI/CD Governance-as-Code
This project supports repeatable deployments using Infrastructure as Code.

### CI/CD Component
- **AWS CloudFormation**
  - provisions pipeline resources consistently
  - enables reproducible environments

### Governance-as-Code Coverage
- Pipeline definitions (Step Functions JSON)
- Transformation scripts (SQL)
- Validation rules (SQL/Lambda logic)
- Infrastructure templates (CloudFormation)

---

## 10. Compliance Summary (What this pipeline guarantees)
✅ Data is validated before consumption  
✅ Master data is versioned and controlled  
✅ Every run is traceable and auditable  
✅ Monitoring provides operational visibility  
✅ Deployment is reproducible via IaC  
