import os
import urllib.parse
import pandas as pd
from sqlalchemy import create_engine

# 1. Database Connection Settings
DB_SERVER = "localhost,1433"
DB_NAME = "SupplyChainDW"
DB_USER = "sa"
DB_PASSWORD = "YourStrong@Password123"

encoded_password = urllib.parse.quote_plus(DB_PASSWORD)

CONNECTION_STRING = (
    f"mssql+pyodbc://{DB_USER}:{encoded_password}@{DB_SERVER}/{DB_NAME}"
    "?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes")

def run_ingestion():
    print("--- Starting Ingestion Pipeline ---")

    # 2. Load Single Dataset File from data/raw/
    filename = "DataCoSupplyChainDatasetRefined.csv"
    raw_path = os.path.join("data", "raw", filename)

    if not os.path.exists(raw_path):
        print(f"Error: {filename} not found in data/raw/ folder!")
        print("Please ensure your file is placed inside data/raw/.")
        return

    print(f"Reading {filename}...")
    df = pd.read_csv(raw_path, encoding="utf-8")
    print(f"Total raw records loaded: {len(df):,}")

    # 3. Defensive Validation Check
    # Check for missing critical identifiers (order_item_id or order_id)
    is_invalid = df['order_item_id'].isnull() | df['order_id'].isnull()

    df_clean = df[~is_invalid].copy()
    df_rejected = df[is_invalid].copy()

    print(f"Clean records passed validation: {len(df_clean):,}")
    print(f"Rejected records caught: {len(df_rejected):,}")

    # 4. Connect to SQL Server
    print("Connecting to SQL Server...")
    engine = create_engine(CONNECTION_STRING)

    # 5. Load Rejected Rows into Quarantine Schema (if any exist)
    if len(df_rejected) > 0:
        df_quarantine = pd.DataFrame({
            'order_item_id': df_rejected['order_item_id'].astype(str),
            'rejection_reason': 'Missing critical order_item_id or order_id',
            'raw_payload': df_rejected.astype(str).values.tolist()
        })
        df_quarantine.to_sql('rejected_orders', con=engine, schema='quarantine', if_exists='append', index=False)
        print("-> Rejected rows safely quarantined.")

    # 6. Load Clean Rows into Staging Schema
    print("Loading clean rows into staging.order_items (this may take a moment)...")
    df_clean.to_sql('order_items', con=engine, schema='staging', if_exists='append', index=False, chunksize=10000)
    print("--- Ingestion Pipeline Completed Successfully! ---")

if __name__ == "__main__":
    run_ingestion()