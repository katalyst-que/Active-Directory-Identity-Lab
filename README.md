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

### 1. The Onboarding Engine (`Onboarding-Provisioning.ps1`)
This script serves as the primary Identity Lifecycle Engine, transforming raw user data (CSV) into functional Active Directory objects. It goes beyond simple creation by implementing logic-based authorization:
* **Input:** Ingests a CSV file containing employee names and departments ("Houses").
* **Process:**
    * Generates a unique implementation of `SamAccountName`.
    * Creates a default password.
    * Provisions the user in Active Directory.
    * **Logic Check:** Automatically assigns the user to the correct Organizational Unit (OU) (e.g., `Gryffindor` -> `OU=Gryffindor,DC=hogwarts,DC=local`).
* **Dynamic RBAC (Role-Based Access Control):**
    * if ($Wizard.House -ne "None")
    * Automatically places users into Security Groups (e.g., Gryffindor_CommonRoom) based on their "House" attribute. This ensures baseline access is granted immediately upon onboarding.
* **Conditional Access (The "Hermione Rule"):**
    * if ($Wizard.Gender -eq "Female") { Add-Member ... }
    * Implements Attribute-Based Access Control (ABAC). The script evaluates multiple attributes (Role + House + Gender) to determine granular file permission scope. Female students receive dual-access tokens (Boys & Girls Dorms), while male students are restricted to single-access.
* **Privileged Access Management (The "Hagrid Rule")**
    * if ($Wizard.SpecialAccess -ne "None")
    * Handles Exception Management. It dynamically provisions elevated privileges (e.g., ForbiddenForest_Keys) for users with specific flags in their identity record, automating what is usually a manual ticket request process.

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
