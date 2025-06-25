# Dockerfile (same directory as workflow)
FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

# Simple HTTPBin test
RUN Set-Content -Path "C:\test.ps1" -Value @' \
Write-Host "=== LTSC 2022 HTTPBin Test ===" -ForegroundColor Green \
Write-Host "OS: $(Get-ComputerInfo | Select -ExpandProperty WindowsProductName)" \
Write-Host "PowerShell: $($PSVersionTable.PSVersion)" \
Write-Host "" \
\
try { \
    Write-Host "Testing HTTPBin..." -ForegroundColor Yellow \
    $response = Invoke-RestMethod "https://httpbin.org/json" -TimeoutSec 10 \
    Write-Host "✅ SUCCESS: HTTPBin works!" -ForegroundColor Green \
    $response | ConvertTo-Json -Depth 2 \
} catch { \
    Write-Host "❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red \
    \
    Write-Host "Trying with TLS 1.2..." -ForegroundColor Yellow \
    try { \
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 \
        $response2 = Invoke-RestMethod "https://httpbin.org/json" -TimeoutSec 10 \
        Write-Host "✅ SUCCESS with TLS 1.2!" -ForegroundColor Green \
    } catch { \
        Write-Host "❌ Still failed: $($_.Exception.Message)" -ForegroundColor Red \
    } \
} \
'@

CMD ["powershell", "-File", "C:\\test.ps1"]
