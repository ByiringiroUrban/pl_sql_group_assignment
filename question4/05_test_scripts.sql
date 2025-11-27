-- ============================================================
-- QUESTION 4 - PART 5: TEST SCRIPTS
-- Hospital Management Package with Bulk Processing
-- ============================================================
-- Comprehensive test scripts for all package procedures and functions
-- ============================================================

SET SERVEROUTPUT ON;

PROMPT ============================================================
PROMPT QUESTION 4 - Hospital Management Package Testing
PROMPT ============================================================

-- Clear previous test data (optional - uncomment if needed)
-- DELETE FROM patients;
-- DELETE FROM doctors;
-- COMMIT;

PROMPT 
PROMPT ============================================================
PROMPT TEST 1: Bulk Load Patients using bulk_load_patients procedure
PROMPT ============================================================
DECLARE
    v_patients hospital_mgmt_pkg.patient_tab_type;
BEGIN
    -- Initialize collection
    v_patients := hospital_mgmt_pkg.patient_tab_type();
    
    -- Add multiple patients to the collection
    v_patients.EXTEND(5);
    
    v_patients(1) := hospital_mgmt_pkg.patient_rec_type(
        patient_name => 'John Smith',
        age => 45,
        gender => 'M',
        admitted_status => 'NO'
    );
    
    v_patients(2) := hospital_mgmt_pkg.patient_rec_type(
        patient_name => 'Mary Johnson',
        age => 32,
        gender => 'F',
        admitted_status => 'YES'
    );
    
    v_patients(3) := hospital_mgmt_pkg.patient_rec_type(
        patient_name => 'Robert Williams',
        age => 58,
        gender => 'Male',
        admitted_status => 'NO'
    );
    
    v_patients(4) := hospital_mgmt_pkg.patient_rec_type(
        patient_name => 'Sarah Davis',
        age => 28,
        gender => 'Female',
        admitted_status => 'NO'
    );
    
    v_patients(5) := hospital_mgmt_pkg.patient_rec_type(
        patient_name => 'Michael Brown',
        age => 65,
        gender => 'M',
        admitted_status => 'YES'
    );
    
    -- Call bulk_load_patients procedure
    hospital_mgmt_pkg.bulk_load_patients(v_patients);
    
    DBMS_OUTPUT.PUT_LINE('Bulk load completed successfully!');
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 2: Display all patients using show_all_patients function
PROMPT ============================================================
DECLARE
    v_cursor SYS_REFCURSOR;
    v_patient_id NUMBER;
    v_patient_name VARCHAR2(100);
    v_age NUMBER;
    v_gender VARCHAR2(10);
    v_admitted_status VARCHAR2(10);
    v_admission_date DATE;
    v_discharge_date DATE;
    v_created_date TIMESTAMP;
BEGIN
    v_cursor := hospital_mgmt_pkg.show_all_patients;
    
    DBMS_OUTPUT.PUT_LINE('--- All Patients ---');
    DBMS_OUTPUT.PUT_LINE(RPAD('ID', 8) || RPAD('Name', 25) || RPAD('Age', 6) || 
                         RPAD('Gender', 10) || RPAD('Status', 10) || 'Admission Date');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    
    LOOP
        FETCH v_cursor INTO 
            v_patient_id, v_patient_name, v_age, v_gender, 
            v_admitted_status, v_admission_date, v_discharge_date, v_created_date;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(TO_CHAR(v_patient_id), 8) || 
            RPAD(v_patient_name, 25) || 
            RPAD(TO_CHAR(v_age), 6) || 
            RPAD(v_gender, 10) || 
            RPAD(v_admitted_status, 10) || 
            TO_CHAR(NVL(v_admission_date, 'N/A'))
        );
    END LOOP;
    
    CLOSE v_cursor;
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 3: Count admitted patients using count_admitted function
PROMPT ============================================================
DECLARE
    v_admitted_count NUMBER;
BEGIN
    v_admitted_count := hospital_mgmt_pkg.count_admitted;
    DBMS_OUTPUT.PUT_LINE('Number of currently admitted patients: ' || v_admitted_count);
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 4: Admit a patient using admit_patient procedure
PROMPT ============================================================
DECLARE
    v_before_count NUMBER;
    v_after_count NUMBER;
    v_patient_id NUMBER := 1; -- Assuming patient_id 1 exists
BEGIN
    -- Get count before admission
    v_before_count := hospital_mgmt_pkg.count_admitted;
    DBMS_OUTPUT.PUT_LINE('Admitted patients before: ' || v_before_count);
    
    -- Admit patient
    hospital_mgmt_pkg.admit_patient(v_patient_id);
    
    -- Get count after admission
    v_after_count := hospital_mgmt_pkg.count_admitted;
    DBMS_OUTPUT.PUT_LINE('Admitted patients after: ' || v_after_count);
    
    IF v_after_count > v_before_count THEN
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Patient admission verified!');
    END IF;
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 5: Verify count_admitted after admission
PROMPT ============================================================
DECLARE
    v_admitted_count NUMBER;
BEGIN
    v_admitted_count := hospital_mgmt_pkg.count_admitted;
    DBMS_OUTPUT.PUT_LINE('Current admitted patients count: ' || v_admitted_count);
    
    -- Show admitted patients
    FOR rec IN (
        SELECT patient_id, patient_name, admission_date
        FROM patients
        WHERE UPPER(admitted_status) IN ('YES', 'Y')
        ORDER BY admission_date DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - Patient ID: ' || rec.patient_id || 
                           ', Name: ' || rec.patient_name ||
                           ', Admitted: ' || TO_CHAR(rec.admission_date, 'YYYY-MM-DD'));
    END LOOP;
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 6: Discharge a patient
PROMPT ============================================================
DECLARE
    v_patient_id NUMBER := 2; -- Assuming patient_id 2 is admitted
BEGIN
    DBMS_OUTPUT.PUT_LINE('Discharging patient ID: ' || v_patient_id);
    hospital_mgmt_pkg.discharge_patient(v_patient_id);
    
    DBMS_OUTPUT.PUT_LINE('Current admitted count: ' || hospital_mgmt_pkg.count_admitted);
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 7: Get patient details by ID
PROMPT ============================================================
DECLARE
    v_cursor SYS_REFCURSOR;
    v_patient_id NUMBER;
    v_patient_name VARCHAR2(100);
    v_age NUMBER;
    v_gender VARCHAR2(10);
    v_admitted_status VARCHAR2(10);
    v_admission_date DATE;
    v_discharge_date DATE;
    v_created_date TIMESTAMP;
BEGIN
    v_cursor := hospital_mgmt_pkg.get_patient_details(1);
    
    FETCH v_cursor INTO 
        v_patient_id, v_patient_name, v_age, v_gender, 
        v_admitted_status, v_admission_date, v_discharge_date, v_created_date;
    
    IF v_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('--- Patient Details ---');
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_patient_id);
        DBMS_OUTPUT.PUT_LINE('Name: ' || v_patient_name);
        DBMS_OUTPUT.PUT_LINE('Age: ' || v_age);
        DBMS_OUTPUT.PUT_LINE('Gender: ' || v_gender);
        DBMS_OUTPUT.PUT_LINE('Admitted: ' || v_admitted_status);
        DBMS_OUTPUT.PUT_LINE('Admission Date: ' || TO_CHAR(NVL(v_admission_date, 'N/A')));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Patient not found');
    END IF;
    
    CLOSE v_cursor;
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 8: Add doctors using add_doctor procedure
PROMPT ============================================================
BEGIN
    hospital_mgmt_pkg.add_doctor('Dr. James Wilson', 'Cardiology', '555-0101', 'jwilson@hospital.com');
    hospital_mgmt_pkg.add_doctor('Dr. Emily Chen', 'Pediatrics', '555-0102', 'echen@hospital.com');
    hospital_mgmt_pkg.add_doctor('Dr. David Lee', 'Surgery', '555-0103', 'dlee@hospital.com');
    
    DBMS_OUTPUT.PUT_LINE('Doctors added successfully');
END;
/

PROMPT 
PROMPT ============================================================
PROMPT TEST 9: View all doctors
PROMPT ============================================================
SELECT 
    doctor_id,
    doctor_name,
    specialty,
    phone_number,
    email
FROM doctors
ORDER BY doctor_id;

PROMPT 
PROMPT ============================================================
PROMPT TEST 10: Final Summary
PROMPT ============================================================
SELECT 
    'Total Patients' AS metric,
    COUNT(*) AS value
FROM patients
UNION ALL
SELECT 
    'Admitted Patients',
    COUNT(*)
FROM patients
WHERE UPPER(admitted_status) IN ('YES', 'Y')
UNION ALL
SELECT 
    'Total Doctors',
    COUNT(*)
FROM doctors;

PROMPT 
PROMPT ============================================================
PROMPT TESTING COMPLETE
PROMPT ============================================================

