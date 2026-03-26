Write-Host "Bipity bopity your IP is now my property"

$myIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.*" 
}).IPAddress
Write-Host "Your local IP: $myIP" -ForegroundColor Green

$target = Read-Host "Write Hostname og IP address"

if ([string]::IsNullOrWhiteSpace($target)) {
    Write-Error "Rerun the code and enter a hostname og IP address"

} else {
    Write-Host "Here is information on your targets network" -ForegroundColor Yellow
    Test-NetConnection -ComputerName $target -InformationLevel "Detailed" -TraceRoute
}