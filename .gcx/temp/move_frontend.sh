#!/bin/bash
cp -r platform/ui-sample/* platform/frontend/
cp platform/ui-sample/.gitignore platform/frontend/
# Copy hidden files if any (like .env)
cp platform/ui-sample/.env* platform/frontend/ 2>/dev/null
echo "Moved ui-sample to frontend"
