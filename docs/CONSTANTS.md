# Project Constants - Global Shipping Disruption Analytics

These values are the same for everyone. Nobody changes them alone.
To change one: open a pull request that edits this file, and the leader approves it.

## 1. Data snapshot (frozen - never re-download)

| Item | Value |
|---|---|
| Folder | `data/raw/snapshot_2026-11-08/` |
| Daily file | `Daily_Chokepoints_Data.csv` - 80,332 rows, 21 columns |
| Chokepoints file | `PortWatch_chokepoints_database.csv` - 28 rows |
| Events file | `portwatch_disruptions_database_-3978591324501330360.csv` - 132 rows |
| Date range | 2019-01-01 to 2026-11-08 (2,869 days x 28 chokepoints) |
| Integrity check | `CHECKSUMS.txt` in the same folder |

Check your copy (Windows PowerShell): `Get-FileHash <file> -Algorithm SHA256` and compare with `CHECKSUMS.txt`.
Mac/Linux: `sha256sum -c CHECKSUMS.txt`.

## 2. Architecture

| Item | Value |
|---|---|
| Layers | Bronze (SQL, BULK INSERT) -> Silver (dbt) -> Gold (dbt) -> Python analysis -> Power BI |
| Database name | `global_shipping_dw` |
| Schemas | `bronze`, `silver`, `gold` |
| dbt profile name / target | `global_shipping_dw` / `dev` |
| `load_date` | Only in Bronze |

## 3. Grain (one row means...)

| Table | One row per |
|---|---|
| `fact` table | chokepoint per day |
| `dim_chokepoint` | chokepoint |
| `dim_date` | calendar day |
| `dim_event` | event |
| `bridge_event_chokepoint` | event + chokepoint pair |

## 4. Naming rules

- Everything is lowercase `snake_case` (tables, columns, files, folders).
- Table prefixes: `dim_`, `fact_`, `bridge_`.
- Branches: `feature/m<member number>-<short-task>` (example `feature/m3-silver-daily`).
- Commit prefixes: `feat:`, `fix:`, `docs:`, `test:`, `chore:`.
- Notebooks (numbered, outputs cleared before commit):
  `01_data_quality`, `02_feature_engineering`, `03_univariate_eda`, `04_bivariate_multivariate_eda`, `05_business_insights`.

## 5. Keys and columns

| Item | Value |
|---|---|
| Chokepoint key | `chokepoint_code` (example `chokepoint1`) |
| Date key | `date_key`, integer like `20261028` |
| Event key | `event_id` (the raw `eventid`) |
| Renames (only in Silver) | `portid` -> `chokepoint_code`, `portname` -> `chokepoint_name` |
| `dim_chokepoint` columns | `chokepoint_code`, `chokepoint_name`, `fullname`, `country`, `ISO3`, `continent`, `lat`, `lon` |
| Tables in Gold | fact table, `dim_chokepoint`, `dim_date` (fuller version from the architecture file), `dim_event`, `bridge_event_chokepoint` |
| Capacity-total check | Compare counts only |

## 6. Date formats

| Source | Raw format | Rule |
|---|---|---|
| Daily file | text `yyyy/mm/dd` | Convert to `DATE` in Silver. Never change after that. |
| Events file | `M/D/YYYY h:mm AM` | Convert to `DATE` in Silver. Never change after that. |

## 7. Tools

| Item | Value |
|---|---|
| ODBC driver | ODBC Driver 18 for SQL Server |
| dbt packages | pinned in `requirements.txt` |
| SQL Server version | |
| Python version | |
| Power BI Desktop release | |

## 8. Business rules (one value, one place)

Rule values live in one file only (dbt `vars:` or a Python constants file). Nobody types them into their own code.

| Rule | Value | Owner | Decide before |
|---|---|---|---|
| How events map to chokepoints | | Member 1 | Gold builds `bridge_event_chokepoint` |
| Baseline window | | Member 2 (Feature Engineering) | Anyone calculates impact or recovery |
| Disruption window | | Member 2 (Feature Engineering) | Anyone calculates impact or recovery |
| Recovery rule | | Member 2 (Feature Engineering) | Anyone calculates impact or recovery |

The event-to-chokepoint rule is written in `docs/schema/event_chokepoint_rule.md`.
