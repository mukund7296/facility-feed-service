
import asyncio
import asyncpg
import time
from database import fetch_facility_data
from transformer import transform_record
from file_handler import write_feed_file, generate_metadata
from uploader import upload_to_s3

DB_CONFIG = {
    "user": "your_user",
    "password": "your_password",
    "database": "your_database",
    "host": "your_host",
}

BUCKET_NAME = "your_bucket_name"

async def main():
    """Main function to fetch, process, and upload facility data."""
    pool = await asyncpg.create_pool(**DB_CONFIG)
    
    feed_files = []
    async for batch in fetch_facility_data(pool):
        transformed_data = [transform_record(record) for record in batch]
        filename = f"facility_feed_{int(time.time())}.json.gz"
        write_feed_file(transformed_data, filename)
        feed_files.append(filename)
        await upload_to_s3(BUCKET_NAME, filename, filename)

    generate_metadata(feed_files)
    await upload_to_s3(BUCKET_NAME, "metadata.json", "metadata.json")

    await pool.close()

if __name__ == "__main__":
    asyncio.run(main())
