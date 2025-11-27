-- ============================================================
-- QUESTION 3 - PART 4: CREATE PROCEDURES AND FUNCTIONS
-- Security Login Monitoring System
-- ============================================================

-- ============================================================
-- Procedure to send email notification
-- ============================================================
CREATE OR REPLACE PROCEDURE send_security_alert_email (
    p_alert_id IN NUMBER
)
IS
    v_alert_rec security_alerts%ROWTYPE;
    v_email_subject VARCHAR2(200);
    v_email_body VARCHAR2(1000);
BEGIN
    -- Retrieve alert information
    SELECT * INTO v_alert_rec
    FROM security_alerts
    WHERE alert_id = p_alert_id;
    
    -- Prepare email content
    v_email_subject := 'Security Alert: Multiple Failed Login Attempts';
    v_email_body := 'Dear Security Team,' || CHR(10) || CHR(10) ||
                   'A security alert has been triggered:' || CHR(10) ||
                   'Username: ' || v_alert_rec.username || CHR(10) ||
                   'Failed Attempts: ' || v_alert_rec.failed_attempts || CHR(10) ||
                   'Alert Time: ' || TO_CHAR(v_alert_rec.alert_time, 'YYYY-MM-DD HH24:MI:SS') || CHR(10) ||
                   'Message: ' || v_alert_rec.alert_message || CHR(10) || CHR(10) ||
                   'Please investigate this incident immediately.';
    
    -- Send email using UTL_MAIL (requires proper configuration)
    -- Note: This requires Oracle UTL_MAIL package to be configured
    -- Alternative: Use UTL_SMTP or external email service
    
    -- Example using UTL_MAIL (uncomment if configured):
    /*
    UTL_MAIL.SEND(
        sender => 'noreply@organization.com',
        recipients => NVL(v_alert_rec.contact_email, 'security@organization.com'),
        subject => v_email_subject,
        message => v_email_body
    );
    */
    
    -- For demonstration, we'll use DBMS_OUTPUT
    DBMS_OUTPUT.PUT_LINE('Email would be sent to: ' || 
                        NVL(v_alert_rec.contact_email, 'security@organization.com'));
    DBMS_OUTPUT.PUT_LINE('Subject: ' || v_email_subject);
    DBMS_OUTPUT.PUT_LINE('Body: ' || v_email_body);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Alert ID ' || p_alert_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error sending email: ' || SQLERRM);
        RAISE;
END;
/

-- ============================================================
-- Trigger to automatically send email on alert creation
-- ============================================================
CREATE OR REPLACE TRIGGER trg_send_security_alert_email
AFTER INSERT ON security_alerts
FOR EACH ROW
BEGIN
    -- Automatically send email notification when alert is created
    send_security_alert_email(:NEW.alert_id);
EXCEPTION
    WHEN OTHERS THEN
        -- Don't fail the transaction if email fails
        DBMS_OUTPUT.PUT_LINE('Warning: Could not send email notification: ' || SQLERRM);
END;
/

-- ============================================================
-- Procedure to resolve an alert
-- ============================================================
CREATE OR REPLACE PROCEDURE resolve_security_alert (
    p_alert_id IN NUMBER
)
IS
BEGIN
    UPDATE security_alerts
    SET resolved = 'Y'
    WHERE alert_id = p_alert_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Alert ID ' || p_alert_id || ' not found.');
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Alert ' || p_alert_id || ' has been resolved.');
END;
/

-- ============================================================
-- Function to get failed attempts count for a user on a specific date
-- ============================================================
CREATE OR REPLACE FUNCTION get_failed_attempts_count (
    p_username IN VARCHAR2,
    p_date IN DATE DEFAULT TRUNC(SYSDATE)
) RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM login_audit
    WHERE username = p_username
      AND status = 'FAILED'
      AND TRUNC(attempt_time) = TRUNC(p_date);
    
    RETURN v_count;
END;
/

-- Add comments
COMMENT ON PROCEDURE send_security_alert_email IS 
    'Sends email notification for a security alert (requires UTL_MAIL configuration)';
COMMENT ON TRIGGER trg_send_security_alert_email IS 
    'Automatically sends email when a new security alert is created';
COMMENT ON PROCEDURE resolve_security_alert IS 
    'Marks a security alert as resolved';
COMMENT ON FUNCTION get_failed_attempts_count IS 
    'Returns the count of failed login attempts for a user on a specific date';

