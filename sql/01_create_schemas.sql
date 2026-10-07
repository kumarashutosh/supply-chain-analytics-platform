USE SupplyChainDW;
GO

-- 1. Staging Schema: For raw, unmodified batch ingestion
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging')
BEGIN
    EXEC('CREATE SCHEMA staging');
END
GO

-- 2. Quarantine Schema: For invalid or malformed records
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'quarantine')
BEGIN
    EXEC('CREATE SCHEMA quarantine');
END
GO

-- 3. Warehouse Schema: For production Star Schema (Facts & Dimensions)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'warehouse')
BEGIN
    EXEC('CREATE SCHEMA warehouse');
END
GO