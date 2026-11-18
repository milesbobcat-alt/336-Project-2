-- PART 4: integrity constraints and three rejection tests
-- Run only after the normalized Part 3 database is populated.

-- PART 4: data-derived NOT NULL constraints for actual 2017 NJ CSV.
-- Full CSV scanned: 349563 records. Columns nullable in the CSV are left nullable.
-- Run after PART 3, once, inside psql. Does not access staging tables.

\set ON_ERROR_STOP on
BEGIN;
ALTER TABLE p2_application ALTER COLUMN as_of_year SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN respondent_id SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN agency_code SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN loan_type SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN property_type SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN loan_purpose SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN owner_occupancy SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN preapproval SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN action_taken SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN applicant_ethnicity SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN co_applicant_ethnicity SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN applicant_sex SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN co_applicant_sex SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN purchaser_type SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN hoepa_status SET NOT NULL;
ALTER TABLE p2_application ALTER COLUMN lien_status SET NOT NULL;
ALTER TABLE p2_location ALTER COLUMN state_code SET NOT NULL;
ALTER TABLE p2_agency ALTER COLUMN agency_name SET NOT NULL;
ALTER TABLE p2_agency ALTER COLUMN agency_abbr SET NOT NULL;
ALTER TABLE p2_loan_type ALTER COLUMN loan_type_name SET NOT NULL;
ALTER TABLE p2_property_type ALTER COLUMN property_type_name SET NOT NULL;
ALTER TABLE p2_loan_purpose ALTER COLUMN loan_purpose_name SET NOT NULL;
ALTER TABLE p2_owner_occupancy ALTER COLUMN owner_occupancy_name SET NOT NULL;
ALTER TABLE p2_preapproval ALTER COLUMN preapproval_name SET NOT NULL;
ALTER TABLE p2_action_taken ALTER COLUMN action_taken_name SET NOT NULL;
ALTER TABLE p2_state ALTER COLUMN state_name SET NOT NULL;
ALTER TABLE p2_state ALTER COLUMN state_abbr SET NOT NULL;
ALTER TABLE p2_applicant_ethnicity ALTER COLUMN applicant_ethnicity_name SET NOT NULL;
ALTER TABLE p2_co_applicant_ethnicity ALTER COLUMN co_applicant_ethnicity_name SET NOT NULL;
ALTER TABLE p2_applicant_sex ALTER COLUMN applicant_sex_name SET NOT NULL;
ALTER TABLE p2_co_applicant_sex ALTER COLUMN co_applicant_sex_name SET NOT NULL;
ALTER TABLE p2_applicant_race ALTER COLUMN applicant_race_name SET NOT NULL;
ALTER TABLE p2_co_applicant_race ALTER COLUMN co_applicant_race_name SET NOT NULL;
ALTER TABLE p2_purchaser_type ALTER COLUMN purchaser_type_name SET NOT NULL;
ALTER TABLE p2_denial_reason ALTER COLUMN denial_reason_name SET NOT NULL;
ALTER TABLE p2_hoepa_status ALTER COLUMN hoepa_status_name SET NOT NULL;
ALTER TABLE p2_lien_status ALTER COLUMN lien_status_name SET NOT NULL;
-- Restrict invalid source position numbers (Step 3 already has equivalent CHECKs).
-- Existing PRIMARY KEY / FOREIGN KEY definitions in Steps 2-3 reject unknown
-- codes and duplicate keys; do not disable those constraints.
-- Explicit singleton protection for the fields that are all NULL in the CSV:
ALTER TABLE p2_null_only_fields ADD CONSTRAINT p2_null_fields_all_null
    CHECK (edit_status IS NULL AND edit_status_name IS NULL
           AND application_date_indicator IS NULL);
COMMIT;


-- PART 4: three reproducible REJECTED INSERT demonstrations.
-- Run after the constraints section above, with valid populated p2_application.
-- Each DO block catches ONLY the expected SQLSTATE; an unexpected error aborts.
-- No invalid record is committed. No application rows are changed.
\set ON_ERROR_STOP on

-- TEST 1: invalid foreign key. property_type=4 is not an allowed code
-- (the actual CSV only uses 1, 2, 3). All other values are copied from
-- an existing valid row to isolate the foreign-key failure.
DO $$
DECLARE msg text;
BEGIN
  BEGIN
    INSERT INTO p2_application
    SELECT (SELECT MAX(sequence_number)+1 FROM p2_application) AS sequence_number,
           as_of_year, respondent_id, agency_code, loan_type, 4 AS property_type,
           loan_purpose, owner_occupancy, loan_amount_000s, preapproval,
           action_taken, applicant_ethnicity, co_applicant_ethnicity,
           applicant_sex, co_applicant_sex, applicant_income_000s,
           purchaser_type, rate_spread, hoepa_status, lien_status, location_id
    FROM p2_application ORDER BY sequence_number LIMIT 1;
    RAISE EXCEPTION 'TEST 1 FAIL: invalid property_type was accepted';
  EXCEPTION WHEN foreign_key_violation THEN
    GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
    RAISE NOTICE 'TEST 1 PASS: FK rejected bad property_type: %', msg;
  END;
END $$;

-- TEST 2: primary key uniqueness. Reinsert an unchanged application row.
DO $$
DECLARE msg text;
BEGIN
  BEGIN
    INSERT INTO p2_application SELECT * FROM p2_application
    ORDER BY sequence_number LIMIT 1;
    RAISE EXCEPTION 'TEST 2 FAIL: duplicate application ID was accepted';
  EXCEPTION WHEN unique_violation THEN
    GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
    RAISE NOTICE 'TEST 2 PASS: duplicate PK rejected: %', msg;
  END;
END $$;

-- TEST 3: required field cannot be NULL. respondent_id never NULL in CSV.
DO $$
DECLARE msg text;
BEGIN
  BEGIN
    INSERT INTO p2_application
    SELECT (SELECT MAX(sequence_number)+1 FROM p2_application) AS sequence_number,
           as_of_year, NULL::text AS respondent_id, agency_code, loan_type,
           property_type, loan_purpose, owner_occupancy, loan_amount_000s,
           preapproval, action_taken, applicant_ethnicity,
           co_applicant_ethnicity, applicant_sex, co_applicant_sex,
           applicant_income_000s, purchaser_type, rate_spread,
           hoepa_status, lien_status, location_id
    FROM p2_application ORDER BY sequence_number LIMIT 1;
    RAISE EXCEPTION 'TEST 3 FAIL: NULL respondent_id was accepted';
  EXCEPTION WHEN not_null_violation THEN
    GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
    RAISE NOTICE 'TEST 3 PASS: NULL rejected: %', msg;
  END;
END $$;
