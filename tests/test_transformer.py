
import pytest
from src.transformer import transform_record

def test_transform_record():
    record = {
        "id": 1,
        "name": "Test Facility",
        "phone": "+123456789",
        "url": "http://test.com",
        "latitude": 40.7128,
        "longitude": -74.0060,
        "country": "US",
        "locality": "New York",
        "region": "NY",
        "postal_code": "10001",
        "street_address": "123 Test St"
    }
    transformed = transform_record(record)
    assert transformed["name"] == "Test Facility"
    assert transformed["location"]["latitude"] == 40.7128
