<#
.SYNOPSIS
    Updates a user's detention record and enforces security group membership.
.DESCRIPTION
    This script implements an Attribute-Based Access Control (ABAC) update.
    It increments the integer value in the 'OfficePhone' attribute (simulating 'Detention Hours')
    and ensures the user is added to the 'Detention_Squad' security group.
.PARAMETER StudentName
    The SamAccountName of the user (e.g., 'harry.potter').
.PARAMETER HoursAssigned
    Integer value of hours to add to the record.
#>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$StudentName,

    [Parameter(Mandatory=$true, Position=1)]
    [int]$HoursAssigned
)

# Configuration
$DetentionGroup = "Detention_Squad"
$AttributeField = "OfficePhone" # Mapping 'Detention Hours' to a standard AD Attribute

try {
    # 1. Identity Verification
    $Student = Get-ADUser -Filter "SamAccountName -eq '$StudentName'" -Properties $AttributeField -ErrorAction Stop
    
    # 2. Attribute Logic (Calculate Balance)
    [int]$CurrentHours = 0
    if ($Student.$AttributeField -match '^\d+$') {
        $CurrentHours = [int]$Student.$AttributeField
    }
    $NewBalance = $CurrentHours + $HoursAssigned

    # 3. Modify Identity Object
    Set-ADUser -Identity $Student -Replace @{$AttributeField="$NewBalance"} -ErrorAction Stop

    # 4. Enforce Access Control (Group Membership)
    # Check if already a member to avoid error noise
    $MemberCheck = Get-ADGroupMember -Identity $DetentionGroup -Filter "SamAccountName -eq '$StudentName'" -ErrorAction SilentlyContinue
    
    if (-not $MemberCheck) {
        Add-ADGroupMember -Identity $DetentionGroup -Members $Student -ErrorAction Stop
        $GroupStatus = "ADDED to $DetentionGroup"
    } else {
        $GroupStatus = "Already in $DetentionGroup"
    }

    # 5. Output Result Object (Professional Standard)
    # Instead of text, we output an object that can be exported to CSV or logs
    [PSCustomObject]@{
        Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm"
        User         = $Student.Name
        Action       = "Assign Detention"
        HoursAdded   = $HoursAssigned
        TotalBalance = $NewBalance
        GroupStatus  = $GroupStatus
    }

    Write-Host "[SUCCESS] Detention record updated for $($Student.Name)." -ForegroundColor Green
}
catch {
    Write-Error "Failed to assign detention: $_"
}
