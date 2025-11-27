-- ============================================================
-- QUESTION 4 - PART 3: CREATE PACKAGE SPECIFICATION
-- Hospital Management Package with Bulk Processing
-- ============================================================
-- Package Specification: hospital_mgmt_pkg
-- ============================================================

CREATE OR REPLACE PACKAGE hospital_mgmt_pkg
IS
    -- ============================================================
    -- Collection Type for Bulk Processing
    -- ============================================================
    TYPE patient_rec_type IS RECORD (
        patient_name VARCHAR2(100),
        age NUMBER,
        gender VARCHAR2(10),
        admitted_status VARCHAR2(10) DEFAULT 'NO'
    );
    
    TYPE patient_tab_type IS TABLE OF patient_rec_type;
    
    -- ============================================================
    -- Procedure: bulk_load_patients
    -- Description: Inserts multiple patient records at once using bulk collection
    -- Parameters: p_patients - Collection of patient records
    -- ============================================================
    PROCEDURE bulk_load_patients (
        p_patients IN patient_tab_type
    );
    
    -- ============================================================
    -- Function: show_all_patients
    -- Description: Returns a cursor to display all patients
    -- Returns: REF CURSOR with patient information
    -- ============================================================
    FUNCTION show_all_patients
    RETURN SYS_REFCURSOR;
    
    -- ============================================================
    -- Function: count_admitted
    -- Description: Returns the number of patients currently admitted
    -- Returns: NUMBER - count of admitted patients
    -- ============================================================
    FUNCTION count_admitted
    RETURN NUMBER;
    
    -- ============================================================
    -- Procedure: admit_patient
    -- Description: Updates a patient's status as admitted
    -- Parameters: p_patient_id - ID of the patient to admit
    -- ============================================================
    PROCEDURE admit_patient (
        p_patient_id IN NUMBER
    );
    
    -- ============================================================
    -- Additional Helper Procedures (Optional but useful)
    -- ============================================================
    
    -- Procedure to discharge a patient
    PROCEDURE discharge_patient (
        p_patient_id IN NUMBER
    );
    
    -- Function to get patient details by ID
    FUNCTION get_patient_details (
        p_patient_id IN NUMBER
    ) RETURN SYS_REFCURSOR;
    
    -- Procedure to add a doctor
    PROCEDURE add_doctor (
        p_doctor_name IN VARCHAR2,
        p_specialty IN VARCHAR2,
        p_phone_number IN VARCHAR2 DEFAULT NULL,
        p_email IN VARCHAR2 DEFAULT NULL
    );
    
END hospital_mgmt_pkg;
/

-- Add package comment
COMMENT ON PACKAGE hospital_mgmt_pkg IS 
    'Hospital Management Package for bulk processing of patients and managing admissions';

