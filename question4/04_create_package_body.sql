-- ============================================================
-- QUESTION 4 - PART 4: CREATE PACKAGE BODY
-- Hospital Management Package with Bulk Processing
-- ============================================================
-- Package Body: hospital_mgmt_pkg
-- ============================================================

CREATE OR REPLACE PACKAGE BODY hospital_mgmt_pkg
IS
    -- ============================================================
    -- Procedure: bulk_load_patients
    -- Uses FORALL for efficient bulk insertion
    -- ============================================================
    PROCEDURE bulk_load_patients (
        p_patients IN patient_tab_type
    )
    IS
        -- Counter for successful inserts
        v_inserted_count NUMBER := 0;
    BEGIN
        -- Validate input collection
        IF p_patients IS NULL OR p_patients.COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Patient collection is empty or null');
        END IF;
        
        -- Use FORALL for bulk insertion - directly using the input collection
        FORALL i IN 1 .. p_patients.COUNT
            INSERT INTO patients (
                patient_name,
                age,
                gender,
                admitted_status
            ) VALUES (
                p_patients(i).patient_name,
                p_patients(i).age,
                p_patients(i).gender,
                NVL(p_patients(i).admitted_status, 'NO')
            );
        
        -- Get count of inserted rows
        v_inserted_count := SQL%ROWCOUNT;
        
        -- Commit the transaction
        COMMIT;
        
        -- Output success message
        DBMS_OUTPUT.PUT_LINE('Successfully inserted ' || v_inserted_count || ' patient record(s)');
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback on error
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error in bulk_load_patients: ' || SQLERRM);
            RAISE;
    END bulk_load_patients;
    
    -- ============================================================
    -- Function: show_all_patients
    -- Returns a cursor with all patient information
    -- ============================================================
    FUNCTION show_all_patients
    RETURN SYS_REFCURSOR
    IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                patient_id,
                patient_name,
                age,
                gender,
                admitted_status,
                admission_date,
                discharge_date,
                created_date
            FROM patients
            ORDER BY patient_id;
        
        RETURN v_cursor;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in show_all_patients: ' || SQLERRM);
            RAISE;
    END show_all_patients;
    
    -- ============================================================
    -- Function: count_admitted
    -- Returns count of currently admitted patients
    -- ============================================================
    FUNCTION count_admitted
    RETURN NUMBER
    IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM patients
        WHERE UPPER(admitted_status) IN ('YES', 'Y')
          AND (discharge_date IS NULL OR discharge_date > SYSDATE);
        
        RETURN v_count;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in count_admitted: ' || SQLERRM);
            RETURN 0;
    END count_admitted;
    
    -- ============================================================
    -- Procedure: admit_patient
    -- Updates patient status to admitted
    -- ============================================================
    PROCEDURE admit_patient (
        p_patient_id IN NUMBER
    )
    IS
        v_patient_exists NUMBER;
    BEGIN
        -- Check if patient exists
        SELECT COUNT(*)
        INTO v_patient_exists
        FROM patients
        WHERE patient_id = p_patient_id;
        
        IF v_patient_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Patient ID ' || p_patient_id || ' does not exist');
        END IF;
        
        -- Update patient status
        UPDATE patients
        SET admitted_status = 'YES',
            admission_date = SYSDATE,
            discharge_date = NULL
        WHERE patient_id = p_patient_id;
        
        -- Commit the transaction
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Patient ID ' || p_patient_id || ' has been admitted');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error in admit_patient: ' || SQLERRM);
            RAISE;
    END admit_patient;
    
    -- ============================================================
    -- Procedure: discharge_patient
    -- Updates patient status to discharged
    -- ============================================================
    PROCEDURE discharge_patient (
        p_patient_id IN NUMBER
    )
    IS
        v_patient_exists NUMBER;
    BEGIN
        -- Check if patient exists
        SELECT COUNT(*)
        INTO v_patient_exists
        FROM patients
        WHERE patient_id = p_patient_id;
        
        IF v_patient_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Patient ID ' || p_patient_id || ' does not exist');
        END IF;
        
        -- Update patient status
        UPDATE patients
        SET admitted_status = 'NO',
            discharge_date = SYSDATE
        WHERE patient_id = p_patient_id;
        
        -- Commit the transaction
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Patient ID ' || p_patient_id || ' has been discharged');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error in discharge_patient: ' || SQLERRM);
            RAISE;
    END discharge_patient;
    
    -- ============================================================
    -- Function: get_patient_details
    -- Returns patient details by ID
    -- ============================================================
    FUNCTION get_patient_details (
        p_patient_id IN NUMBER
    ) RETURN SYS_REFCURSOR
    IS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT 
                patient_id,
                patient_name,
                age,
                gender,
                admitted_status,
                admission_date,
                discharge_date,
                created_date
            FROM patients
            WHERE patient_id = p_patient_id;
        
        RETURN v_cursor;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_patient_details: ' || SQLERRM);
            RAISE;
    END get_patient_details;
    
    -- ============================================================
    -- Procedure: add_doctor
    -- Adds a new doctor to the system
    -- ============================================================
    PROCEDURE add_doctor (
        p_doctor_name IN VARCHAR2,
        p_specialty IN VARCHAR2,
        p_phone_number IN VARCHAR2 DEFAULT NULL,
        p_email IN VARCHAR2 DEFAULT NULL
    )
    IS
    BEGIN
        INSERT INTO doctors (
            doctor_name,
            specialty,
            phone_number,
            email
        ) VALUES (
            p_doctor_name,
            p_specialty,
            p_phone_number,
            p_email
        );
        
        -- Commit the transaction
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Doctor ' || p_doctor_name || ' added successfully');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error in add_doctor: ' || SQLERRM);
            RAISE;
    END add_doctor;
    
END hospital_mgmt_pkg;
/

