# FILE 1: test.ps1 (create this file in your repository root)

Write-Host "=== LTSC 2022 HTTPBin Test ===" -ForegroundColor Green
Write-Host "OS: $(Get-ComputerInfo | Select-Object -ExpandProperty WindowsProductName)" -ForegroundColor Cyan
Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Test HTTPBin JSON endpoint
Write-Host "Testing HTTPBin JSON endpoint..." -ForegroundColor Yellow
try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $response = Invoke-RestMethod -Uri "https://httpbin.org/json" -TimeoutSec 15 -ErrorAction Stop
    $stopwatch.Stop()
    
    Write-Host "✅ SUCCESS! ($($stopwatch.ElapsedMilliseconds)ms)" -ForegroundColor Green
    Write-Host "Response received:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 2
    
} catch {
    Write-Host "❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try alternative method
    Write-Host "Trying with TLS 1.2 and skip certificate check..." -ForegroundColor Yellow
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $response2 = Invoke-RestMethod -Uri "https://httpbin.org/json" -SkipCertificateCheck -TimeoutSec 15 -ErrorAction Stop
        Write-Host "✅ SUCCESS with workaround!" -ForegroundColor Green
        $response2 | ConvertTo-Json -Depth 2
    } catch {
        Write-Host "❌ Still failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Test complete!" -ForegroundColor Green
