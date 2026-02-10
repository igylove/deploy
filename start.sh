#!/bin/bash
set -e
docker compose up -d
echo "Dashboard: http://localhost:8501"
echo "API Docs: http://localhost:8000/docs"
