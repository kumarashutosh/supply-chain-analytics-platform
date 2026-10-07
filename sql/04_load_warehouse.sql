USE SupplyChainDW;
GO

CREATE OR ALTER PROCEDURE warehouse.sp_Load_SupplyChain_Warehouse
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Populate Dim_Customer (Unique customers)
    PRINT 'Populating Dim_Customer...';
    INSERT INTO warehouse.Dim_Customer (CustomerID, CustomerSegment, CustomerCity, CustomerState, CustomerCountry)
    SELECT DISTINCT 
        customer_id, 
        customer_segment, 
        customer_city, 
        customer_state, 
        customer_country
    FROM staging.order_items
    WHERE customer_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM warehouse.Dim_Customer dc 
          WHERE dc.CustomerID = staging.order_items.customer_id
      );

    -- 2. Populate Dim_Product (Unique products based on product_card_id)
    PRINT 'Populating Dim_Product...';
    INSERT INTO warehouse.Dim_Product (ProductID, ProductName, CategoryName, DepartmentName)
    SELECT DISTINCT 
        product_card_id, 
        product_name, 
        category_name, 
        department_name
    FROM staging.order_items
    WHERE product_card_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM warehouse.Dim_Product dp 
          WHERE dp.ProductID = staging.order_items.product_card_id
      );

    -- 3. Populate Dim_Shipping (Unique shipping and market attributes)
    PRINT 'Populating Dim_Shipping...';
    INSERT INTO warehouse.Dim_Shipping (ShippingMode, DeliveryStatus, Market, OrderRegion)
    SELECT DISTINCT 
        shipping_mode, 
        delivery_status, 
        market, 
        order_region
    FROM staging.order_items
    WHERE shipping_mode IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM warehouse.Dim_Shipping ds 
          WHERE ds.ShippingMode = staging.order_items.shipping_mode
            AND ds.DeliveryStatus = staging.order_items.delivery_status
            AND ds.Market = staging.order_items.market
            AND ds.OrderRegion = staging.order_items.order_region
      );

    -- 4. Populate Dim_Date (Using robust TRY_CAST for variable date string lengths)
    PRINT 'Populating Dim_Date...';
    INSERT INTO warehouse.Dim_Date (DateKey, FullDate, Year, Quarter, Month, MonthName, DayOfWeek)
    SELECT DISTINCT 
        CAST(FORMAT(TRY_CAST(order_date_dateorders AS DATETIME), 'yyyyMMdd') AS INT) AS DateKey,
        CAST(TRY_CAST(order_date_dateorders AS DATETIME) AS DATE) AS FullDate,
        YEAR(TRY_CAST(order_date_dateorders AS DATETIME)) AS Year,
        DATEPART(QUARTER, TRY_CAST(order_date_dateorders AS DATETIME)) AS Quarter,
        MONTH(TRY_CAST(order_date_dateorders AS DATETIME)) AS Month,
        DATENAME(MONTH, TRY_CAST(order_date_dateorders AS DATETIME)) AS MonthName,
        DATENAME(WEEKDAY, TRY_CAST(order_date_dateorders AS DATETIME)) AS DayOfWeek
    FROM staging.order_items
    WHERE order_date_dateorders IS NOT NULL
      AND TRY_CAST(order_date_dateorders AS DATETIME) IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM warehouse.Dim_Date dd 
          WHERE dd.DateKey = CAST(FORMAT(TRY_CAST(order_date_dateorders AS DATETIME), 'yyyyMMdd') AS INT)
      );

    -- 5. Populate Fact_Order_Items with Idempotent MERGE logic
    PRINT 'Populating Fact_Order_Items...';
    MERGE warehouse.Fact_Order_Items AS target
    USING (
        SELECT 
            s.order_id,
            s.order_item_id,
            dc.CustomerKey,
            dp.ProductKey,
            ds.ShippingKey,
            CAST(FORMAT(TRY_CAST(s.order_date_dateorders AS DATETIME), 'yyyyMMdd') AS INT) AS DateKey,
            s.order_item_quantity,
            s.sales,
            s.order_item_discount,
            s.order_item_total,
            s.order_profit_per_order,
            s.days_for_shipping_real,
            s.days_for_shipment_scheduled,
            s.late_delivery_risk
        FROM staging.order_items s
        JOIN warehouse.Dim_Customer dc ON s.customer_id = dc.CustomerID
        JOIN warehouse.Dim_Product dp ON s.product_card_id = dp.ProductID
        -- Fixed: Matching staging columns to Dim_Shipping PascalCase columns
        JOIN warehouse.Dim_Shipping ds ON s.shipping_mode = ds.ShippingMode 
                                      AND s.delivery_status = ds.DeliveryStatus 
                                      AND s.market = ds.Market 
                                      AND s.order_region = ds.OrderRegion
        WHERE s.order_item_id IS NOT NULL
          AND TRY_CAST(s.order_date_dateorders AS DATETIME) IS NOT NULL
    ) AS source 
    ON target.OrderItemID = source.order_item_id
    WHEN MATCHED THEN
        UPDATE SET 
            target.OrderQuantity = source.order_item_quantity,
            target.GrossSales = source.sales,
            target.DiscountAmount = source.order_item_discount,
            target.NetSales = source.order_item_total,
            target.Profit = source.order_profit_per_order,
            target.DaysReal = source.days_for_shipping_real,
            target.DaysScheduled = source.days_for_shipment_scheduled,
            target.LateDeliveryRisk = source.late_delivery_risk
    WHEN NOT MATCHED THEN
        INSERT (OrderID, OrderItemID, CustomerKey, ProductKey, ShippingKey, OrderDateKey, OrderQuantity, GrossSales, DiscountAmount, NetSales, Profit, DaysReal, DaysScheduled, LateDeliveryRisk)
        VALUES (source.order_id, source.order_item_id, source.CustomerKey, source.ProductKey, source.ShippingKey, source.DateKey, source.order_item_quantity, source.sales, source.order_item_discount, source.order_item_total, source.order_profit_per_order, source.days_for_shipping_real, source.days_for_shipment_scheduled, source.late_delivery_risk);

    PRINT 'Warehouse load completed successfully!';
END;
GO