/* =====================================================
   Project: Global Shipping Disruption Analytics
   File: 02_bronze_validation.sql
   Purpose: Bronze Layer Data Validation
   Author: Member 1 - Data Architect
   Database: global_shipping_dw
   ===================================================== */

USE global_shipping_dw;
GO

/* =====================================================
   TABLE 1: DAILY CHOKEPOINTS DATA
   ===================================================== */

-- 1. Row Count
SELECT COUNT(*) AS TotalRows
FROM bronze.Daily_Chokepoints_Data;
GO

-- 2. Duplicate (portid, date)
SELECT portid, date, COUNT(*) AS DuplicateCount
FROM bronze.Daily_Chokepoints_Data
GROUP BY portid, date
HAVING COUNT(*) > 1;
GO

-- 3. Duplicate ObjectId
SELECT ObjectId, COUNT(*) AS DuplicateCount
FROM bronze.Daily_Chokepoints_Data
GROUP BY ObjectId
HAVING COUNT(*) > 1;
GO

-- 4. Date Range and Coverage
SELECT
    MIN(date) AS FirstDate,
    MAX(date) AS LastDate,
    COUNT(DISTINCT date) AS DistinctDates,
    COUNT(DISTINCT portid) AS DistinctChokepoints
FROM bronze.Daily_Chokepoints_Data;
GO

-- 5. Rows per Chokepoint
SELECT
    portid,
    COUNT(*) AS TotalRows,
    MIN(date) AS FirstDate,
    MAX(date) AS LastDate,
    COUNT(DISTINCT date) AS DistinctDates
FROM bronze.Daily_Chokepoints_Data
GROUP BY portid
ORDER BY portid;
GO

-- 6. Negative Vessel Counts or Capacities
SELECT *
FROM bronze.Daily_Chokepoints_Data
WHERE n_container < 0
   OR n_dry_bulk < 0
   OR n_general_cargo < 0
   OR n_roro < 0
   OR n_tanker < 0
   OR n_cargo < 0
   OR n_total < 0
   OR capacity_container < 0
   OR capacity_dry_bulk < 0
   OR capacity_general_cargo < 0
   OR capacity_roro < 0
   OR capacity_tanker < 0
   OR capacity_cargo < 0
   OR capacity < 0;
GO

-- 7. Unmatched Chokepoint IDs
SELECT DISTINCT d.portid
FROM bronze.Daily_Chokepoints_Data AS d
LEFT JOIN bronze.PortWatch_chokepoints_database AS c
    ON d.portid = c.portid
WHERE c.portid IS NULL;
GO

-- 8. Vessel Count Arithmetic Validation
SELECT *
FROM bronze.Daily_Chokepoints_Data
WHERE n_cargo <> (
        n_container + n_dry_bulk + n_general_cargo + n_roro
      )
   OR n_total <> (
        n_container + n_dry_bulk + n_general_cargo
        + n_roro + n_tanker
      );
GO

-- 9. Capacity Reconciliation
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE
        WHEN capacity_cargo <>
             capacity_container + capacity_dry_bulk
             + capacity_general_cargo + capacity_roro
        THEN 1 ELSE 0
    END) AS CargoCapacityDifferences,
    SUM(CASE
        WHEN capacity <>
             capacity_container + capacity_dry_bulk
             + capacity_general_cargo + capacity_roro
             + capacity_tanker
        THEN 1 ELSE 0
    END) AS TotalCapacityDifferences
FROM bronze.Daily_Chokepoints_Data;
GO

-- 10. Port Name Matching
SELECT
    d.portid,
    d.portname AS DailyPortName,
    c.portname AS ReferencePortName
FROM bronze.Daily_Chokepoints_Data AS d
INNER JOIN bronze.PortWatch_chokepoints_database AS c
    ON d.portid = c.portid
WHERE LTRIM(RTRIM(d.portname)) <>
      LTRIM(RTRIM(c.portname));
GO


/* =====================================================
   TABLE 2: CHOKEPOINTS REFERENCE
   ===================================================== */

-- 11. Row Count and Key Uniqueness
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT portid) AS UniquePortIDs,
    COUNT(DISTINCT portname) AS UniquePortNames,
    COUNT(DISTINCT ObjectId) AS UniqueObjectIDs
FROM bronze.PortWatch_chokepoints_database;
GO

-- 12. Duplicate Port IDs
SELECT portid, COUNT(*) AS DuplicateCount
FROM bronze.PortWatch_chokepoints_database
GROUP BY portid
HAVING COUNT(*) > 1;
GO

-- 13. Duplicate Object IDs
SELECT ObjectId, COUNT(*) AS DuplicateCount
FROM bronze.PortWatch_chokepoints_database
GROUP BY ObjectId
HAVING COUNT(*) > 1;
GO

-- 14. Missing or Invalid Coordinates
SELECT portid, portname, lat, lon
FROM bronze.PortWatch_chokepoints_database
WHERE lat IS NULL
   OR lon IS NULL
   OR lat NOT BETWEEN -90 AND 90
   OR lon NOT BETWEEN -180 AND 180;
GO

-- 15. Non-Empty Text Values
SELECT
    COUNT(*) AS TotalRows,
    COUNT(NULLIF(LTRIM(RTRIM(country)), '')) AS NonEmptyCountry,
    COUNT(NULLIF(LTRIM(RTRIM(ISO3)), '')) AS NonEmptyISO3,
    COUNT(NULLIF(LTRIM(RTRIM(continent)), '')) AS NonEmptyContinent,
    COUNT(NULLIF(LTRIM(RTRIM(LOCODE)), '')) AS NonEmptyLOCODE,
    COUNT(NULLIF(LTRIM(RTRIM(countrynoaccents)), '')) AS NonEmptyCountryNoAccents,
    COUNT(NULLIF(LTRIM(RTRIM(industry_top1)), '')) AS NonEmptyIndustryTop1,
    COUNT(NULLIF(LTRIM(RTRIM(industry_top2)), '')) AS NonEmptyIndustryTop2,
    COUNT(NULLIF(LTRIM(RTRIM(industry_top3)), '')) AS NonEmptyIndustryTop3
FROM bronze.PortWatch_chokepoints_database;
GO


/* =====================================================
   TABLE 3: EVENTS
   ===================================================== */

-- 16. Row Count
SELECT COUNT(*) AS TotalRows
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)];
GO

-- 17. Duplicate Event IDs
SELECT eventid, COUNT(*) AS DuplicateCount
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
GROUP BY eventid
HAVING COUNT(*) > 1;
GO

-- 18. Duplicate Object IDs
SELECT ObjectId, COUNT(*) AS DuplicateCount
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
GROUP BY ObjectId
HAVING COUNT(*) > 1;
GO

-- 19. Event Date Validation
SELECT eventid, eventname, fromdate, todate
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
WHERE fromdate IS NULL
   OR (todate IS NOT NULL AND todate < fromdate);
GO

-- 20. Event Coordinates Validation
SELECT eventid, eventname, lat, long
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
WHERE lat IS NULL
   OR long IS NULL
   OR lat NOT BETWEEN -90 AND 90
   OR long NOT BETWEEN -180 AND 180;
GO

-- 21. Negative Numeric / Geometry Values
SELECT eventid, eventname, n_affectedports,
       Shape__Area, Shape__Length
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
WHERE n_affectedports < 0
   OR Shape__Area < 0
   OR Shape__Length < 0;
GO

-- 22. Non-Empty Text Values
SELECT
    COUNT(*) AS TotalRows,
    COUNT(NULLIF(LTRIM(RTRIM(eventtype)), '')) AS NonEmptyEventType,
    COUNT(NULLIF(LTRIM(RTRIM(eventname)), '')) AS NonEmptyEventName,
    COUNT(NULLIF(LTRIM(RTRIM(country)), '')) AS NonEmptyCountry,
    COUNT(NULLIF(LTRIM(RTRIM(severitytext)), '')) AS NonEmptySeverityText,
    COUNT(NULLIF(LTRIM(RTRIM(affectedports)), '')) AS NonEmptyAffectedPorts,
    COUNT(NULLIF(LTRIM(RTRIM(pageid)), '')) AS NonEmptyPageID,
    COUNT(affectedpopulation) AS NonNullAffectedPopulation
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)];
GO

-- 23. Event Type Distribution
SELECT eventtype, COUNT(*) AS EventCount
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
GROUP BY eventtype
ORDER BY EventCount DESC;
GO

-- 24. Sample of Affected Ports
SELECT TOP 20
    eventid, eventname, affectedports, n_affectedports
FROM bronze.[portwatch_disruptions_database_-3978591324501330360 (1)]
WHERE affectedports IS NOT NULL
ORDER BY eventid;
GO

/* =====================================================
   END OF BRONZE VALIDATION
   ===================================================== */