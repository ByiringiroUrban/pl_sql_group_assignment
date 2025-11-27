-- ============================================================
-- QUESTION 4 - MASTER SCRIPT
-- Hospital Management Package with Bulk Processing
-- ============================================================
-- This script runs all components in the correct order
-- ============================================================

PROMPT ============================================================
PROMPT QUESTION 4 - Hospital Management Package with Bulk Processing
PROMPT Installing all components...
PROMPT ============================================================

PROMPT 
PROMPT Step 1/5: Creating patients table...
@01_create_patients_table.sql

PROMPT 
PROMPT Step 2/5: Creating doctors table...
@02_create_doctors_table.sql

PROMPT 
PROMPT Step 3/5: Creating package specification...
@03_create_package_specification.sql

PROMPT 
PROMPT Step 4/5: Creating package body...
@04_create_package_body.sql

PROMPT 
PROMPT Step 5/5: Running test scripts...
@05_test_scripts.sql

PROMPT 
PROMPT ============================================================
PROMPT Installation Complete!
PROMPT ============================================================
PROMPT All components have been installed successfully.
PROMPT Check the output above for any errors.
PROMPT ============================================================

