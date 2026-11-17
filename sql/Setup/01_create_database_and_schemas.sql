/* =========================================
   Project: Global Shipping Disruption Analytics
   Purpose: Create Database and Schemas
   Author: Member 1 - Data Architect
   ========================================= */

USE master;
GO

-- Create Database if it does not exist
IF DB_ID(N'global_shipping_dw') IS NULL
BEGIN
    CREATE DATABASE global_shipping_dw;
END;
GO

USE global_shipping_dw;
GO

-- Create Bronze Schema
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'bronze'
)
BEGIN
    EXEC(N'CREATE SCHEMA bronze');
END;
GO

-- Create Silver Schema
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'silver'
)
BEGIN
    EXEC(N'CREATE SCHEMA silver');
END;
GO

-- Create Gold Schema
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = N'gold'
)
BEGIN
    EXEC(N'CREATE SCHEMA gold');
END;
GO