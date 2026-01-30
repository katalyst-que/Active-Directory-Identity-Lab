# Automated Identity Lifecycle System (The "Hogwarts" Lab)
### Identity & Access Management (IAM) | PowerShell | Azure

![Status](https://img.shields.io/badge/Status-Complete-success) ![Platform](https://img.shields.io/badge/Platform-Windows_Server_2022-blue) ![Tools](https://img.shields.io/badge/Tools-PowerShell_Active_Directory-blue)

## Table of Contents
- [Project Overview](#project-overview)
- [Architecture & Logic](#architecture--logic)
- [The Scripts (Automated Workflows)](#-the-scripts-automated-workflows)
- [Implementation & Verification](#implementation--verification)
- [Skills Demonstrated](#%EF%B8%8F-skills-demonstrated)

## Project Overview
This project uses the Hogwarts ecosystem as a conceptual framework to demonstrate complex enterprise Identity & Access Management (IAM) challenges. By mapping "Houses" to Departments and "Dorms" to secure resources, we model real-world scenarios where access must be strictly segmented.

The core engineering challenge focuses on dynamic security postures. In this lab, the "Forbidden Forest" represents a high-risk, restricted resource. Access to this zone is not static; it is granted dynamically through a "Detention" protocol. This simulates **Just-In-Time (JIT)** access, where a user's behavior (getting detention) triggers a temporary change in security group membership, granting them necessary access to perform specific tasks before automatically revoking it upon completion.

**Key Engineering Goals:**
* **Automation:** Replace manual data entry with bulk ingestion from structured HR data files.
* **Security:** Enforce Least Privilege using attribute-based access control (ABAC).
* **Self-Healing:** A scripted remediation engine that automatically identifies task completion and revokes unauthorized access without human intervention.

---

## Architecture & Logic

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Domain Controller** | Windows Server 2022 | The heart of the identity infrastructure (AD DS, DNS). |
| **Cloud Hosting** | Microsoft Azure | Hosted in a custom Resource Group with restricted Network Security Groups. |
| **The "Sorting Hat"** | PowerShell Script | Reads CSV data and assigns users to the correct OU and Security Groups. |
| **"Detention" Logic** | Scheduled Task | A security script that modifies user attributes to trigger dynamic access changes. |

---

## ⚡ The Scripts (Automated Workflows)

### 1. The Onboarding Engine (`Onboarding-Provisioning.ps1`)
This script serves as the primary Identity Lifecycle Engine. It transforms raw user data (CSV) into functional Active Directory objects, implementing logic-based authorization rather than simple creation.
* **Dynamic RBAC:** Automatically places users into Security Groups (e.g., *Gryffindor_CommonRoom*) based on their "House" attribute. This ensures baseline access is granted immediately upon onboarding.
* **Conditional Access (The "Hermione Rule"):** Implements Attribute-Based Access Control (ABAC). The script evaluates multiple attributes (Role + House + Gender) to determine granular file permission scope. For example, female students receive dual-access tokens (Boys & Girls Dorms), while male students are restricted to single-access.
* **Privileged Access Management (The "Hagrid Rule"):** Handles Exception Management. It dynamically provisions elevated privileges (e.g., *ForbiddenForest_Keys*) for users with specific flags in their identity record, automating what is usually a manual ticket request process.

### 2. The "Detention" Enforcement Engine (`Assign-Detention.ps1`)
This script demonstrates **Dynamic Access Control** by modifying user attributes to trigger security changes. It repurposes a standard Active Directory attribute (*OfficePhone*) to store a custom integer value representing "Detention Hours."
* **Attribute Modification:** Instead of manually adding a user to a group, the script modifies the identity object itself to reflect a new status.
* **Policy Enforcement:** By adding the user to the *Detention_Squad* group, the script dynamically changes the user's effective permissions. In this lab, this **grants** access to the Forbidden Forest (to serve detention), simulating a workflow where a user is temporarily elevated to access a restricted zone for a specific job.

### 3. The "Detention Completion" Check (`Log-Service.ps1`)
This script handles the "Return to Standard" phase of the lifecycle, proving that security controls can be dynamic and self-correcting.
* **Automated Deprovisioning:** The script monitors the "Hours" attribute. When the risk is remediated (balance reaches zero), the system automatically revokes the *Detention_Squad* membership.
* **Self-Healing State:** The system automatically corrects the user's access level back to baseline without human intervention, reducing "Ticket Fatigue" for IT staff.

---

## Implementation & Verification

The following workflow demonstrates the execution of the Just-In-Time (JIT) access policies using Draco Malfoy as the test subject.

### 1. Baseline Access Verification
We verify the user's starting state. The screenshot confirms Draco is a member of his House (`Slytherin_CommonRoom`) but is **not** a member of the restricted `Detention_Squad`.
![Baseline Access](./images/1_baseline.png)

### 2. Policy Enforcement (The "Detention" Trigger)
We execute the `Assign-Detention.ps1` script. The output highlights the **Attribute-Based Access Control (ABAC)** logic in action: the script updates the "Office" attribute and immediately flags the user for "GRANTED" access to the Forbidden Forest.
![Policy Enforcement](./images/2_trigger.png)

### 3. JIT Access Grant (Group Membership)
A check of the user object confirms the immediate security posture change. Draco has been dynamically added to `CN=Detention_Squad`, which inherits the necessary Read/Write ACLs for the restricted folder.
![Access Grant](./images/3_access_proof.png)

### 4. Remediation Cycle (The "Log-Service")
We execute `Log-Service.ps1` to simulate the user performing their required tasks. The screenshot demonstrates the **Self-Healing logic**:
* **First Run:** The system detects 10 total hours, logs 5, and calculates a remaining balance (Status: `[PARTIAL]`).
* **Second Run:** Once the balance hits zero, the script clears the record.
![Remediation](./images/4_remediation.png)

### 5. Automated Revocation
A final audit of the user object confirms the loop is closed. The system has automatically removed Draco from the `Detention_Squad`, returning him strictly to his baseline permissions without manual admin intervention.
![Revocation](./images/5_clean_state.png)

---

## 🛡️ Skills Demonstrated
* **PowerShell Scripting:** Loops, Variables, CSV Parsing, AD Modules.
* **Identity Management:** OU Design, GPO Application, RBAC.
* **Security Engineering:** Automating defensive responses to user behavior.
