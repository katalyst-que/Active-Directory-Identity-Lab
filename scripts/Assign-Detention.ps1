
# SCRIPT: Assign-Detention.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$StudentName,

    [Parameter(Mandatory=$true)]
    [int]$HoursAssigned
)

Write-Host "Searching for student: [$StudentName]" -ForegroundColor Cyan


try {
    # We use the 'Office' property to store detention hours
    $Student = Get-ADUser -Filter "SamAccountName -eq '$StudentName'" -Properties Office -ErrorAction Stop
    
    if (-not $Student) {
        Write-Warning "Student '$StudentName' returned null object."
        break
    }
}
catch {
    Write-Warning "SYSTEM ERROR: Could not find student."
    Write-Error $_.Exception.Message
    break
}


[int]$CurrentHours = 0
# Check if the Office field has a number in it
if ($Student.Office -and ($Student.Office -match '^\d+$')) {
    $CurrentHours = [int]$Student.Office
}
$NewBalance = $CurrentHours + $HoursAssigned

# Update the Record (Saving to the 'Office' field)
Set-ADUser -Identity $Student -Office "$NewBalance"

Add-ADGroupMember -Identity "Detention_Squad" -Members $Student -ErrorAction SilentlyContinue

Write-Host "---------------------------------------------" -ForegroundColor Yellow
Write-Host "DETENTION ASSIGNED BY HEADMASTER" -ForegroundColor Yellow
Write-Host "Student:  $($Student.Name)"
Write-Host "Added:    $HoursAssigned hours"
Write-Host "Total:    $NewBalance hours"
Write-Host "Location: Stored in 'Office' field"
Write-Host "Access:   GRANTED to Forbidden Forest" -ForegroundColor Red
Write-Host "---------------------------------------------"
