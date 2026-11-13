# Supply Chain Data Platform & Analytics Warehouse

An end-to-end, production-style supply chain data engineering and business intelligence platform designed to ingest, validate, model, and analyze **180,519** global supply chain transactions.

---

## Verified Data Reconciliation (Truth Sheet)

| Pipeline Layer / Table | Exact Row Count | Grain / Primary Entity |
| :--- | :---: | :--- |
| **Raw CSV (`DataCoSupplyChainDatasetRefined.csv`)** | **180,519** | 1 row per order line item (`order_item_id`) |
| **`staging.order_items`** | **180,519** | Validated raw landing rows |
| **`quarantine.rejected_orders`** | **0** | Rows failing null/key validation |
| **`warehouse.Fact_Order_Items`** | **180,519** | Central fact table (`OrderItemID` grain) |
| **`warehouse.Dim_Customer`** | **20,652** | Unique customers (`CustomerID`) |
| **`warehouse.Dim_Product`** | **118** | Unique products (`ProductID`) |
| **`warehouse.Dim_Shipping`** | **273** | Unique shipping & market combinations |
| **`warehouse.Dim_Date`** | **1,127** | Calendar dates (`YYYYMMDD` `DateKey`) |

---

## System Architecture & Workflow

1. **Raw Ingestion:** Raw transactional CSV data is loaded through a Python ingestion pipeline using Pandas, reading database credentials securely from a local `.env` file.

2. **Defensive Validation & Quarantine:** Critical data-quality checks identify invalid records (`order_item_id` or `order_id` null checks). Clean rows are loaded into `staging`, while rejected records are preserved in a dedicated `quarantine` schema for investigation and auditing.

3. **Kimball Star Schema Warehouse:** Staging data is transformed into a dimensional warehouse containing a central `Fact_Order_Items` fact table and four dimensions: `Dim_Customer`, `Dim_Product`, `Dim_Shipping`, and `Dim_Date`, implemented in Microsoft SQL Server 2022.

4. **Idempotent Warehouse Loading:** T-SQL stored procedures use `NOT EXISTS` logic for dimension loading and `MERGE` logic for fact loading, allowing the warehouse load to be safely rerun.

5. **Performance Engineering:** Non-clustered indexes are applied to frequently joined foreign keys and dimension natural keys to improve query access paths.

6. **Business Intelligence:** Power BI provides the analytical and semantic layer, with DAX measures for sales, profit, margins, and operational delivery risk.

---

## Tech Stack

- **Database & Infrastructure:** Microsoft SQL Server 2022, Docker Desktop
- **ETL & Data Processing:** Python, Pandas, SQLAlchemy, PyODBC, python-dotenv
- **Data Modeling & SQL:** T-SQL, Kimball Dimensional Modeling, Stored Procedures, Indexing
- **Business Intelligence:** Power BI, DAX

---

## Repository Structure

```text
/sql
    ├── 01_create_schemas.sql
    ├── 02_create_dimensions.sql
    ├── 03_create_fact_and_staging.sql
    ├── 04_load_warehouse.sql
    └── 05_performance_indexing.sql

/src
    └── ingest.py

/data
    └── raw

.env.example
docker-compose.yml
```

- `/sql` — Database lifecycle scripts for schemas, staging, dimensions, fact tables, stored procedures, and indexes.
- `/src` — Python ingestion and defensive validation pipeline.

---

## How to Run Locally

### 1. Clone the repository

```bash
git clone [https://github.com/kumarashutosh/supply-chain-analytics-platform.git](https://github.com/kumarashutosh/supply-chain-analytics-platform.git)
cd supply-chain-analytics-platform
```

### 2. Configure database credentials

Copy `.env.example` to `.env` and add your SQL Server password inside `.env`:

```bash
# Windows (Command Prompt / PowerShell)
copy .env.example .env

# macOS / Linux
cp .env.example .env
```

### 3. Start SQL Server

Run the SQL Server 2022 container using Docker Desktop:

```bash
docker-compose up -d
```

### 4. Create the database and schemas

Create the `SupplyChainDW` database and execute scripts `01` through `05` inside `/sql` using SQL Server Management Studio (SSMS).

### 5. Configure Python dependencies

Install the required Python packages:

```bash
pip install pandas sqlalchemy pyodbc python-dotenv
```

### 6. Run the ingestion pipeline

```bash
python src/ingest.py
```

The pipeline loads valid records into `staging.order_items` and rejected records into the `quarantine.rejected_orders` table.

### 7. Load the warehouse

Execute:

```sql
EXEC warehouse.sp_Load_SupplyChain_Warehouse;
```

This populates the dimensional model and `warehouse.Fact_Order_Items`.

### 8. Connect Power BI

Connect Power BI to the SQL Server warehouse (`SupplyChainDW`) and build the analytical model and dashboards.
