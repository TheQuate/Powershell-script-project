
#Define path to your import CSV file location in a variable as shown in below line.
$AD_Users = Import-csv .\navn.csv
foreach ($User in $AD_Users)
{
       $User_name    = $User.username
       $User_Password    = $User.password
       $First_name   = $User.firstname
       $Last_name    = $User.lastname
    $User_Department = $User.department
       $User_OU           = $User.ou
       #Below if-else condition will check if the user already exists in Active Directory.
       if (Get-ADUser -F {SamAccountName -eq $User_name})
       {
               #Will output a warning message if user exist.
               Write-Warning "A user $User_name has already existed in Active Directory."
       }
       else
       {
              #Will create a new user, if user is not available in Active Directory.
          
        #User account will be created in the OU listed in the $User_OU variable in the CSV file; it is necessary to change the domain name in the"-UserPrincipalName" variable in the script below.
              New-ADUser `
            -SamAccountName $User_name `
            -UserPrincipalName "$Username@example.com"
            -Name "$First_name $Last_name"
            -GivenName $First_name `
            -Surname $Last_name `
            -Enabled $True `
            -ChangePasswordAtLogon $false `
            -DisplayName "$First_name, $Last_name" `
            -Department $User_Department `
            -Path $User_OU `
            -AccountPassword (IbanezGuitars21!) 
            
       }
}
    #create homefolder, and set access rights for it
$domain = 'gitarlydas.no'
$initials = '$User_name'
$homedir = 'H:\'

$folder = New-Item $homedir -Type Directory

$acl = Get-Acl -LiteralPath $folder.FullName
$acl.SetAccessRuleProtection($false, $true)

$ace = "$($domain)\$($initials)","FullControl", "ContainerInherit,ObjectInherit","None","Allow"

$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($ace)
$acl.AddAccessRule($objACE)

Set-ACL -LiteralPath $folder.FullName -AclObject $acl

