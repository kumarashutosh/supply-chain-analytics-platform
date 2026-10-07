USE SupplyChainDW;
GO

-- 1. Staging Table: Landing pad for raw CSV data before cleaning
IF OBJECT_ID('staging.order_items', 'U') IS NOT NULL DROP TABLE staging.order_items;
CREATE TABLE staging.order_items (
    type VARCHAR(50),
    days_for_shipping_real INT,
    days_for_shipment_scheduled INT,
    benefit_per_order FLOAT,
    sales_per_customer FLOAT,
    delivery_status VARCHAR(50),
    late_delivery_risk INT,
    category_id INT,
    category_name VARCHAR(100),
    customer_city VARCHAR(100),
    customer_country VARCHAR(100),
    customer_email VARCHAR(255),
    customer_fname VARCHAR(100),
    customer_id INT,
    customer_lname VARCHAR(100),
    customer_password VARCHAR(255),
    customer_segment VARCHAR(50),
    customer_state VARCHAR(100),
    customer_street VARCHAR(255),
    customer_zipcode FLOAT,
    department_id INT,
    department_name VARCHAR(100),
    latitude_src FLOAT,
    longitude_src FLOAT,
    market VARCHAR(50),
    order_city VARCHAR(100),
    order_country VARCHAR(100),
    order_customer_id INT,
    order_date_dateorders VARCHAR(50),
    order_id INT,
    order_item_cardprod_id INT,
    order_item_discount FLOAT,
    order_item_discount_rate FLOAT,
    order_item_id INT,
    order_item_product_price FLOAT,
    order_item_profit_ratio FLOAT,
    order_item_quantity INT,
    sales FLOAT,
    order_item_total FLOAT,
    order_profit_per_order FLOAT,
    order_region VARCHAR(100),
    order_state VARCHAR(100),
    order_status VARCHAR(50),
    order_zipcode FLOAT,
    product_card_id INT,
    product_category_id INT,
    product_image VARCHAR(MAX),
    product_name VARCHAR(255),
    product_price FLOAT,
    product_status INT,
    shipping_date_dateorders VARCHAR(50),
    shipping_mode VARCHAR(50),
    order_country_en VARCHAR(100),
    order_state_en VARCHAR(100),
    order_city_en VARCHAR(100),
    latitude_dest FLOAT,
    longitude_dest FLOAT,
    address_dest VARCHAR(255)
);
GO

-- 2. Quarantine Table: Holds corrupted/malformed rows rejected by Python validation
IF OBJECT_ID('quarantine.rejected_orders', 'U') IS NOT NULL DROP TABLE quarantine.rejected_orders;
CREATE TABLE quarantine.rejected_orders (
    rejection_id INT IDENTITY(1,1) PRIMARY KEY,
    order_item_id VARCHAR(50),
    rejection_reason VARCHAR(255),
    raw_payload VARCHAR(MAX),
    rejected_at DATETIME DEFAULT GETDATE()
);
GO

-- 3. Fact Table: The central performance and revenue table
IF OBJECT_ID('warehouse.Fact_Order_Items', 'U') IS NOT NULL DROP TABLE warehouse.Fact_Order_Items;
CREATE TABLE warehouse.Fact_Order_Items (
    OrderItemKey INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    OrderItemID INT NOT NULL,
    CustomerKey INT FOREIGN KEY REFERENCES warehouse.Dim_Customer(CustomerKey),
    ProductKey INT FOREIGN KEY REFERENCES warehouse.Dim_Product(ProductKey),
    ShippingKey INT FOREIGN KEY REFERENCES warehouse.Dim_Shipping(ShippingKey),
    OrderDateKey INT FOREIGN KEY REFERENCES warehouse.Dim_Date(DateKey),
    
    -- Numerical Measures
    OrderQuantity INT,
    GrossSales FLOAT,
    DiscountAmount FLOAT,
    NetSales FLOAT,
    Profit FLOAT,
    DaysReal INT,
    DaysScheduled INT,
    LateDeliveryRisk INT
);
GO