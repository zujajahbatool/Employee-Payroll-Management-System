# Employee Payroll Management System
### Built with Oracle PL/SQL | Oracle SQL Developer

---

## Project Overview
A fully functional payroll management system built using Oracle PL/SQL,
demonstrating core database programming concepts applicable to real-world
enterprise environments.

---

## Features
- Auto-generates realistic employee data using `DBMS_RANDOM` and PL/SQL collections
- Calculates monthly payroll with role-based bonus logic
- Automatically logs every salary change via a `BEFORE UPDATE` trigger
- All modules bundled into an organized PL/SQL package

---

## Concepts Covered

| Concept | Implementation |
|---|---|
| Block Structure | All scripts |
| Variables & %TYPE | Data generator, procedures |
| Stored Procedures | `add_employee`, `process_monthly_payroll` |
| Functions | `calculate_bonus`, `get_total_payout` |
| Cursors | Payroll processing, report generation |
| Triggers | `trg_salary_audit` — auto audit on salary change |
| Exception Handling | All modules |
| Packages | `payroll_pkg` — bundles all components |
| BULK COLLECT | Dynamic dept ID loading in data generator |

---

## How to Run

1. Open Oracle SQL Developer and connect to your schema
2. Run scripts in order: `01_` → `02_` → ... → `08_`
3. Enable DBMS Output: **View → Dbms Output → Click +**
4. Execute the test script to see output

---

## Database Schema

**departments** → **employees** → **payroll**
                                ↘ **salary_audit** (via trigger)

---

## Environment
- Oracle Database (XE / 19c / 21c)
- Oracle SQL Developer
- PL/SQL
