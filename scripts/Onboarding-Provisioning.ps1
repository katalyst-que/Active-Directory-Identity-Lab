# PROJECT: Hogwarts Automated User Provisioning

$HogwartsUsers = Import-Csv "C:\hogwarts_users.csv"

# Set the Default Password (demonstration – non-randomized)
$SecurePassword = ConvertTo-SecureString "H0gwarts!2026" -AsPlainText -Force

$BasePath = "DC=hogwarts,DC=local" 

$OUs = @("Student", "Staff", "Groups")
foreach ($OU in $OUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$OU'")) {
        New-ADOrganizationalUnit -Name $OU -Path $BasePath
        Write-Host "Created OU: $OU" -ForegroundColor Cyan
    }
}

foreach ($Wizard in $HogwartsUsers) {
    $SamAccountName = "$($Wizard.FirstName).$($Wizard.LastName)".ToLower()
    $UserPath = "OU=$($Wizard.Role),DC=hogwarts,DC=local"

    if (Get-ADUser -Filter {SamAccountName -eq $SamAccountName}) {
        Write-Host "Wizard $SamAccountName already exists." -ForegroundColor Yellow
    }
    else {
        New-ADUser -Name $SamAccountName `
            -GivenName $Wizard.FirstName `
            -Surname $Wizard.LastName `
            -SamAccountName $SamAccountName `
            -UserPrincipalName "$SamAccountName@hogwarts.local" `
            -Path $UserPath `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -Description "$($Wizard.House) - $($Wizard.JobTitle)" `
            -Department $Wizard.House
        
        Write-Host "Provisionsed Account: $SamAccountName" -ForegroundColor Green
    }

    # If user is assigned to a House, add them to that House's Common Room Group
    if ($Wizard.House -ne "None") {
        $HouseGroup = "$($Wizard.House)_CommonRoom"
        
        # Create Group if it doesn't exist
        if (-not (Get-ADGroup -Filter "Name -eq '$HouseGroup'")) {
            New-ADGroup -Name $HouseGroup -GroupScope Global -Path "OU=Groups,DC=hogwarts,DC=local"
        }
        Add-ADGroupMember -Identity $HouseGroup -Members $SamAccountName
    }

    # The "Hermione Rule" (Conditional Access)
    # "Girls can enter Boys Dorms, but Boys cannot enter Girls Dorms"
    if ($Wizard.House -eq "Gryffindor" -and $Wizard.Role -eq "Student") {
       
        $BoysDorm = "Gryffindor_BoysDorm"
        $GirlsDorm = "Gryffindor_GirlsDorm"
        if (-not (Get-ADGroup -Filter "Name -eq '$BoysDorm'")) { New-ADGroup -Name $BoysDorm -GroupScope Global -Path "OU=Groups,DC=hogwarts,DC=local" }
        if (-not (Get-ADGroup -Filter "Name -eq '$GirlsDorm'")) { New-ADGroup -Name $GirlsDorm -GroupScope Global -Path "OU=Groups,DC=hogwarts,DC=local" }

        Add-ADGroupMember -Identity $BoysDorm -Members $SamAccountName
        if ($Wizard.Gender -eq "Female") {
            Add-ADGroupMember -Identity $GirlsDorm -Members $SamAccountName
            Write-Host "  -> Granted Hermione Rule Access (All Dorms) to $SamAccountName" -ForegroundColor Magenta
        }
    }

    # The "Hagrid Rule" (Special Privileges) ---
    if ($Wizard.SpecialAccess -ne "None") {
        $SpecialGroup = $Wizard.SpecialAccess
        
        # Create the Special Group 
        if (-not (Get-ADGroup -Filter "Name -eq '$SpecialGroup'")) {
            New-ADGroup -Name $SpecialGroup -GroupScope Global -Path "OU=Groups,DC=hogwarts,DC=local"
        }
        Add-ADGroupMember -Identity $SpecialGroup -Members $SamAccountName
        Write-Host "  -> Assigned SPECIAL PRIVILEGE: $SpecialGroup to $SamAccountName" -ForegroundColor Red
    }
}

