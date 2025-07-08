# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Show-Help {
    Write-Host "This script helps to terminate processes that are using a specified port."
    Write-Host ""
    Write-Host "Usage: Run the script and enter a port number when prompted."
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  Enter port: 8080"
    Write-Host "  (Then it terminates processes using port 8080)"
    Write-Host ""
    exit
}

# Ask user for input
$userInput = Read-Host "Enter port number: "

if ($userInput -in @("help", "-h", "--help", "-?")) {
    Show-Help
}

if (-not ($userInput -match '^\d+$')) {
    Write-Host "Invalid port number. Please enter a numeric port."
    exit
}

$port = $userInput
$killedPIDs = @()

# Get all connections matching the port
$connections = netstat -ano | Select-String -Pattern "[:.]$port\s"

if (-not $connections) {
    Write-Host "No processes found for port: $port."
    exit
}

foreach ($line in $connections) {
    $parts = $line.ToString() -split '\s+'
    $processId = $parts[-1]

    if (-not $killedPIDs -contains $processId) {
        try {
            $process = Get-Process -Id $processId -ErrorAction Stop
            Write-Host "Killing process: $($process.ProcessName) (PID: $processId)"
            Stop-Process -Id $processId -Force
            $killedPIDs += $processId
        }
        catch {
            Write-Host "Could not retrieve or kill process with PID $processId"
        }
    }
}
