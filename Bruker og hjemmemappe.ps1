Import-Module ActiveDirectory

# ========================
# Første steg er en rekke variabler som setter hvor brukerne hentes fra, hvor hjemme mappene skal ligge og definerer share navnet. 
# Den definerer også Server som PC navnet for enklere henting av informasjonen. 
# 
# Her må man sette egne mapper og filnavn hvis ikke klarer ikke scriptet å hente riktig informasjon. 
# ========================
$CsvPath          = "C:\Userlist-sn.csv"
$HomeRootPath     = "C:\Home_Folders"
$ShareName        = "Home_Folders$"
$HomeDriveLetter  = "H:"
$Server           = $env:COMPUTERNAME

# ========================
# Her hentes CSV filen fra path-en satt tidligere. Etter dette defineres alle variablene fra CSV filen. 
# I tillegg lager den også en ny variabel som definerer hjemmemappe og share path
# ========================
Import-Csv $CsvPath | ForEach-Object {

    $FirstName   = $_.Firstname
    $LastName    = $_.Lastname
    $Sam         = $_.SAM
    $Domain      = $_.Maildomain
    $OU          = $_.OU
    $Password    = $_.Password
    $Description = $_.Description

    $DisplayName = "$FirstName $LastName"
    $UPN         = "$Sam@$Domain"

    $HomeFolderLocal = Join-Path $HomeRootPath $Sam
    $HomeFolderUNC   = "\\$Server\$ShareName\$Sam"

    Write-Host "Processing user: $Sam"

    # ========================
    # Oppretting av bruker: her bruker den tidligere lagde variabler fra CSV filen og sjekker om brukeren finnes før den lager den. 
    # ========================
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Sam'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name $DisplayName `
            -GivenName $FirstName `
            -Surname $LastName `
            -SamAccountName $Sam `
            -UserPrincipalName $UPN `
            -Path $OU `
            -Description $Description `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $false

        Write-Host "AD user created"
    }
    else {
        Write-Host "AD user already exists"
    }
    # ========================
    # Sjekke og legge til grupper
    # Her sjekker den hvilke grupper brukeren har og legger til utfra listen med nødvendige grupper fra CSV filen. Her får du fra terminalen en beskjed om brukern allerede er medlem eller ikke. 
    # ========================
    if ($_.Groups) {

    $GroupList = $_.Groups -split ";" | ForEach-Object { $_.Trim() }

    foreach ($Group in $GroupList) {

        try {
            # Sjekker om gruppen finnes
            $AdGroup = Get-ADGroup -Identity $Group -ErrorAction Stop

            # Sjekker om brukern er medlem i grupopen
            $IsMember = Get-ADGroupMember $AdGroup -Recursive |
                        Where-Object { $_.SamAccountName -eq $Sam }

            if (-not $IsMember) {
                Add-ADGroupMember -Identity $AdGroup -Members $Sam
                Write-Host "  Added to group: $Group"
            }
            else {
                Write-Host "  Already member of group: $Group"
            }
        }
        catch {
            Write-Warning "  Group not found or failed: $Group"
        }
    }
}


    # ========================
    # Denne delen lager en ny hjemmemappe til brukeren. Først sjekker den om mappen allerede finnes, så lager den mappen via New-Item funksjonen. 
    # ========================
    if (-not (Test-Path $HomeFolderLocal)) {
        New-Item -Path $HomeFolderLocal -ItemType Directory | Out-Null
        Write-Host "  Home folder created"
    }

    # ========================
    # Setter NTFS tilganger både for bruker og for domene admin
    # ========================
    $UserObject = Get-ADUser $Sam
    $Acl = Get-Acl $HomeFolderLocal

    # Disable inheritance & remove inherited permissions
    $Acl.SetAccessRuleProtection($true, $false)
    $Acl.Access | ForEach-Object { $Acl.RemoveAccessRule($_) }

    # User: Full Control
    $UserRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $UserObject.SID,
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    # Domain Admins: Full Control
    $AdminRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        "Domain Admins",
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )

    $Acl.AddAccessRule($UserRule)
    $Acl.AddAccessRule($AdminRule)

    Set-Acl -Path $HomeFolderLocal -AclObject $Acl
    Write-Host "  NTFS permissions set"

    # ========================
    # Den siste setter den mappen som er opprettet til hjem mappe for brukeren.
    # ========================
    Set-ADUser -Identity $Sam `
        -HomeDrive $HomeDriveLetter `
        -HomeDirectory $HomeFolderUNC

    Write-Host "  Home drive mapped to $HomeFolderUNC"
    Write-Host "--------------------------------------"
}
