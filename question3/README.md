# Question 3 - Security Login Monitoring System

## Overview
This directory contains the complete solution for Question 3, separated into individual files for better organization and maintenance.

## Files Structure

### 1. `01_create_login_audit_table.sql`
- Creates the `login_audit` table
- Stores all login attempts (both successful and failed)
- Includes indexes and constraints
- **Run this first**

### 2. `02_create_security_alerts_table.sql`
- Creates the `security_alerts` table
- Stores security alerts when users exceed failed login attempts
- Includes indexes and constraints
- **Run this second**

### 3. `03_create_trigger.sql`
- Creates the trigger `trg_monitor_failed_logins`
- Monitors failed login attempts and creates security alerts
- **Run this third** (requires both tables to exist)

### 4. `04_create_procedures.sql`
- Creates helper procedures and functions:
  - `send_security_alert_email` - Sends email notifications
  - `resolve_security_alert` - Marks alerts as resolved
  - `get_failed_attempts_count` - Query function for failed attempts
- Creates trigger for automatic email notifications
- **Run this fourth** (optional but recommended)

### 5. `05_test_scripts.sql`
- Contains comprehensive test cases
- Tests all scenarios (1, 2, 3, 4+ failed attempts)
- Tests successful logins
- Tests different users
- **Run this last** to verify everything works

## Installation Order

Execute the files in this exact order:

```sql
-- Step 1: Create tables
@01_create_login_audit_table.sql
@02_create_security_alerts_table.sql

-- Step 2: Create trigger
@03_create_trigger.sql

-- Step 3: Create procedures (optional)
@04_create_procedures.sql

-- Step 4: Test the system
@05_test_scripts.sql
```

Or run all at once:
```sql
@01_create_login_audit_table.sql
@02_create_security_alerts_table.sql
@03_create_trigger.sql
@04_create_procedures.sql
@05_test_scripts.sql
```

## How It Works

1. **Application inserts login attempts** into `login_audit` table
2. **Trigger fires automatically** after each INSERT
3. **Trigger checks** if status = 'FAILED'
4. **Trigger counts** failed attempts for same user on same day
5. **If count > 2**, trigger creates/updates alert in `security_alerts`
6. **Email notification** (optional) is sent automatically

## Expected Behavior

- ✅ **1-2 failed attempts**: Only logged in `login_audit`, no alert
- ✅ **3+ failed attempts**: Logged in `login_audit` AND alert created in `security_alerts`
- ✅ **Multiple failures same day**: Alert updated with latest count
- ✅ **Successful login**: Only logged, no alert triggered
- ✅ **Different days**: Each day's attempts counted separately

## Tables Description

### login_audit
Stores all login attempts for auditing purposes.
- `audit_id` - Primary key
- `username` - User who attempted login
- `attempt_time` - When the attempt occurred
- `status` - SUCCESS or FAILED
- `ip_address` - IP address (optional)
- `device_info` - Device information (optional)

### security_alerts
Stores security alerts when users exceed failed login attempts.
- `alert_id` - Primary key
- `username` - User that triggered alert
- `failed_attempts` - Number of failed attempts
- `alert_time` - When alert was created
- `alert_message` - Detailed message
- `contact_email` - Email for notification
- `resolved` - Y/N status

## Notes

- Email functionality requires Oracle UTL_MAIL or UTL_SMTP configuration
- For production, consider adding more fields (session_id, user_agent, etc.)
- Consider adding a cleanup job to archive old audit records
- May want to add rate limiting or account lockout features

## Troubleshooting

If you encounter errors:
1. Make sure tables are created in order
2. Check that all dependencies exist before creating triggers/procedures
3. Verify you have necessary privileges (CREATE TABLE, CREATE TRIGGER, etc.)
4. Check Oracle version compatibility (IDENTITY columns require Oracle 12c+)

