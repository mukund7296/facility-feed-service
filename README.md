## **Resmio_task**  
The **Facility Feed Service** fetches facility data from a PostgreSQL database, transforms it into structured JSON feed files, and uploads them to **AWS S3**. Additionally, a **metadata.json** file is generated to list all uploaded feed files.  

This service is designed to be **asynchronous, memory-efficient, and containerized** for deployment on **AWS ECS Fargate** as a scheduled task.  

---

## **Features**  
1. **Asynchronous Processing**: using `asyncpg` for database queries and `aioboto3` for S3 uploads.  
2. **Memory-Efficient**: Processes data in **100-record chunks** to avoid memory overuse.  
3. **Gzip Compression**: Reduces file size before uploading to S3.  
4. **CI/CD Pipeline**: Automates testing and deployment using **GitHub Actions**.  
5. **Dockerized**: Runs seamlessly in a **Docker container**.  
6. **Scheduled Execution**: Configurable for **AWS ECS Fargate**.  

---

## **📂 Folder Structure**  
```
facility-feed-service/
│── src/
│   ├── database.py          # Fetch data from PostgreSQL
│   ├── transformer.py       # Transform data to JSON format
│   ├── file_handler.py      # Write JSON and metadata files
│   ├── uploader.py          # Upload files to AWS S3
│   ├── main.py              # Main script to orchestrate everything
│── tests/
│   ├── test_transformer.py  # Unit tests for data transformation
│── Dockerfile               # Docker container setup
│── requirements.txt         # Python dependencies
│── .github/
│   ├── workflows/
│       ├── ci-cd.yml        # GitHub Actions pipeline
│── README.md                # Documentation
```

---

## **⚙️ Setup Instructions**  

### **1️⃣ Prerequisites**  
Before running the service, ensure you have:  
- **Python 3.11+** installed  
- **PostgreSQL** database with facility data  
- **AWS CLI** configured  
- **Docker** installed  

---

### **2️⃣ Install Dependencies**  
```sh
pip install -r requirements.txt
```

---
<img width="1040" alt="image" src="https://github.com/user-attachments/assets/50f1f565-3eae-4c5d-9aa1-8b4b68d47102" />


### **3️⃣ Configure Environment Variables**  
Create a `.env` file with your database and AWS credentials:  
```
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=your_database
DB_HOST=your_host
AWS_BUCKET_NAME=your_bucket
AWS_REGION=your_region
```

---

### **4️⃣ Run Locally**  
```sh
python src/main.py
```

---

## **📝 Data Format**  

### **Input: PostgreSQL Table (`facility`)**  
| Column        | Type      |
|--------------|----------|
| id           | INT      |
| name         | TEXT     |
| phone        | TEXT     |
| url          | TEXT     |
| latitude     | FLOAT    |
| longitude    | FLOAT    |
| country      | TEXT     |
| locality     | TEXT     |
| region       | TEXT     |
| postal_code  | TEXT     |
| street_address | TEXT  |

---

### **Output: JSON Feed File (`facility_feed_xxxx.json.gz`)**  
```json
{
    "data": [
        {
            "entity_id": "dining-1",
            "name": "Sample Eatery 1",
            "telephone": "+1-415-876-5432",
            "url": "www.sampleeatery1.com",
            "location": {
                "latitude": 37.404570,
                "longitude": -122.033160,
                "address": {
                    "country": "US",
                    "locality": "Sunnyvale",
                    "region": "CA",
                    "postal_code": "94089",
                    "street_address": "815 11th Ave"
                }
            }
        }
    ]
}
```

---

### **Metadata File (`metadata.json`)**
```json
{
    "generation_timestamp": 1697754089,
    "name": "reservewithgoogle.entity",
    "data_file": ["facility_feed_1697754089.json.gz", "facility_feed_1697754090.json.gz"]
}
```

---

## **🐳 Running with Docker**  

### **1️⃣ Build the Docker Image**  
```sh
docker build -t facility-feed-service .
```

### **2️⃣ Run the Docker Container**  
```sh
docker run --env-file .env facility-feed-service
```

---

## **🚀 CI/CD Pipeline**  
📄 **File:** `.github/workflows/ci-cd.yml`  

The pipeline includes:  
✅ **Linting and Testing** (flake8, pytest)  
✅ **Building Docker Image**  
✅ **Pushing to AWS ECR**  

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  test-lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run Linter
        run: flake8 .

      - name: Run Tests
        run: pytest

  build-push:
    needs: test-lint
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Login to AWS ECR
        run: |
          aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${{ secrets.AWS_ECR_URI }}

      - name: Build Docker Image
        run: docker build -t facility-feed-service .

      - name: Push to ECR
        run: |
          docker tag facility-feed-service:latest ${{ secrets.AWS_ECR_URI }}/facility-feed-service:latest
          docker push ${{ secrets.AWS_ECR_URI }}/facility-feed-service:latest
```

---

## **⏰ Running as a Scheduled Task in AWS ECS Fargate**  
1️⃣ **Create an ECS Task Definition**  
2️⃣ **Set up a CloudWatch Event Rule** to trigger the task  
3️⃣ **Use AWS Fargate** to run the containerized service  

---

## **🔍 Testing the Service**  
📄 **File: `tests/test_transformer.py`**  
```python
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
```

Run tests using:  
```sh
pytest tests/
```

---

## **📌 Summary**
✅ **Asynchronous** processing for efficiency  
✅ **JSON & gzip compression** for optimized storage  
✅ **AWS S3 uploads** handled asynchronously  
✅ **Dockerized** for easy deployment  
✅ **CI/CD pipeline** for automated testing & deployment  
✅ **Scheduled execution** on **AWS ECS Fargate**  

---

## **📩 Contact & Contribution**
If you find any issues or want to contribute, feel free to submit a **pull request** or open an **issue** on GitHub.  

💡 **Need help?** Reach out at [mukund2015@outlook.com](mailto:mukund2015@outlook.com).  

---
