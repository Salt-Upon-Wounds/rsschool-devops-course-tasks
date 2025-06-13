# Имя IAM-пользователя
$userName = "taskuser"
$region = "us-east-1"

Write-Host "📦 Getting MFA device ARN for user: $userName..."
$mfaArn = (aws iam list-mfa-devices --user-name $userName --query "MFADevices[0].SerialNumber" --output text)

if (-not $mfaArn) {
    Write-Error "❌ MFA device not found for user $userName"
    exit
}

Write-Host "🔐 MFA ARN: $mfaArn"
$mfaCode = Read-Host "⏳ Enter your 6-digit MFA code"

Write-Host "📡 Requesting session token..."
$credsJson = aws sts get-session-token `
    --serial-number $mfaArn `
    --token-code $mfaCode `
    --region $region `
    --query "Credentials" `
    --output json

if (-not $credsJson) {
    Write-Error "❌ Failed to get session token"
    exit
}

# Правильный парсинг JSON для PowerShell
$creds = $credsJson | ConvertFrom-Json

# Экспорт временных ключей в текущую сессию PowerShell
$env:AWS_ACCESS_KEY_ID = $creds.AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $creds.SecretAccessKey
$env:AWS_SESSION_TOKEN = $creds.SessionToken

Write-Host "`n✅ Temporary AWS credentials set for this session:`n"
Write-Host "AWS_ACCESS_KEY_ID=$($env:AWS_ACCESS_KEY_ID)"
Write-Host "AWS_SECRET_ACCESS_KEY=$($env:AWS_SECRET_ACCESS_KEY)"
Write-Host "AWS_SESSION_TOKEN=$($env:AWS_SESSION_TOKEN)"

Write-Host "`n🧪 Testing temporary credentials..."
aws sts get-caller-identity --region $region
