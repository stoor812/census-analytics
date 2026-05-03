from dotenv import load_dotenv
from sqlalchemy import create_engine, text
import os

load_dotenv()

engine = create_engine(
    f"postgresql+psycopg2://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASSWORD']}"
    f"@{os.environ['POSTGRES_HOST']}:{os.environ['POSTGRES_PORT']}/{os.environ['POSTGRES_DB']}"
)

with engine.connect() as conn:
    result = conn.execute(text("""
        SELECT DISTINCT characteristic_id, characteristic_name
        FROM census_profiles
        WHERE geo_level = 'Federal electoral district (2013 Representation Order)'
        ORDER BY characteristic_id
    """))
    with open('characteristics.txt', 'w') as f:
        for row in result:
            f.write(f"{row[0]}: {row[1]}\n")

print("Done - check characteristics.txt")