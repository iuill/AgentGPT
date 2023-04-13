# Set execution policy
Set-ExecutionPolicy Bypass -Scope Process -Force

# Set error action preference
$ErrorActionPreference = "Stop"

# Change to the script directory
$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $ScriptPath

# Get OpenAI API Key
$OPENAI_API_KEY = Read-Host -Prompt "Enter your OpenAI Key (eg: sk...)"

# Generate NextAuth secret
$RNGCryptoServiceProvider = New-Object Security.Cryptography.RNGCryptoServiceProvider
$RandomBytes = New-Object Byte[] 32
$RNGCryptoServiceProvider.GetBytes($RandomBytes)
$NEXTAUTH_SECRET = [Convert]::ToBase64String($RandomBytes)

# Prepare .env content
$ENV = @"
NODE_ENV=development
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
NEXTAUTH_URL=http://localhost:3000
OPENAI_API_KEY=$OPENAI_API_KEY
DATABASE_URL=file:../db/db.sqlite
"@

# Write .env file
Set-Content -Path ".env" -Value $ENV

if ($args[0] -eq "--docker") {
    Set-Content -Path ".env.docker" -Value $ENV
    docker build -t agentgpt .
    docker run -d --name agentgpt -p 3000:3000 -v "$(Get-Location)/db:/app/db" agentgpt
} else {
    Write-Output "Do not implemented."
}
