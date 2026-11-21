# Supply Chain Data Platform & Analytics Warehouse

This project is a supply chain analytics platform built using Python, Microsoft SQL Server, and Power BI.

The goal was to take raw supply chain transaction data, load it into SQL Server, validate the records, organize the data into a star schema, and make it ready for business reporting.

The project uses the DataCo supply chain dataset, containing **180,519 order line-item records**. I built the ingestion process in Python, handled data validation and rejected records, created the warehouse tables using dimensional modeling, and used SQL stored procedures to load the warehouse.

## 1. Data Overview

The following counts represent the data after the ingestion and warehouse loading process.

| Table / Data Layer | Row Count | Description |
|---|---:|---|
| Raw CSV | 180,519 | Original order line-item records |
| staging.order_items | 180,519 | Records loaded into staging |
| quarantine.rejected_orders | 0 | Records rejected during validation |
| warehouse.Fact_Order_Items | 180,519 | Order line-item fact records |
| warehouse.Dim_Customer | 20,652 | Unique customers |
| warehouse.Dim_Product | 118 | Unique products |
| warehouse.Dim_Shipping | 273 | Unique shipping and market combinations |
| warehouse.Dim_Date | 1,127 | Calendar dates |

**Data grain:** One row represents one order line item, identified by `order_item_id`.

## 2. How the Project Works

I divided the project into the following steps:

### 1. Data Ingestion

I used Python and Pandas to read the raw CSV file and load the records into Microsoft SQL Server.

Database connection details are stored in a local `.env` file instead of being written directly into the Python script.

### 2. Data Validation and Quarantine

Before loading the records into the staging table, I added validation checks for important fields.

For example:
- Check whether `order_item_id` is missing.
- Check whether `order_id` is missing.
- Separate invalid records from valid records.

Valid records are loaded into `staging.order_items`, while rejected records are stored in `quarantine.rejected_orders` for further investigation.

In this dataset, all 180,519 records passed these validation checks.

### 3. Building the Data Warehouse

I designed the warehouse using Kimball-style dimensional modeling.

The warehouse contains one fact table and four dimension tables:

- `Fact_Order_Items` – Stores order line-item information and measures.
- `Dim_Customer` – Stores customer-related attributes.
- `Dim_Product` – Stores product information.
- `Dim_Shipping` – Stores shipping and market-related information.
- `Dim_Date` – Stores calendar date attributes.

The fact table connects to the dimension tables through their respective keys, making the data easier to query and analyze.

### 4. Loading the Warehouse

I used T-SQL stored procedures to populate the dimension and fact tables.

- `NOT EXISTS` checks help prevent existing dimension records from being inserted again.
- `MERGE` is used to insert or update fact records based on the matching key.

The loading logic is designed to support rerunning the warehouse load without creating duplicate records.

### 5. SQL Performance
Non-clustered and covering indexes (`INCLUDE` columns on `OrderDateKey`) eliminate Key Lookups on `Fact_Order_Items`, verified via `SET STATISTICS IO, TIME ON` to reduce logical reads by **98.5% (from 2,038 down to 30 pages)** on monthly revenue aggregations.

The purpose was to improve data access during joins and analytical queries.

### 6. Power BI Reporting

Once the warehouse was populated, I connected Power BI to SQL Server to build the reporting layer.

The analytical model uses DAX measures to calculate:

- Total Sales
- Total Profit
- Profit Margin
- Delivery Performance
- Late Delivery Rate

These measures help analyze sales performance and identify operational issues across the supply chain.

## 3. Technology Stack

| Area | Tools and Technologies |
|---|---|
| Database | Microsoft SQL Server 2022 |
| Containerization | Docker Desktop |
| Programming | Python |
| Data Processing | Pandas |
| Database Connectivity | SQLAlchemy, PyODBC |
| Environment Configuration | python-dotenv |
| SQL | T-SQL, Stored Procedures, Joins, MERGE |
| Data Modeling | Kimball Dimensional Modeling, Star Schema |
| Performance | Non-clustered Indexing |
| Reporting | Power BI, DAX |

## 4. Project Structure

```text
supply-chain-analytics-platform/
│
├── sql/
│   ├── 01_create_schemas.sql
│   ├── 02_create_dimensions.sql
│   ├── 03_create_fact_and_staging.sql
│   ├── 04_load_warehouse.sql
│   └── 05_performance_indexing.sql
│
├── src/
│   └── ingest.py
│
├── data/
│   └── raw/
│
├── .env.example
├── docker-compose.yml
└── README.md
```

**Folder descriptions:**

- `sql/` – SQL scripts for creating schemas, tables, stored procedures, and indexes.
- `src/` – Python ingestion and validation code.
- `data/raw/` – Raw source dataset.
- `.env.example` – Example environment variables required for the database connection.
- `docker-compose.yml` – Configuration for running the SQL Server container.

## 5. Running the Project Locally

### Step 1: Clone the repository

```bash
git clone https://github.com/kumarashutosh/supply-chain-analytics-platform.git

cd supply-chain-analytics-platform
```

### Step 2: Configure environment variables

Create a local `.env` file from the example file.

**Windows (PowerShell):**

```powershell
Copy-Item .env.example .env
```

**macOS / Linux:**

```bash
cp .env.example .env
```

Add your SQL Server connection details to the `.env` file.

### Step 3: Start SQL Server

Make sure Docker Desktop is running, then execute:

```bash
docker-compose up -d
```

### Step 4: Create the database

Open SQL Server Management Studio (SSMS).

Create the `SupplyChainDW` database and execute the SQL scripts in the following order:

1. `01_create_schemas.sql`
2. `02_create_dimensions.sql`
3. `03_create_fact_and_staging.sql`
4. `04_load_warehouse.sql`
5. `05_performance_indexing.sql`

### Step 5: Install Python dependencies

Open the project folder in VS Code and run:

```bash
python -m pip install pandas sqlalchemy pyodbc python-dotenv
```

### Step 6: Run the ingestion script

```bash
python src/ingest.py
```

This reads the source CSV, performs the validation checks, and loads valid and rejected records into their respective SQL Server tables.

### Step 7: Load the warehouse

After ingestion is complete, execute the stored procedure in SSMS:

```sql
EXEC warehouse.sp_Load_SupplyChain_Warehouse;
```

This loads the dimension and fact tables.

### Step 8: Connect Power BI

Connect Power BI Desktop to the `SupplyChainDW` database in SQL Server.

Use the warehouse tables to create relationships, DAX measures, and supply chain dashboards.

---

## 6. What I Practised in This Project

Through this project, I worked on:

- Loading CSV data into SQL Server using Python.
- Managing database credentials through environment variables.
- Validating incoming records before loading them.
- Separating rejected records for data-quality checks.
- Designing fact and dimension tables using a star schema.
- Writing SQL stored procedures for warehouse loading.
- Using `NOT EXISTS` and `MERGE` for repeatable loading.
- Creating indexes for commonly used joins.
- Connecting a SQL Server warehouse to Power BI.

**Repository:** https://github.com/kumarashutosh/supply-chain-analytics-platform
