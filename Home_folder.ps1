Import-Module ActiveDirectory

# ========================
# CONFIG
# ========================
$CsvPath          = "C:\Userlist-sn.csv"
$HomeRootPath     = "C:\Home_Folders"
$ShareName        = "Home_Folders$"
$HomeDriveLetter  = "H:"
$Server           = $env:COMPUTERNAME

# ========================
# PROCESS CSV
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
    # CREATE USER (IF NEEDED)
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

        Write-Host "  AD user created"
    }
    else {
        Write-Host "  AD user already exists"
    }
    # ========================
    # ADD USER TO GROUPS (SAFE)
    # ========================
    if ($_.Groups) {

    $GroupList = $_.Groups -split ";" | ForEach-Object { $_.Trim() }

    foreach ($Group in $GroupList) {

        try {
            # Check if group exists
            $AdGroup = Get-ADGroup -Identity $Group -ErrorAction Stop

            # Check if user is already a member
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
    # CREATE HOME FOLDER
    # ========================
    if (-not (Test-Path $HomeFolderLocal)) {
        New-Item -Path $HomeFolderLocal -ItemType Directory | Out-Null
        Write-Host "  Home folder created"
    }

    # ========================
    # NTFS PERMISSIONS
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
    # SET HOME DRIVE IN AD
    # ========================
    Set-ADUser -Identity $Sam `
        -HomeDrive $HomeDriveLetter `
        -HomeDirectory $HomeFolderUNC

    Write-Host "  Home drive mapped to $HomeFolderUNC"
    Write-Host "--------------------------------------"
}
