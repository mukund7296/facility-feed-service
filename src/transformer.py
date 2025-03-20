
def transform_record(record):
    """Convert facility data to JSON format."""
    return {
        "entity_id": f"dining-{record['id']}",
        "name": record["name"],
        "telephone": record["phone"],
        "url": record["url"],
        "location": {
            "latitude": record["latitude"],
            "longitude": record["longitude"],
            "address": {
                "country": record["country"],
                "locality": record["locality"],
                "region": record["region"],
                "postal_code": record["postal_code"],
                "street_address": record["street_address"]
            }
        }
    }
