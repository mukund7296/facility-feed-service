
import aioboto3
import logging

async def upload_to_s3(bucket_name, file_name, s3_key):
    """Upload a file to AWS S3 using aioboto3."""
    try:
        session = aioboto3.Session()
        async with session.client("s3") as s3:
            with open(file_name, "rb") as f:
                await s3.upload_fileobj(f, bucket_name, s3_key, ExtraArgs={
                    "ContentType": "application/json",
                    "ContentEncoding": "gzip"
                })
        logging.info(f"Uploaded {file_name} to s3://{bucket_name}/{s3_key}")
    except Exception as e:
        logging.error(f"Failed to upload {file_name} to S3: {e}")
