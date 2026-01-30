# SCRIPT: Log-Service.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$StudentName,

    [Parameter(Mandatory=$true)]
    [int]$HoursServed
)

Write-Host "Processing log for: [$StudentName]..." -NoNewline


try {
    $Student = Get-ADUser -Filter "SamAccountName -eq '$StudentName'" -Properties Office -ErrorAction Stop
}
catch {
    Write-Warning " Student not found!"
    break
}

[int]$CurrentHours = 0
if ($Student.Office -match '^\d+$') { 
    $CurrentHours = [int]$Student.Office 
}

if ($CurrentHours -eq 0) {
    Write-Host " Has no hours recorded." -ForegroundColor Cyan
    break
}

$Remaining = $CurrentHours - $HoursServed

if ($Remaining -le 0) {
    # Detention is Over!
    Set-ADUser -Identity $Student -Clear "Office"
    
    # REVOKE ACCESS 
    Remove-ADGroupMember -Identity "Detention_Squad" -Members $Student -Confirm:$false -ErrorAction SilentlyContinue
    
    Write-Host " [FREEDOM]" -ForegroundColor Green
    Write-Host "   -> Hours cleared."
    Write-Host "   -> Removed from Detention_Squad."
}
else {
    # Detention Continues
    Set-ADUser -Identity $Student -Clear "physicalDeliveryOfficeName"
    Write-Host " [PARTIAL]" -ForegroundColor Yellow
    Write-Host "   -> Remaining: $Remaining hours"
}
