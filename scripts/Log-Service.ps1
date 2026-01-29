<#
.SYNOPSIS
    Decrements a user's detention balance and restores access if compliant.
.DESCRIPTION
    This script automates the remediation phase of the Identity Lifecycle.
    It reduces the integer value in the 'OfficePhone' attribute.
    Logic: If the balance reaches 0, the user is automatically removed from 
    the 'Detention_Squad' security group (Automated Deprovisioning of Restrictions).
.PARAMETER StudentName
    The SamAccountName of the user.
.PARAMETER HoursServed
    Integer value of hours to deduct from the record.
#>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$StudentName,

    [Parameter(Mandatory=$true, Position=1)]
    [int]$HoursServed
)

# Configuration
$DetentionGroup = "Detention_Squad"
$AttributeField = "OfficePhone" 

try {
    # 1. Get Current Identity State
    $Student = Get-ADUser -Filter "SamAccountName -eq '$StudentName'" -Properties $AttributeField -ErrorAction Stop
    
    # 2. Parse Current Balance
    [int]$CurrentHours = 0
    if ($Student.$AttributeField -match '^\d+$') { 
        $CurrentHours = [int]$Student.$AttributeField 
    }

    if ($CurrentHours -eq 0) {
        Write-Warning "User '$StudentName' has no active detention record."
        break
    }

    # 3. Calculate Remediation
    $Remaining = $CurrentHours - $HoursServed
    $ActionTaken = ""

    # 4. Conditional Access Logic (The "Freedom" Check)
    if ($Remaining -le 0) {
        # Condition Met: Remediation Complete
        Set-ADUser -Identity $Student -Clear $AttributeField -ErrorAction Stop
        
        # REVOKE RESTRICTION (Automated Security Ops)
        Remove-ADGroupMember -Identity $DetentionGroup -Members $Student -Confirm:$false -ErrorAction SilentlyContinue
        
        $Remaining = 0
        $ActionTaken = "ACCESS RESTORED (Removed from $DetentionGroup)"
        Write-Host "[COMPLIANT] $StudentName has cleared all detention hours." -ForegroundColor Green
    }
    else {
        # Condition Met: Partial Remediation
        Set-ADUser -Identity $Student -Replace @{$AttributeField="$Remaining"} -ErrorAction Stop
        $ActionTaken = "Balance Updated"
        Write-Host "[PARTIAL] $StudentName remaining balance: $Remaining hours." -ForegroundColor Yellow
    }

    # 5. Log Output
    [PSCustomObject]@{
        Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm"
        User          = $Student.Name
        HoursServed   = $HoursServed
        NewBalance    = $Remaining
        SystemAction  = $ActionTaken
    }
}
catch {
    Write-Error "System Error: $_"
}
