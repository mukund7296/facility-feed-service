#!/bin/bash

# Set variables
AWS_REGION="your-region"
AWS_ACCOUNT_ID="your-account-id"
ECR_REPO_NAME="facility-feed-service"
ECS_CLUSTER_NAME="facility-cluster"
ECS_TASK_NAME="facility-task"
SCHEDULE_EXPRESSION="cron(0 0 * * ? *)"  # Run daily at midnight

# Function to check command success
check_success() {
    if [ $? -ne 0 ]; then
        echo "❌ Error occurred. Exiting..."
        exit 1
    fi
}

echo "🚀 Cloning the repository..."
git clone https://github.com/your-username/facility-feed-service.git
cd facility-feed-service || exit
check_success

echo "🔧 Creating a virtual environment..."
python3 -m venv venv
source venv/bin/activate
check_success

echo "📦 Installing dependencies..."
pip install -r requirements.txt
check_success

echo "📝 Creating .env file..."
cat <<EOL > .env
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name
DB_HOST=your_db_host

AWS_BUCKET_NAME=your_s3_bucket
AWS_REGION=$AWS_REGION
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
EOL
check_success

echo "⚡ Running the project locally..."
python src/main.py
check_success

echo "✅ Running unit tests..."
pytest tests/
check_success

echo "🐳 Building Docker image..."
docker build -t $ECR_REPO_NAME .
check_success

echo "🛠 Logging into AWS ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
check_success

echo "📂 Creating AWS ECR Repository..."
aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION || echo "Repository may already exist."
check_success

echo "🏷 Tagging and pushing Docker image to ECR..."
docker tag $ECR_REPO_NAME:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest
check_success

echo "🚀 Creating ECS Task Definition..."
aws ecs register-task-definition --family $ECS_TASK_NAME --network-mode awsvpc --requires-compatibilities FARGATE \
    --cpu "256" --memory "512" --execution-role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/ecsTaskExecutionRole" \
    --container-definitions "[{\"name\":\"$ECS_TASK_NAME\",\"image\":\"$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:latest\",\"memory\":512,\"cpu\":256,\"essential\":true,\"environment\":[{\"name\":\"AWS_REGION\",\"value\":\"$AWS_REGION\"}]}]"
check_success

echo "⏳ Scheduling CloudWatch Event Rule..."
aws events put-rule --schedule-expression "$SCHEDULE_EXPRESSION" --name "$ECS_TASK_NAME-schedule"
check_success

echo "🔗 Setting up ECS Fargate Task..."
aws events put-targets --rule "$ECS_TASK_NAME-schedule" --targets "[{\"Id\":\"1\",\"Arn\":\"arn:aws:ecs:$AWS_REGION:$AWS_ACCOUNT_ID:cluster/$ECS_CLUSTER_NAME\",\"RoleArn\":\"arn:aws:iam::$AWS_ACCOUNT_ID:role/ecsEventsRole\"}]"
check_success

echo "🎉 Deployment Complete! Your service is now running on AWS ECS Fargate."
