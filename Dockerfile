FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as default shell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# Copy the PowerShell script from local repository into the container
COPY test.ps1 C:/test.ps1

# Verify the file was copied
RUN Write-Host "Copied test.ps1 to container" -ForegroundColor Green; \
    Test-Path C:/test.ps1

# Set the default command to run our test script
CMD ["powershell", "-ExecutionPolicy", "Bypass", "-File", "C:\\test.ps1"]
