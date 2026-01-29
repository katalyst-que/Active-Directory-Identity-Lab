# Active-Directory-Identity-Lab
An automated Identity Lifecycle Management system built with PowerShell and Azure, featuring Just-In-Time (JIT) access and self-healing security.
# Automated Identity Lifecycle System (The "Hogwarts" Lab)
### Identity & Access Management (IAM) | PowerShell | Azure

![Status](https://img.shields.io/badge/Status-Complete-success) ![Platform](https://img.shields.io/badge/Platform-Windows_Server_2022-blue) ![Tools](https://img.shields.io/badge/Tools-PowerShell_Active_Directory-blue)

## Project Overview
This project simulates a real-world enterprise Identity environment for a fictional organization ("Hogwarts"). The goal was to eliminate manual administration by building a **scripted, automated lifecycle engine** that handles user onboarding, group assignment, and security enforcement without human intervention.

**Key Engineering Goals:**
* **Automation:** Replace "Right-click > New User" with bulk ingestion from HR data.
* **Security:** Enforce Least Privilege using attribute-based access control.
* **Self-Healing:** A "Detention" mechanism that automatically identifies and revokes unauthorized access.

---

## Architecture & Logic

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Domain Controller** | Windows Server 2022 | The heart of the identity infrastructure (AD DS, DNS). |
| **Cloud Hosting** | Microsoft Azure | Hosted specifically in a custom Resource Group with restricted NSGs. |
| **The "Sorting Hat"** | PowerShell Script | Reads CSV data (Name, House) and assigns users to the correct OU and Security Groups. |
| **"Detention" Logic** | Scheduled Task | A security script that scans for restricted users and moves them to a locked-down OU. |

---

## ⚡ The Scripts (Automated Workflows)

### 1. The Onboarding Engine (`Onboard-Users.ps1`)
This script acts as the bridge between "HR Data" and "IT Infrastructure."
* **Input:** Ingests a CSV file containing employee names and departments ("Houses").
* **Process:**
    * Generates a unique implementation of `SamAccountName`.
    * Creates a random, high-complexity password.
    * Provisions the user in Active Directory.
    * **Logic Check:** Automatically assigns the user to the correct Organizational Unit (OU) (e.g., `Gryffindor` -> `OU=Gryffindor,DC=hogwarts,DC=local`).

### 2. The "Detention" Security Bot (`Security-Sweep.ps1`)
This is a **Just-In-Time (JIT)** access control simulation.
* **The Trigger:** Monitors user attributes for "Rule Breaking" flags (simulated by specific Description tags or Group memberships).
* **The Action:**
    * Detects the target user.
    * **Revokes** current group memberships.
    * **Moves** the user object to the `Detention` OU (a locked-down container with Deny-All GPOs).
    * **Logs** the incident for audit.

---

## Implementation Steps

1.  **Infrastructure Deploy:**
    * Provisioned Azure VM (Standard_B2s) as the Domain Controller.
    * Promoted server to DC and configured DNS.
2.  **Code Execution:**
    ```powershell
    # Example snippet of the onboarding loop
    foreach ($user in $users) {
        if ($user.House -eq "Slytherin") {
            New-ADUser -Name $user.Name -Path "OU=Slytherin,DC=hogwarts,DC=local" ...
        }
    }
    ```
3.  **Verification:**
    * Successfully onboarded all users in <2 minutes.
    * Verified "Detention" script successfully isolated compromised accounts during testing.

---

## 🛡️ Skills Demonstrated
* **PowerShell Scripting:** Loops, Variables, CSV Parsing, AD Modules.
* **Identity Management:** OU Design, GPO Application, RBAC.
* **Security Engineering:** Automating defensive responses to user behavior.
