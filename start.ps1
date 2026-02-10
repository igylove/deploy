# Hummingbot Deploy Start Script (PowerShell Version)

# Fix console encoding to UTF-8 to display emojis correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Hummingbot Deploy..." -ForegroundColor Green

docker compose up -d

Write-Host ""
Write-Host "✅ Services started!" -ForegroundColor Green
Write-Host "📊 Dashboard: http://localhost:8501" -ForegroundColor Blue
Write-Host "🔧 API Docs: http://localhost:8000/docs" -ForegroundColor Blue
