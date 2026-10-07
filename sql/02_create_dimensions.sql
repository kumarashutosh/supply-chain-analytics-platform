USE SupplyChainDW;
GO

-- 1. Customer Dimension
IF OBJECT_ID('warehouse.Dim_Customer', 'U') IS NOT NULL DROP TABLE warehouse.Dim_Customer;
CREATE TABLE warehouse.Dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerSegment VARCHAR(50),
    CustomerCity VARCHAR(100),
    CustomerState VARCHAR(100),
    CustomerCountry VARCHAR(100)
);
GO

-- 2. Product Dimension
IF OBJECT_ID('warehouse.Dim_Product', 'U') IS NOT NULL DROP TABLE warehouse.Dim_Product;
CREATE TABLE warehouse.Dim_Product (
    ProductKey INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL, -- Corresponds to product_card_id
    ProductName VARCHAR(255),
    CategoryName VARCHAR(100),
    DepartmentName VARCHAR(100)
);
GO

-- 3. Shipping Dimension
IF OBJECT_ID('warehouse.Dim_Shipping', 'U') IS NOT NULL DROP TABLE warehouse.Dim_Shipping;
CREATE TABLE warehouse.Dim_Shipping (
    ShippingKey INT IDENTITY(1,1) PRIMARY KEY,
    ShippingMode VARCHAR(50),
    DeliveryStatus VARCHAR(50),
    Market VARCHAR(50),
    OrderRegion VARCHAR(100)
);
GO

-- 4. Date Dimension
IF OBJECT_ID('warehouse.Dim_Date', 'U') IS NOT NULL DROP TABLE warehouse.Dim_Date;
CREATE TABLE warehouse.Dim_Date (
    DateKey INT PRIMARY KEY, -- Format: YYYYMMDD (e.g., 20180131)
    FullDate DATE NOT NULL,
    Year INT,
    Quarter INT,
    Month INT,
    MonthName VARCHAR(20),
    DayOfWeek VARCHAR(20)
);
GO