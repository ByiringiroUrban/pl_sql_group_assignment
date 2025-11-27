-- ============================================================
-- QUESTION 3 - PART 5: TEST SCRIPTS
-- Security Login Monitoring System
-- ============================================================
-- Run these scripts to test the security monitoring system
-- ============================================================

-- Enable DBMS_OUTPUT for testing
SET SERVEROUTPUT ON;

-- Clear previous test data (optional - uncomment if needed)
-- DELETE FROM security_alerts;
-- DELETE FROM login_audit;
-- COMMIT;

PROMPT ============================================================
PROMPT TEST CASE 1: User fails login once (should only be logged, no alert)
PROMPT ============================================================
INSERT INTO login_audit (username, status, ip_address) 
VALUES ('test_user', 'FAILED', '192.168.1.100');
COMMIT;

SELECT 'Login Audit Count: ' || COUNT(*) AS result FROM login_audit;
SELECT 'Security Alerts Count: ' || COUNT(*) AS result FROM security_alerts;

PROMPT ============================================================
PROMPT TEST CASE 2: Same user fails again (should only be logged, no alert)
PROMPT ============================================================
INSERT INTO login_audit (username, status, ip_address) 
VALUES ('test_user', 'FAILED', '192.168.1.100');
COMMIT;

SELECT 'Login Audit Count: ' || COUNT(*) AS result FROM login_audit;
SELECT 'Security Alerts Count: ' || COUNT(*) AS result FROM security_alerts;

PROMPT ============================================================
PROMPT TEST CASE 3: Same user fails third time (should trigger alert)
PROMPT ============================================================
INSERT INTO login_audit (username, status, ip_address) 
VALUES ('test_user', 'FAILED', '192.168.1.100');
COMMIT;

SELECT 'Login Audit Count: ' || COUNT(*) AS result FROM login_audit;
SELECT 'Security Alerts Count: ' || COUNT(*) AS result FROM security_alerts;

PROMPT ============================================================
PROMPT TEST CASE 4: Same user fails fourth time (should update existing alert)
PROMPT ============================================================
INSERT INTO login_audit (username, status, ip_address) 
VALUES ('test_user', 'FAILED', '192.168.1.100');
COMMIT;

SELECT 'Login Audit Count: ' || COUNT(*) AS result FROM login_audit;
SELECT 'Security Alerts Count: ' || COUNT(*) AS result FROM security_alerts;

PROMPT ============================================================
PROMPT TEST CASE 5: Successful login (should not trigger alert)
PROMPT ============================================================
INSERT INTO login_audit (username, status, ip_address) 
VALUES ('test_user', 'SUCCESS', '192.168.1.100');
COMMIT;

SELECT 'Login Audit Count: ' || COUNT(*) AS result FROM login_audit;
SELECT 'Security Alerts Count: ' || COUNT(*) AS result FROM security_alerts;

PROMPT ============================================================
PROMPT TEST CASE 6: Different user fails 3 times (should create separate alert)
PROMPT ============================================================
INSERT INTO login_audit (username, status, ip_address) 
VALUES ('another_user', 'FAILED', '192.168.1.101');
COMMIT;

INSERT INTO login_audit (username, status, ip_address) 
VALUES ('another_user', 'FAILED', '192.168.1.101');
COMMIT;

INSERT INTO login_audit (username, status, ip_address) 
VALUES ('another_user', 'FAILED', '192.168.1.101');
COMMIT;

PROMPT ============================================================
PROMPT VIEW ALL RESULTS
PROMPT ============================================================
PROMPT 
PROMPT --- Login Audit Records ---
SELECT * FROM login_audit ORDER BY attempt_time;

PROMPT 
PROMPT --- Security Alerts ---
SELECT * FROM security_alerts ORDER BY alert_time;

PROMPT 
PROMPT --- Test Helper Function ---
SELECT 'Failed attempts for test_user today: ' || 
       get_failed_attempts_count('test_user', TRUNC(SYSDATE)) AS result
FROM DUAL;

PROMPT 
PROMPT --- Test Resolve Alert Procedure ---
-- Uncomment to test resolving an alert
-- EXEC resolve_security_alert(1);

PROMPT ============================================================
PROMPT TESTING COMPLETE
PROMPT ============================================================

