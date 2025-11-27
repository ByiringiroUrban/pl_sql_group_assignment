-- ============================================================
-- QUESTION 3 - MASTER SCRIPT
-- Security Login Monitoring System
-- ============================================================
-- This script runs all components in the correct order
-- ============================================================

PROMPT ============================================================
PROMPT QUESTION 3 - Security Login Monitoring System
PROMPT Installing all components...
PROMPT ============================================================

PROMPT 
PROMPT Step 1/5: Creating login_audit table...
@01_create_login_audit_table.sql

PROMPT 
PROMPT Step 2/5: Creating security_alerts table...
@02_create_security_alerts_table.sql

PROMPT 
PROMPT Step 3/5: Creating trigger...
@03_create_trigger.sql

PROMPT 
PROMPT Step 4/5: Creating procedures and functions...
@04_create_procedures.sql

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

