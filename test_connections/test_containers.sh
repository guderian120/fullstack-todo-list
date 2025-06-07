#!/bin/bash

# Test Script for 3-Tier Application

echo "---------------------------------------------"
echo "Verifying Docker Containers Status"
echo "---------------------------------------------"
docker-compose ps

echo -e "\n---------------------------------------------"
echo "Testing Backend API Endpoint"
echo "---------------------------------------------"
BACKEND_RESPONSE=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" http://localhost:3000/api/gettodos)
BACKEND_BODY=$(echo $BACKEND_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
BACKEND_STATUS=$(echo $BACKEND_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

if [ "$BACKEND_STATUS" -ge 200 ] && [ "$BACKEND_STATUS" -le 299 ]; then
  echo "✅ Backend is accessible. Response:"
  echo "$BACKEND_BODY"
else
  echo "❌ Backend API test failed. Status code: $BACKEND_STATUS"
  exit 1
fi

echo -e "\n---------------------------------------------"
echo "Testing Frontend Accessibility"
echo "---------------------------------------------"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000)

if [ "$FRONTEND_STATUS" -ge 200 ] && [ "$FRONTEND_STATUS" -le 299 ]; then
  echo "✅ Frontend is accessible at http://localhost:8000"
else
  echo "❌ Frontend is not accessible. Status code: $FRONTEND_STATUS"
  exit 1
fi

echo -e "\n---------------------------------------------"
echo "Testing MongoDB Container Connection"
echo "---------------------------------------------"
docker exec database mongosh -u user -p password --authenticationDatabase admin --eval "db.adminCommand('ping')" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "✅ MongoDB is running and authenticated successfully"
else
  echo "❌ MongoDB test failed. Could not connect or authenticate"
  exit 1
fi

echo -e "\n✅ All tests passed successfully!"
