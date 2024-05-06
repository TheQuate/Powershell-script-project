try {
    [System.Console]::Beep(440,500)
    [System.Console]::Beep(440,500)
    [System.Console]::Beep(440,500)
    [System.Console]::Beep(349,350)
    [System.Console]::Beep(523,150)
    [System.Console]::Beep(440,500)
    [System.Console]::Beep(349,350)
    [System.Console]::Beep(523,150)
	[System.Console]::beep(440, 1000)
	[System.Console]::beep(659, 500)       
	[System.Console]::beep(659, 500)       
	[System.Console]::beep(659, 500)       
	[System.Console]::beep(698, 350)       
	[System.Console]::beep(523, 150)       
	[System.Console]::beep(415, 500)       
	[System.Console]::beep(349, 350)       
	[System.Console]::beep(523, 150)       
	[System.Console]::beep(440, 1000)
    exit 0 #success
}
catch {
    "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
    <#Do this if a terminating exception happens#>
}