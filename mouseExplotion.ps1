while ($true) {
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point -ArgumentList (Get-Random -Minimum 0 -Maximum 1920), (Get-Random -Minimum 0 -Maximum 1080)
    Start-Sleep -Milliseconds 100
}