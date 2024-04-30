$files = Get-ChildItem "C:\Program Files (x86)" | Where-Object { -not $_.PSIsContainer}

$folders = Get-ChildItem "C:\Program Files (x86)" | Where-Object { -not $_.PSIsContainer}

$files | Sort-Object Length -Descending

$folders | Sort-Object Length -Descending

