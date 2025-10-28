$Users = Import-Csv -Path ".\csv_fil.csv"
if ($Users.length -gt 0){
    Write-Host "CSV import completed successfully and contains data."
} else{
    "CSV import completed, but no data rows were found (only headers or empty file)."
}

foreach ($User in $Users)
{
    $Displayname = $User.Firstname + " " + $User.Lastname
    $UserFirstname = $User.Firstname
    $UserLastname = $User.Lastname
    $OU = "$User.OU"
    $SAM = $User.SAM
    $UPN = $User.Firstname + "." + $User.Lastname + "@" + $User.Maildomain
    $Description = $User.Description
    $Password = $User.Password
    try {
        New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $false -PasswordNeverExpires $true -server domain.loc
        Write-Host "User created"
    }
    catch {
        Write-Host "User not Created"
    }
}

