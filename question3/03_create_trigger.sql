-- ============================================================
-- QUESTION 3 - PART 3: CREATE TRIGGER
-- Security Login Monitoring System
-- ============================================================
-- This trigger monitors failed login attempts and creates security alerts
-- ============================================================

CREATE OR REPLACE TRIGGER trg_monitor_failed_logins
AFTER INSERT ON login_audit
FOR EACH ROW
WHEN (NEW.status = 'FAILED')
DECLARE
    v_failed_count NUMBER;
    v_existing_alert_id NUMBER;
    v_alert_message VARCHAR2(500);
BEGIN
    -- Count failed attempts for this user on the same day
    SELECT COUNT(*)
    INTO v_failed_count
    FROM login_audit
    WHERE username = :NEW.username
      AND status = 'FAILED'
      AND TRUNC(attempt_time) = TRUNC(:NEW.attempt_time);
    
    -- Check if failed attempts exceed 2 (i.e., >= 3)
    IF v_failed_count > 2 THEN
        -- Check if an alert already exists for this user today
        BEGIN
            SELECT alert_id
            INTO v_existing_alert_id
            FROM security_alerts
            WHERE username = :NEW.username
              AND TRUNC(alert_time) = TRUNC(:NEW.attempt_time)
              AND resolved = 'N'
            FETCH FIRST 1 ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_existing_alert_id := NULL;
        END;
        
        -- If no existing alert, create a new one
        IF v_existing_alert_id IS NULL THEN
            v_alert_message := 'Security Alert: User ' || :NEW.username || 
                             ' has made ' || v_failed_count || 
                             ' failed login attempts on ' || 
                             TO_CHAR(:NEW.attempt_time, 'YYYY-MM-DD HH24:MI:SS');
            
            INSERT INTO security_alerts (
                username,
                failed_attempts,
                alert_time,
                alert_message,
                contact_email
            ) VALUES (
                :NEW.username,
                v_failed_count,
                :NEW.attempt_time,
                v_alert_message,
                'security@organization.com'  -- Default security team email
            );
            
            -- Optional: Log the alert creation
            DBMS_OUTPUT.PUT_LINE('Security Alert Created for user: ' || :NEW.username);
        ELSE
            -- Update existing alert with new count
            UPDATE security_alerts
            SET failed_attempts = v_failed_count,
                alert_message = 'Security Alert: User ' || :NEW.username || 
                              ' has made ' || v_failed_count || 
                              ' failed login attempts on ' || 
                              TO_CHAR(:NEW.attempt_time, 'YYYY-MM-DD HH24:MI:SS'),
                alert_time = :NEW.attempt_time
            WHERE alert_id = v_existing_alert_id;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the transaction
        DBMS_OUTPUT.PUT_LINE('Error in trigger: ' || SQLERRM);
        -- Don't raise to avoid blocking the login_audit insert
END;
/

-- Add comment to trigger
COMMENT ON TRIGGER trg_monitor_failed_logins IS 
    'Monitors failed login attempts and creates security alerts when a user exceeds 2 failed attempts in the same day';

