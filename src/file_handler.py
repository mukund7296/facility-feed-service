
import json
import gzip
import time

def write_feed_file(feed_data, filename):
    """Write feed data to a JSON file and compress it using gzip."""
    json_data = json.dumps({"data": feed_data}, indent=4)
    with gzip.open(filename, "wt", encoding="utf-8") as f:
        f.write(json_data)

def generate_metadata(feed_files):
    """Create metadata.json containing feed file details."""
    metadata = {
        "generation_timestamp": int(time.time()),
        "name": "reservewithgoogle.entity",
        "data_file": feed_files
    }
    with open("metadata.json", "w") as f:
        json.dump(metadata, f, indent=4)
