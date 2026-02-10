# Hummingbot Deploy Setup Script (PowerShell Version)
# This script sets up the deployment environment for Hummingbot Deploy
# with all necessary configuration options

# Fix console encoding to UTF-8 to display emojis correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"

# Colors are handled by Write-Host directly in PowerShell

Write-Host "🚀 Hummingbot Deploy Setup" -ForegroundColor Cyan
Write-Host ""

# Config Password
if (Test-Path ".env") {
    $SkipConfig = Read-Host "Configuration file (.env) already exists. Skip configuration? (Y/n) [default: Y]"
    if ([string]::IsNullOrWhiteSpace($SkipConfig)) {
        $SkipConfig = "Y"
    }
} else {
    $SkipConfig = "n"
}

if ($SkipConfig -eq "n" -or $SkipConfig -eq "N") {
    $ConfigPassword = Read-Host "Config password [default: admin]"
    if ([string]::IsNullOrWhiteSpace($ConfigPassword)) {
        $ConfigPassword = "admin"
    }

    # Dashboard Username
    $Username = Read-Host "Dashboard username [default: admin]"
    if ([string]::IsNullOrWhiteSpace($Username)) {
        $Username = "admin"
    }

    # Dashboard Password
    $Password = Read-Host "Dashboard password [default: admin]"
    if ([string]::IsNullOrWhiteSpace($Password)) {
        $Password = "admin"
    }

    # Set paths and defaults
    $BotsPath = Get-Location

    # Use sensible defaults for deployment
    $DebugMode = "false"
    $BrokerHost = "localhost"
    $BrokerPort = "1883"
    $BrokerUsername = "admin"
    $BrokerPassword = "password"
    $DatabaseUrl = "postgresql+asyncpg://hbot:hummingbot-api@localhost:5432/hummingbot_api"
    $CleanupInterval = "300"
    $FeedTimeout = "600"
    $AwsApiKey = ""
    $AwsSecretKey = ""
    $S3Bucket = ""
    $LogfireEnv = "prod"
    $BannedTokens = '["NAV","ARS","ETHW","ETHF","NEWT"]'

    Write-Host ""
    Write-Host "✅ Using sensible defaults for MQTT, Database, and other settings" -ForegroundColor Green

    Write-Host ""
    Write-Host "📝 Creating .env file..." -ForegroundColor Green

    # Generate .env content
    $EnvContent = @"
# =================================================================
# Hummingbot Deploy Environment Configuration
# Generated on: $(Get-Date)
# =================================================================

# =================================================================
# 🔐 Security Configuration
# =================================================================
HB_USERNAME=$Username
PASSWORD=$Password
DEBUG_MODE=$DebugMode
CONFIG_PASSWORD=$ConfigPassword

# =================================================================
# 🔗 MQTT Broker Configuration (BROKER_*)
# =================================================================
BROKER_HOST=$BrokerHost
BROKER_PORT=$BrokerPort
BROKER_USERNAME=$BrokerUsername
BROKER_PASSWORD=$BrokerPassword

# =================================================================
# 💾 Database Configuration (DATABASE_*)
# =================================================================
DATABASE_URL=$DatabaseUrl

# =================================================================
# 📊 Market Data Feed Manager Configuration (MARKET_DATA_*)
# =================================================================
MARKET_DATA_CLEANUP_INTERVAL=$CleanupInterval
MARKET_DATA_FEED_TIMEOUT=$FeedTimeout

# =================================================================
# ☁️ AWS Configuration (AWS_*) - Optional
# =================================================================
AWS_API_KEY=$AwsApiKey
AWS_SECRET_KEY=$AwsSecretKey
AWS_S3_DEFAULT_BUCKET_NAME=$S3Bucket

# =================================================================
# ⚙️ Application Settings
# =================================================================
LOGFIRE_ENVIRONMENT=$LogfireEnv
BANNED_TOKENS=$BannedTokens

# =================================================================
# 📁 Application Paths
# =================================================================
BOTS_PATH=$BotsPath

"@

    # Write .env file (using UTF8 encoding to avoid issues)
    $EnvContent | Out-File -FilePath ".env" -Encoding utf8

    Write-Host "✅ .env file created successfully!" -ForegroundColor Green
    Write-Host ""

    # Display configuration summary
    Write-Host "📋 Configuration Summary" -ForegroundColor Blue
    Write-Host "======================="
    Write-Host "Security: Username: $Username, Debug: $DebugMode" -ForegroundColor Cyan
    Write-Host "Broker: $BrokerHost`:$BrokerPort" -ForegroundColor Cyan
    Write-Host "Database: ${DatabaseUrl} (hidden creds)" -ForegroundColor Cyan
    Write-Host "Market Data: Cleanup: ${CleanupInterval}s, Timeout: ${FeedTimeout}s" -ForegroundColor Cyan
    Write-Host "Environment: $LogfireEnv" -ForegroundColor Cyan

    if (-not [string]::IsNullOrWhiteSpace($AwsApiKey)) {
        Write-Host "AWS: Configured with S3 bucket: $S3Bucket" -ForegroundColor Cyan
    } else {
        Write-Host "AWS: Not configured (optional)" -ForegroundColor Cyan
    }
} else {
    Write-Host "⏭️  Skipping configuration (using existing .env file)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🐳 Pulling required Docker images..." -ForegroundColor Green

# Pull Docker images
# Using Start-Process to run in parallel is possible but simpler to run sequentially for stability in script
docker compose pull
docker pull hummingbot/hummingbot:latest

Write-Host "✅ All Docker images pulled successfully!" -ForegroundColor Green
Write-Host ""

# Check if password verification file exists
$VerifyPath = "bots\credentials\master_account\.password_verification"
if (-not (Test-Path $VerifyPath)) {
    Write-Host "📌 Note: Password verification file will be created on first startup" -ForegroundColor Yellow
    Write-Host "   Location: $VerifyPath" -ForegroundColor Blue
    Write-Host ""
}

Write-Host "🚀 Starting Hummingbot Deploy services..." -ForegroundColor Green

# Start the deployment
docker compose up -d

Write-Host ""
Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host ""

Write-Host "Your services are now running:"
Write-Host "📊 Dashboard: http://localhost:8501" -ForegroundColor Blue
Write-Host "🔧 API Docs: http://localhost:8000/docs" -ForegroundColor Blue
Write-Host "📡 MQTT Broker: localhost:1883" -ForegroundColor Blue
Write-Host ""

Write-Host "Next steps:"
Write-Host "1. Access the Dashboard: http://localhost:8501"
Write-Host "2. Configure your trading strategies"
Write-Host "3. Monitor logs: docker compose logs -f"
Write-Host ""
Write-Host "💡 Pro tip: You can modify environment variables in .env file anytime" -ForegroundColor Magenta
Write-Host "📚 Documentation: Check CLAUDE.md for project guidance" -ForegroundColor Magenta
Write-Host "🔒 Security: The password verification file secures bot credentials" -ForegroundColor Magenta
Write-Host ""
Write-Host "Happy Trading! 🤖💰" -ForegroundColor Green
