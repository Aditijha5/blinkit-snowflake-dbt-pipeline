"""run the full pipeline: bootstrap snowflake + load from s3, dbt build, row-count checks."""
import os
import subprocess
import sys
from pathlib import Path

import snowflake.connector
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent.parent
load_dotenv(ROOT / ".env")

REQUIRED = [
    "SNOWFLAKE_ACCOUNT", "SNOWFLAKE_USER", "SNOWFLAKE_PASSWORD",
    "AWS_KEY_ID", "AWS_SECRET_KEY", "S3_PATH",
]


def check_env() -> None:
    missing = [k for k in REQUIRED if not os.getenv(k)]
    if missing:
        sys.exit(f"missing environment variables: {', '.join(missing)}")


def connect():
    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        role=os.getenv("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
    )


def bootstrap(conn) -> None:
    sql = (ROOT / "sql" / "bootstrap_snowflake.sql").read_text()
    # secrets are injected in memory only, never written back to disk
    for key in ("S3_PATH", "AWS_KEY_ID", "AWS_SECRET_KEY"):
        sql = sql.replace("{{" + key + "}}", os.environ[key])
    print("bootstrapping snowflake and loading raw data...")
    conn.execute_string(sql)


def run_dbt() -> None:
    env = {**os.environ, "SNOWFLAKE_ROLE": os.getenv("SNOWFLAKE_ROLE", "ACCOUNTADMIN")}
    for cmd in (["dbt", "debug"], ["dbt", "build"]):
        print(f"running: {' '.join(cmd)}")
        subprocess.run(cmd + ["--profiles-dir", str(ROOT)], cwd=ROOT, env=env, check=True)


def row_counts(conn) -> None:
    tables = [
        "blinkit_db.raw.blinkit_orders_raw",
        "blinkit_db.staging.stg_blinkit_orders",
        "blinkit_db.marts.dim_outlets",
        "blinkit_db.marts.dim_items",
        "blinkit_db.marts.fct_blinkit_sales",
        "blinkit_db.marts.mart_outlet_sales",
        "blinkit_db.marts.mart_item_type_sales",
    ]
    cur = conn.cursor()
    print("\nrow counts")
    for t in tables:
        cur.execute(f"select count(*) from {t}")
        print(f"  {t:<45} {cur.fetchone()[0]:>8}")


if __name__ == "__main__":
    check_env()
    if not (ROOT / "profiles.yml").exists():
        (ROOT / "profiles.yml").write_text((ROOT / "profiles.yml.example").read_text())
    conn = connect()
    try:
        bootstrap(conn)
        run_dbt()
        row_counts(conn)
    finally:
        conn.close()
