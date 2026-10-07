# Supply Chain Data Platform & Analytics Warehouse

An end-to-end, production-style supply chain data engineering and business intelligence platform designed to ingest, validate, model, and analyze **180,519+** global supply chain transactions.

---

## System Architecture & Workflow

1. **Raw Ingestion:** Raw transactional CSV data is loaded through a Python ingestion pipeline using Pandas.

2. **Defensive Validation & Quarantine:** Critical data-quality checks identify invalid records. Clean rows are loaded into `staging`, while rejected records are preserved in a dedicated `quarantine` schema for investigation and auditing.

3. **Kimball Star Schema Warehouse:** Staging data is transformed into a dimensional warehouse containing a central `Fact_Order_Items` fact table and four dimensions: `Dim_Customer`, `Dim_Product`, `Dim_Shipping`, and `Dim_Date`, implemented in Microsoft SQL Server 2022.

4. **Idempotent Warehouse Loading:** T-SQL stored procedures use `NOT EXISTS` logic for dimension loading and `MERGE` logic for fact loading, allowing the warehouse load to be safely rerun.

5. **Performance Engineering:** Non-clustered indexes are applied to frequently joined and looked-up keys to improve query access paths.

6. **Business Intelligence:** Power BI provides the analytical and semantic layer, with DAX measures for sales, profit, margins, and operational delivery risk.

---

## Tech Stack

* **Database & Infrastructure:** Microsoft SQL Server 2022, Docker Desktop
* **ETL & Data Processing:** Python, Pandas, SQLAlchemy, PyODBC
* **Data Modeling & SQL:** T-SQL, Kimball Dimensional Modeling, Stored Procedures, Indexing
* **Business Intelligence:** Power BI, DAX

---

## Repository Structure

```text
/sql
    ├── database and schema setup
    ├── staging and warehouse tables
    ├── stored procedures
    └── indexing

/src
    └── ingest.py

/data
    └── raw
```

* `/sql` — Database lifecycle scripts for schemas, staging, dimensions, fact tables, stored procedures, and indexes.
* `/src` — Python ingestion and defensive validation pipeline.

---

## How to Run Locally

### 1. Clone the repository

```bash
git clone https://github.com/kumarashutosh/supply-chain-analytics-platform.git
```

### 2. Start SQL Server

Run the SQL Server 2022 container using Docker Desktop.

### 3. Create the database and schemas

Execute the database setup scripts in SQL Server Management Studio (SSMS).

### 4. Configure Python dependencies

Install the required Python packages:

```bash
pip install pandas sqlalchemy pyodbc
```

### 5. Configure database credentials

Set the SQL Server connection details used by the ingestion pipeline.

### 6. Run the ingestion pipeline

```bash
python src/ingest.py
```

The pipeline loads valid records into `staging.order_items` and rejected records into the `quarantine` schema.

### 7. Load the warehouse

Execute:

```sql
EXEC warehouse.sp_Load_SupplyChain_Warehouse;
```

This populates the dimensional model and fact table.

### 8. Connect Power BI

Connect Power BI to the SQL Server warehouse and build the analytical model and dashboards.
