-- Project 2: move name-dependent values out of the application table.
-- Run after this folder's preliminary_upload.sql has populated preliminary.
-- preliminary_upload.sql remains a separate input/staging script.
-- This step normalizes code/name dependencies only; it keeps the original
-- numeric race and denial-reason slots and does not normalize other FDs.

\set ON_ERROR_STOP on
BEGIN;

DROP TABLE IF EXISTS p2_application_denial;
DROP TABLE IF EXISTS p2_application_co_race;
DROP TABLE IF EXISTS p2_application_race;
DROP TABLE IF EXISTS p2_application_denial_reason;
DROP TABLE IF EXISTS p2_co_applicant_race_selection;
DROP TABLE IF EXISTS p2_applicant_race_selection;
DROP TABLE IF EXISTS p2_application;
DROP TABLE IF EXISTS p2_respondent;
DROP TABLE IF EXISTS p2_location;
DROP TABLE IF EXISTS p2_null_only_fields;
DROP TABLE IF EXISTS p2_edit_status;
DROP TABLE IF EXISTS p2_denial_reason;
DROP TABLE IF EXISTS p2_denial_reason_code;
DROP TABLE IF EXISTS p2_co_applicant_race;
DROP TABLE IF EXISTS p2_co_applicant_race_code;
DROP TABLE IF EXISTS p2_applicant_race;
DROP TABLE IF EXISTS p2_applicant_race_code;
DROP TABLE IF EXISTS p2_co_applicant_sex;
DROP TABLE IF EXISTS p2_applicant_sex;
DROP TABLE IF EXISTS p2_co_applicant_ethnicity;
DROP TABLE IF EXISTS p2_applicant_ethnicity;
DROP TABLE IF EXISTS p2_lien_status;
DROP TABLE IF EXISTS p2_hoepa_status;
DROP TABLE IF EXISTS p2_purchaser_type;
DROP TABLE IF EXISTS p2_action_taken;
DROP TABLE IF EXISTS p2_preapproval;
DROP TABLE IF EXISTS p2_owner_occupancy;
DROP TABLE IF EXISTS p2_loan_purpose;
DROP TABLE IF EXISTS p2_property_type;
DROP TABLE IF EXISTS p2_loan_type;
DROP TABLE IF EXISTS p2_msamd;
DROP TABLE IF EXISTS p2_county;
DROP TABLE IF EXISTS p2_state;
DROP TABLE IF EXISTS p2_agency;

-- Each code is the primary key for its name (and abbreviation, where present).
CREATE TABLE p2_agency (
    agency_code INTEGER PRIMARY KEY,
    agency_name TEXT,
    agency_abbr TEXT
);

CREATE TABLE p2_loan_type (
    loan_type INTEGER PRIMARY KEY,
    loan_type_name TEXT
);

CREATE TABLE p2_property_type (
    property_type INTEGER PRIMARY KEY,
    property_type_name TEXT
);

CREATE TABLE p2_loan_purpose (
    loan_purpose INTEGER PRIMARY KEY,
    loan_purpose_name TEXT
);

CREATE TABLE p2_owner_occupancy (
    owner_occupancy INTEGER PRIMARY KEY,
    owner_occupancy_name TEXT
);

CREATE TABLE p2_preapproval (
    preapproval INTEGER PRIMARY KEY,
    preapproval_name TEXT
);

CREATE TABLE p2_action_taken (
    action_taken INTEGER PRIMARY KEY,
    action_taken_name TEXT
);

CREATE TABLE p2_msamd (
    msamd INTEGER PRIMARY KEY,
    msamd_name TEXT
);

CREATE TABLE p2_state (
    state_code INTEGER PRIMARY KEY,
    state_name TEXT,
    state_abbr TEXT
);

CREATE TABLE p2_county (
    state_code INTEGER REFERENCES p2_state(state_code),
    county_code INTEGER,
    county_name TEXT,
    PRIMARY KEY (state_code, county_code)
);

CREATE TABLE p2_applicant_ethnicity (
    applicant_ethnicity INTEGER PRIMARY KEY,
    applicant_ethnicity_name TEXT
);

CREATE TABLE p2_co_applicant_ethnicity (
    co_applicant_ethnicity INTEGER PRIMARY KEY,
    co_applicant_ethnicity_name TEXT
);

CREATE TABLE p2_applicant_sex (
    applicant_sex INTEGER PRIMARY KEY,
    applicant_sex_name TEXT
);

CREATE TABLE p2_co_applicant_sex (
    co_applicant_sex INTEGER PRIMARY KEY,
    co_applicant_sex_name TEXT
);

CREATE TABLE p2_applicant_race (
    applicant_race INTEGER PRIMARY KEY,
    applicant_race_name TEXT
);

CREATE TABLE p2_co_applicant_race (
    co_applicant_race INTEGER PRIMARY KEY,
    co_applicant_race_name TEXT
);

CREATE TABLE p2_purchaser_type (
    purchaser_type INTEGER PRIMARY KEY,
    purchaser_type_name TEXT
);

CREATE TABLE p2_denial_reason (
    denial_reason INTEGER PRIMARY KEY,
    denial_reason_name TEXT
);

CREATE TABLE p2_hoepa_status (
    hoepa_status INTEGER PRIMARY KEY,
    hoepa_status_name TEXT
);

CREATE TABLE p2_lien_status (
    lien_status INTEGER PRIMARY KEY,
    lien_status_name TEXT
);

-- These source fields are entirely NULL. Keep their types and NULL values
-- together in one singleton row so they can be reconstructed later.
CREATE TABLE p2_null_only_fields (
    singleton_id SMALLINT PRIMARY KEY CHECK (singleton_id = 1),
    edit_status INTEGER,
    edit_status_name TEXT,
    application_date_indicator INTEGER
);

-- Keep the source numeric types and sequence_number key. All descriptive
-- text columns are removed; respondent_id is the sole text exception.
CREATE TABLE p2_application (
    sequence_number INTEGER PRIMARY KEY,
    as_of_year INTEGER,
    respondent_id TEXT,
    agency_code INTEGER REFERENCES p2_agency(agency_code),
    loan_type INTEGER REFERENCES p2_loan_type(loan_type),
    property_type INTEGER REFERENCES p2_property_type(property_type),
    loan_purpose INTEGER REFERENCES p2_loan_purpose(loan_purpose),
    owner_occupancy INTEGER REFERENCES p2_owner_occupancy(owner_occupancy),
    loan_amount_000s NUMERIC(12, 3),
    preapproval INTEGER REFERENCES p2_preapproval(preapproval),
    action_taken INTEGER REFERENCES p2_action_taken(action_taken),
    msamd INTEGER REFERENCES p2_msamd(msamd),
    state_code INTEGER REFERENCES p2_state(state_code),
    county_code INTEGER,
    census_tract_number NUMERIC(12, 2),
    applicant_ethnicity INTEGER
        REFERENCES p2_applicant_ethnicity(applicant_ethnicity),
    co_applicant_ethnicity INTEGER
        REFERENCES p2_co_applicant_ethnicity(co_applicant_ethnicity),
    applicant_race_1 INTEGER REFERENCES p2_applicant_race(applicant_race),
    applicant_race_2 INTEGER REFERENCES p2_applicant_race(applicant_race),
    applicant_race_3 INTEGER REFERENCES p2_applicant_race(applicant_race),
    applicant_race_4 INTEGER REFERENCES p2_applicant_race(applicant_race),
    applicant_race_5 INTEGER REFERENCES p2_applicant_race(applicant_race),
    co_applicant_race_1 INTEGER
        REFERENCES p2_co_applicant_race(co_applicant_race),
    co_applicant_race_2 INTEGER
        REFERENCES p2_co_applicant_race(co_applicant_race),
    co_applicant_race_3 INTEGER
        REFERENCES p2_co_applicant_race(co_applicant_race),
    co_applicant_race_4 INTEGER
        REFERENCES p2_co_applicant_race(co_applicant_race),
    co_applicant_race_5 INTEGER
        REFERENCES p2_co_applicant_race(co_applicant_race),
    applicant_sex INTEGER REFERENCES p2_applicant_sex(applicant_sex),
    co_applicant_sex INTEGER
        REFERENCES p2_co_applicant_sex(co_applicant_sex),
    applicant_income_000s INTEGER,
    purchaser_type INTEGER REFERENCES p2_purchaser_type(purchaser_type),
    denial_reason_1 INTEGER REFERENCES p2_denial_reason(denial_reason),
    denial_reason_2 INTEGER REFERENCES p2_denial_reason(denial_reason),
    denial_reason_3 INTEGER REFERENCES p2_denial_reason(denial_reason),
    rate_spread NUMERIC(10, 3),
    hoepa_status INTEGER REFERENCES p2_hoepa_status(hoepa_status),
    lien_status INTEGER REFERENCES p2_lien_status(lien_status),
    population INTEGER,
    minority_population NUMERIC,
    hud_median_family_income INTEGER,
    tract_to_msamd_income NUMERIC,
    number_of_owner_occupied_units INTEGER,
    number_of_1_to_4_family_units INTEGER,
    FOREIGN KEY (state_code, county_code)
        REFERENCES p2_county(state_code, county_code)
);

-- Load each code/name mapping from the actual typed source values. If a
-- code occurs with conflicting names, its primary-key constraint raises an
-- error rather than silently choosing one label.
INSERT INTO p2_agency (agency_code, agency_name, agency_abbr)
SELECT DISTINCT agency_code, agency_name, agency_abbr
FROM preliminary
WHERE agency_code IS NOT NULL;

INSERT INTO p2_loan_type (loan_type, loan_type_name)
SELECT DISTINCT loan_type, loan_type_name
FROM preliminary
WHERE loan_type IS NOT NULL;

INSERT INTO p2_property_type (property_type, property_type_name)
SELECT DISTINCT property_type, property_type_name
FROM preliminary
WHERE property_type IS NOT NULL;

INSERT INTO p2_loan_purpose (loan_purpose, loan_purpose_name)
SELECT DISTINCT loan_purpose, loan_purpose_name
FROM preliminary
WHERE loan_purpose IS NOT NULL;

INSERT INTO p2_owner_occupancy (owner_occupancy, owner_occupancy_name)
SELECT DISTINCT owner_occupancy, owner_occupancy_name
FROM preliminary
WHERE owner_occupancy IS NOT NULL;

INSERT INTO p2_preapproval (preapproval, preapproval_name)
SELECT DISTINCT preapproval, preapproval_name
FROM preliminary
WHERE preapproval IS NOT NULL;

INSERT INTO p2_action_taken (action_taken, action_taken_name)
SELECT DISTINCT action_taken, action_taken_name
FROM preliminary
WHERE action_taken IS NOT NULL;

INSERT INTO p2_msamd (msamd, msamd_name)
SELECT DISTINCT msamd, msamd_name
FROM preliminary
WHERE msamd IS NOT NULL;

INSERT INTO p2_state (state_code, state_name, state_abbr)
SELECT DISTINCT state_code, state_name, state_abbr
FROM preliminary
WHERE state_code IS NOT NULL;

INSERT INTO p2_county (state_code, county_code, county_name)
SELECT DISTINCT state_code, county_code, county_name
FROM preliminary
WHERE state_code IS NOT NULL
  AND county_code IS NOT NULL;

INSERT INTO p2_applicant_ethnicity (
    applicant_ethnicity, applicant_ethnicity_name
)
SELECT DISTINCT applicant_ethnicity, applicant_ethnicity_name
FROM preliminary
WHERE applicant_ethnicity IS NOT NULL;

INSERT INTO p2_co_applicant_ethnicity (
    co_applicant_ethnicity, co_applicant_ethnicity_name
)
SELECT DISTINCT co_applicant_ethnicity, co_applicant_ethnicity_name
FROM preliminary
WHERE co_applicant_ethnicity IS NOT NULL;

INSERT INTO p2_applicant_sex (applicant_sex, applicant_sex_name)
SELECT DISTINCT applicant_sex, applicant_sex_name
FROM preliminary
WHERE applicant_sex IS NOT NULL;

INSERT INTO p2_co_applicant_sex (
    co_applicant_sex, co_applicant_sex_name
)
SELECT DISTINCT co_applicant_sex, co_applicant_sex_name
FROM preliminary
WHERE co_applicant_sex IS NOT NULL;

INSERT INTO p2_applicant_race (applicant_race, applicant_race_name)
SELECT DISTINCT race_code, race_name
FROM (
    SELECT applicant_race_1 AS race_code,
           applicant_race_name_1 AS race_name
    FROM preliminary
    UNION ALL
    SELECT applicant_race_2, applicant_race_name_2 FROM preliminary
    UNION ALL
    SELECT applicant_race_3, applicant_race_name_3 FROM preliminary
    UNION ALL
    SELECT applicant_race_4, applicant_race_name_4 FROM preliminary
    UNION ALL
    SELECT applicant_race_5, applicant_race_name_5 FROM preliminary
) AS applicant_race_codes
WHERE race_code IS NOT NULL;

INSERT INTO p2_co_applicant_race (
    co_applicant_race, co_applicant_race_name
)
SELECT DISTINCT race_code, race_name
FROM (
    SELECT co_applicant_race_1 AS race_code,
           co_applicant_race_name_1 AS race_name
    FROM preliminary
    UNION ALL
    SELECT co_applicant_race_2, co_applicant_race_name_2 FROM preliminary
    UNION ALL
    SELECT co_applicant_race_3, co_applicant_race_name_3 FROM preliminary
    UNION ALL
    SELECT co_applicant_race_4, co_applicant_race_name_4 FROM preliminary
    UNION ALL
    SELECT co_applicant_race_5, co_applicant_race_name_5 FROM preliminary
) AS co_applicant_race_codes
WHERE race_code IS NOT NULL;

INSERT INTO p2_purchaser_type (purchaser_type, purchaser_type_name)
SELECT DISTINCT purchaser_type, purchaser_type_name
FROM preliminary
WHERE purchaser_type IS NOT NULL;

INSERT INTO p2_denial_reason (denial_reason, denial_reason_name)
SELECT DISTINCT reason_code, reason_name
FROM (
    SELECT denial_reason_1 AS reason_code,
           denial_reason_name_1 AS reason_name
    FROM preliminary
    UNION ALL
    SELECT denial_reason_2, denial_reason_name_2 FROM preliminary
    UNION ALL
    SELECT denial_reason_3, denial_reason_name_3 FROM preliminary
) AS denial_reason_codes
WHERE reason_code IS NOT NULL;

INSERT INTO p2_hoepa_status (hoepa_status, hoepa_status_name)
SELECT DISTINCT hoepa_status, hoepa_status_name
FROM preliminary
WHERE hoepa_status IS NOT NULL;

INSERT INTO p2_lien_status (lien_status, lien_status_name)
SELECT DISTINCT lien_status, lien_status_name
FROM preliminary
WHERE lien_status IS NOT NULL;

-- The source has no non-NULL values for these fields, so the one row is
-- intentionally all NULL apart from its technical singleton primary key.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM preliminary
        WHERE edit_status IS NOT NULL
           OR NULLIF(edit_status_name, '') IS NOT NULL
           OR application_date_indicator IS NOT NULL
    ) THEN
        RAISE EXCEPTION
            'Expected edit_status and application_date_indicator to be entirely NULL';
    END IF;
END;
$$;

INSERT INTO p2_null_only_fields (
    singleton_id, edit_status, edit_status_name, application_date_indicator
)
VALUES (1, NULL, NULL, NULL);

-- Copy one row per source application. The original numeric slots and
-- sequence_number values are preserved.
INSERT INTO p2_application (
    sequence_number, as_of_year, respondent_id, agency_code,
    loan_type, property_type, loan_purpose, owner_occupancy,
    loan_amount_000s, preapproval, action_taken, msamd, state_code,
    county_code, census_tract_number, applicant_ethnicity,
    co_applicant_ethnicity, applicant_race_1, applicant_race_2,
    applicant_race_3, applicant_race_4, applicant_race_5,
    co_applicant_race_1, co_applicant_race_2, co_applicant_race_3,
    co_applicant_race_4, co_applicant_race_5, applicant_sex,
    co_applicant_sex, applicant_income_000s, purchaser_type,
    denial_reason_1, denial_reason_2, denial_reason_3, rate_spread,
    hoepa_status, lien_status, population, minority_population,
    hud_median_family_income, tract_to_msamd_income,
    number_of_owner_occupied_units, number_of_1_to_4_family_units
)
SELECT
    sequence_number, as_of_year, respondent_id, agency_code,
    loan_type, property_type, loan_purpose, owner_occupancy,
    loan_amount_000s, preapproval, action_taken, msamd, state_code,
    county_code, census_tract_number, applicant_ethnicity,
    co_applicant_ethnicity, applicant_race_1, applicant_race_2,
    applicant_race_3, applicant_race_4, applicant_race_5,
    co_applicant_race_1, co_applicant_race_2, co_applicant_race_3,
    co_applicant_race_4, co_applicant_race_5, applicant_sex,
    co_applicant_sex, applicant_income_000s, purchaser_type,
    denial_reason_1, denial_reason_2, denial_reason_3, rate_spread,
    hoepa_status, lien_status, population, minority_population,
    hud_median_family_income, tract_to_msamd_income,
    number_of_owner_occupied_units, number_of_1_to_4_family_units
FROM preliminary;

COMMIT;
