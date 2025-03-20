
import asyncpg
import logging

async def fetch_facility_data(pool, batch_size=100):
    """Fetch facility data from the database in batches of 100 records."""
    try:
        async with pool.acquire() as conn:
            async for record in conn.cursor(
                """SELECT id, name, phone, url, latitude, longitude, 
                          country, locality, region, postal_code, street_address 
                   FROM facility""",
                prefetch=batch_size
            ):
                yield record
    except Exception as e:
        logging.error(f"Database error: {e}")
