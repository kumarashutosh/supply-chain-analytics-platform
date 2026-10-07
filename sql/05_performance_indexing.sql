USE SupplyChainDW;
GO

-- 1. Index Foreign Keys on Fact_Order_Items for lightning-fast joins with Dimensions
PRINT 'Creating indexes on Fact_Order_Items...';

CREATE NONCLUSTERED INDEX IX_Fact_CustomerKey 
ON warehouse.Fact_Order_Items(CustomerKey);
GO

CREATE NONCLUSTERED INDEX IX_Fact_ProductKey 
ON warehouse.Fact_Order_Items(ProductKey);
GO

CREATE NONCLUSTERED INDEX IX_Fact_ShippingKey 
ON warehouse.Fact_Order_Items(ShippingKey);
GO

CREATE NONCLUSTERED INDEX IX_Fact_OrderDateKey 
ON warehouse.Fact_Order_Items(OrderDateKey);
GO

-- 2. Index Natural Keys on Dimensions for fast lookups during MERGE / ETL operations
PRINT 'Creating indexes on Dimension natural keys...';

CREATE NONCLUSTERED INDEX IX_DimCustomer_CustomerID 
ON warehouse.Dim_Customer(CustomerID);
GO

CREATE NONCLUSTERED INDEX IX_DimProduct_ProductID 
ON warehouse.Dim_Product(ProductID);
GO

PRINT 'Performance indexing completed successfully!';
GO