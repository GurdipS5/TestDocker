Write-Host "=== LTSC 2022 Azure DevOps REST API Test ===" -ForegroundColor Green
Write-Host "OS: $(Get-ComputerInfo | Select-Object -ExpandProperty WindowsProductName)" -ForegroundColor Cyan
Write-Host "PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Azure DevOps REST API endpoints to test
$azureDevOpsTests = @(
    @{
        Name = "Public Microsoft Projects"
        Url = "https://dev.azure.com/microsoft/_apis/projects?api-version=7.0"
        Description = "List Microsoft's public projects"
        RequiresAuth = $false
    },
    @{
        Name = "Azure DevOps Services Info"
        Url = "https://dev.azure.com/_apis/connectionData?api-version=7.0"
        Description = "Get Azure DevOps connection data"
        RequiresAuth = $false
    },
    @{
        Name = "Resource Areas"
        Url = "https://dev.azure.com/_apis/resourceAreas?api-version=7.0"
        Description = "List available resource areas"
        RequiresAuth = $false
    },
    @{
        Name = "Microsoft Repos (Public)"
        Url = "https://dev.azure.com/microsoft/vscode/_apis/git/repositories?api-version=7.0"
        Description = "List VSCode project repositories"
        RequiresAuth = $false
    }
)

Write-Host "Testing Azure DevOps REST API endpoints..." -ForegroundColor Yellow
Write-Host "=" * 60
Write-Host ""

foreach ($test in $azureDevOpsTests) {
    Write-Host "Testing: $($test.Name)" -ForegroundColor Magenta
    Write-Host "URL: $($test.Url)" -ForegroundColor Gray
    Write-Host "Description: $($test.Description)" -ForegroundColor Gray
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        # Standard Invoke-RestMethod test
        Write-Host "  Method 1: Standard Invoke-RestMethod..." -ForegroundColor Cyan
        $headers = @{
            'Accept' = 'application/json'
            'User-Agent' = 'PowerShell-LTSC2022-Test/1.0'
        }
        
        $response = Invoke-RestMethod -Uri $test.Url -Method GET -Headers $headers -TimeoutSec 30 -ErrorAction Stop
        $stopwatch.Stop()
        
        Write-Host "  ✅ SUCCESS ($($stopwatch.ElapsedMilliseconds)ms)" -ForegroundColor Green
        
        # Show response details
        if ($response) {
            if ($response.count) {
                Write-Host "  📊 Response count: $($response.count)" -ForegroundColor Yellow
            }
            if ($response.value -and $response.value.Count -gt 0) {
                Write-Host "  📋 First item: $($response.value[0].name -or $response.value[0].id -or 'No name/id')" -ForegroundColor Yellow
            }
            
            # Show sample of response
            $responseJson = $response | ConvertTo-Json -Depth 2 -Compress
            if ($responseJson.Length -gt 200) {
                $responseJson = $responseJson.Substring(0, 200) + "..."
            }
            Write-Host "  📄 Sample: $responseJson" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "  ❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
        
        # Try alternative methods for Azure DevOps
        Write-Host "  🔄 Trying alternative methods..." -ForegroundColor Yellow
        
        # Method 2: Force TLS 1.2
        try {
            Write-Host "    Method 2: Force TLS 1.2..." -ForegroundColor Cyan
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            $response2 = Invoke-RestMethod -Uri $test.Url -Method GET -Headers $headers -TimeoutSec 30 -ErrorAction Stop
            Write-Host "    ✅ SUCCESS with TLS 1.2" -ForegroundColor Green
        } catch {
            Write-Host "    ❌ TLS 1.2 failed: $($_.Exception.Message)" -ForegroundColor Red
            
            # Method 3: Skip certificate check
            try {
                Write-Host "    Method 3: Skip certificate check..." -ForegroundColor Cyan
                $response3 = Invoke-RestMethod -Uri $test.Url -Method GET -Headers $headers -SkipCertificateCheck -TimeoutSec 30 -ErrorAction Stop
                Write-Host "    ✅ SUCCESS with skip certificate" -ForegroundColor Green
            } catch {
                Write-Host "    ❌ Skip certificate failed: $($_.Exception.Message)" -ForegroundColor Red
                
                # Method 4: System.Net.WebRequest
                try {
                    Write-Host "    Method 4: WebRequest..." -ForegroundColor Cyan
                    $webRequest = [System.Net.WebRequest]::Create($test.Url)
                    $webRequest.Method = "GET"
                    $webRequest.Headers.Add("Accept", "application/json")
                    $webRequest.Headers.Add("User-Agent", "PowerShell-LTSC2022-Test/1.0")
                    $webRequest.Timeout = 30000
                    
                    $webResponse = $webRequest.GetResponse()
                    $statusCode = [int]$webResponse.StatusCode
                    $webResponse.Close()
                    
                    Write-Host "    ✅ SUCCESS with WebRequest (Status: $statusCode)" -ForegroundColor Green
                } catch {
                    Write-Host "    ❌ WebRequest failed: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host ""
}

# Test specific Azure DevOps scenarios that might fail with MCAS
Write-Host "=" * 60
Write-Host "Testing MCAS-problematic scenarios..." -ForegroundColor Magenta
Write-Host ""

# Test authentication header scenarios (without actual auth)
Write-Host "Testing authentication header handling..." -ForegroundColor Yellow
try {
    $authHeaders = @{
        'Authorization' = 'Basic dGVzdDp0ZXN0' # test:test in base64 (fake)
        'Accept' = 'application/json'
        'User-Agent' = 'PowerShell-LTSC2022-Test/1.0'
    }
    
    # This will fail auth but should test header handling
    $response = Invoke-RestMethod -Uri "https://dev.azure.com/_apis/connectionData?api-version=7.0" -Method GET -Headers $authHeaders -ErrorAction Stop
    Write-Host "✅ Auth headers processed successfully" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -match "401|Unauthorized") {
        Write-Host "✅ Auth headers processed (expected 401)" -ForegroundColor Green
    } else {
        Write-Host "❌ Auth header test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=" * 60
Write-Host "Azure DevOps REST API Test Complete!" -ForegroundColor Green
Write-Host ""

# Summary function
Write-Host "💡 Test Summary:" -ForegroundColor Cyan
Write-Host "  - Tested public Azure DevOps REST APIs" -ForegroundColor White
Write-Host "  - Verified LTSC 2022 compatibility" -ForegroundColor White
Write-Host "  - Checked various authentication scenarios" -ForegroundColor White
Write-Host "  - Tested different HTTP client methods" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Use this container if all tests passed!" -ForegroundColor Green
