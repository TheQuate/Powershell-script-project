$files = Get-ChildItem "C:\Users\Joakim Sandum Thrane\OneDrive - Innlandet fylkeskommune\Skolefag" | Where-Object { -not $_.PSIsContainer}

$folders = Get-ChildItem "C:\Users\Joakim Sandum Thrane\OneDrive - Innlandet fylkeskommune\Skolefag" | Where-Object { -not $_.PSIsContainer}

$files | Sort-Object Length -Descending

$folders | Sort-Object Length -Descending

