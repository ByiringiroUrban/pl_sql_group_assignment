# Question 4 - Hospital Management Package with Bulk Processing

## Overview
This directory contains the complete solution for Question 4, which implements a PL/SQL package for hospital management with bulk processing capabilities.

## Files Structure

### 1. `01_create_patients_table.sql`
- Creates the `patients` table
- Stores patient information (ID, name, age, gender, admitted status)
- Includes indexes, constraints, and comments
- **Run this first**

### 2. `02_create_doctors_table.sql`
- Creates the `doctors` table
- Stores doctor information (ID, name, specialty)
- Includes indexes and comments
- **Run this second**

### 3. `03_create_package_specification.sql`
- Creates the package specification `hospital_mgmt_pkg`
- Defines collection type for bulk processing
- Declares all procedures and functions
- **Run this third**

### 4. `04_create_package_body.sql`
- Creates the package body `hospital_mgmt_pkg`
- Implements all procedures and functions
- Uses FORALL for efficient bulk insertion
- Includes proper commit handling
- **Run this fourth**

### 5. `05_test_scripts.sql`
- Comprehensive test scripts
- Tests all procedures and functions
- Demonstrates bulk loading, displaying, counting, and admitting patients
- **Run this last** to verify everything works

### 6. `00_run_all.sql`
- Master script that runs all files in correct order

## Installation Order

Execute the files in this exact order:

```sql
-- Step 1: Create tables
@01_create_patients_table.sql
@02_create_doctors_table.sql

-- Step 2: Create package specification
@03_create_package_specification.sql

-- Step 3: Create package body
@04_create_package_body.sql

-- Step 4: Test the system
@05_test_scripts.sql
```

Or run all at once:
```sql
@00_run_all.sql
```

## Package Components

### Collection Type
- `patient_rec_type` - Record type for patient data
- `patient_tab_type` - Table type for bulk processing

### Procedures

1. **`bulk_load_patients(p_patients)`**
   - Inserts multiple patient records at once
   - Uses FORALL for efficient bulk processing
   - Commits transaction after successful insertion

2. **`admit_patient(p_patient_id)`**
   - Updates patient status to admitted
   - Sets admission date to current date
   - Commits transaction

3. **`discharge_patient(p_patient_id)`**
   - Updates patient status to discharged
   - Sets discharge date to current date
   - Commits transaction

4. **`add_doctor(p_doctor_name, p_specialty, p_phone_number, p_email)`**
   - Adds a new doctor to the system
   - Commits transaction

### Functions

1. **`show_all_patients RETURN SYS_REFCURSOR`**
   - Returns a cursor with all patient information
   - Ordered by patient_id

2. **`count_admitted RETURN NUMBER`**
   - Returns the number of currently admitted patients
   - Counts patients with status 'YES' or 'Y'

3. **`get_patient_details(p_patient_id) RETURN SYS_REFCURSOR`**
   - Returns patient details by ID
   - Returns cursor with patient information

## Tables Description

### patients
Stores patient information for the hospital management system.
- `patient_id` - Primary key (auto-generated)
- `patient_name` - Full name of the patient
- `age` - Age (1-150)
- `gender` - M, F, Male, Female, or Other
- `admitted_status` - YES/NO or Y/N
- `admission_date` - Date when admitted
- `discharge_date` - Date when discharged
- `created_date` - Timestamp when record was created

### doctors
Stores doctor information.
- `doctor_id` - Primary key (auto-generated)
- `doctor_name` - Full name of the doctor
- `specialty` - Medical specialty
- `phone_number` - Contact phone
- `email` - Contact email
- `created_date` - Timestamp when record was created

## Key Features

### Bulk Processing
- Uses `FORALL` for efficient bulk insertion
- Processes multiple records in a single operation
- Reduces database round trips

### Transaction Management
- Proper use of COMMIT after successful operations
- ROLLBACK on errors
- Data consistency maintained

### Error Handling
- Comprehensive exception handling
- User-friendly error messages
- Transaction safety

## Usage Examples

### Bulk Load Patients
```sql
DECLARE
    v_patients hospital_mgmt_pkg.patient_tab_type;
BEGIN
    v_patients := hospital_mgmt_pkg.patient_tab_type();
    v_patients.EXTEND(3);
    
    v_patients(1) := hospital_mgmt_pkg.patient_rec_type(
        'John Doe', 45, 'M', 'NO'
    );
    -- Add more patients...
    
    hospital_mgmt_pkg.bulk_load_patients(v_patients);
END;
/
```

### Show All Patients
```sql
DECLARE
    v_cursor SYS_REFCURSOR;
    v_patient_id NUMBER;
    v_patient_name VARCHAR2(100);
    -- other variables...
BEGIN
    v_cursor := hospital_mgmt_pkg.show_all_patients;
    -- Fetch and display...
END;
/
```

### Count Admitted Patients
```sql
SELECT hospital_mgmt_pkg.count_admitted FROM DUAL;
```

### Admit a Patient
```sql
EXEC hospital_mgmt_pkg.admit_patient(1);
```

## Expected Outcomes

✅ **Bulk Insertion**: Efficiently inserts multiple patients using FORALL  
✅ **Patient Display**: Function returns cursor with all patient information  
✅ **Admission Tracking**: Correctly counts and updates admitted patients  
✅ **Status Updates**: Properly updates patient admission status  
✅ **Transaction Safety**: All operations properly committed or rolled back  

## Notes

- FORALL is used for bulk processing to improve performance
- All procedures use appropriate COMMIT statements
- Error handling ensures data consistency
- Collection type allows flexible bulk operations
- Cursor-based functions provide efficient data retrieval

## Troubleshooting

If you encounter errors:
1. Make sure tables are created before package specification
2. Package specification must be created before package body
3. Check that all dependencies exist
4. Verify you have necessary privileges (CREATE TABLE, CREATE PACKAGE, etc.)
5. Ensure Oracle version supports IDENTITY columns (12c+)

