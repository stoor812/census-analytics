import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text
import pandas as pd
from snowflake.sqlalchemy import URL as SnowflakeURL

load_dotenv()


def get_postgres_engine():
    return create_engine(
        f"postgresql+psycopg2://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASSWORD']}"
        f"@{os.environ['POSTGRES_HOST']}:{os.environ['POSTGRES_PORT']}/{os.environ['POSTGRES_DB']}"
    )


def get_snowflake_engine():
    return create_engine(SnowflakeURL(
        user=os.environ['SNOWFLAKE_USER'],
        password=os.environ['SNOWFLAKE_PASSWORD'],
        account=os.environ['SNOWFLAKE_ACCOUNT'],
        warehouse=os.environ['SNOWFLAKE_WAREHOUSE'],
        database=os.environ['SNOWFLAKE_DATABASE'],
        schema=os.environ['SNOWFLAKE_SCHEMA'],
        role=os.environ['SNOWFLAKE_ROLE'],
    ))


def migrate():
    pg = get_postgres_engine()
    sf = get_snowflake_engine()

    tables = inspect(pg).get_table_names()
    print(f"Found {len(tables)} tables in PostgreSQL: {tables}")

    chunk_size = 10000

    for table in tables:
        print(f"Migrating {table}...")
        first_chunk = True
        rows_written = 0

        for chunk in pd.read_sql(f"SELECT * FROM {table}", pg, chunksize=chunk_size):
            if_exists = 'replace' if first_chunk else 'append'
            chunk.to_sql(table, sf, if_exists=if_exists, index=False)
            first_chunk = False
            rows_written += len(chunk)
            print(f"  -> wrote chunk of {len(chunk)} rows (total: {rows_written})")

        with pg.connect() as conn:
            pg_count = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
        with sf.connect() as conn:
            sf_count = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()

        print(f"  PostgreSQL: {pg_count} rows | Snowflake: {sf_count} rows")
        assert pg_count == sf_count, f"Row count mismatch on {table}!"

    print("Migration complete.")


if __name__ == "__main__":
    migrate()
