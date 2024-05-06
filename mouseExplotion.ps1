while ($true) {
    [System.Windows.Forms.Cursor]::Postion = New-Object System.Drawing.Point -ArgumentList (Get-Randm -Minimum 0 -Maximum 1920), (Get-Random -Minimum 0 -Maximum 1080)
    Start-Sleep -Milliseconds 100
}