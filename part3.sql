\set ON_ERROR_STOP on
BEGIN;

-- respondent_id has conflicting agency_code values in the source CSV, so the
-- observed data does not satisfy respondent_id -> agency_code.
CREATE TABLE p2_location (
    location_id SERIAL PRIMARY KEY,
    county_code INTEGER,
    msamd INTEGER REFERENCES p2_msamd(msamd),
    state_code INTEGER REFERENCES p2_state(state_code),
    census_tract_number NUMERIC(12, 2),
    population INTEGER,
    minority_population NUMERIC,
    hud_median_family_income INTEGER,
    tract_to_msamd_income NUMERIC,
    number_of_owner_occupied_units INTEGER,
    number_of_1_to_4_family_units INTEGER,
    FOREIGN KEY (state_code, county_code)
        REFERENCES p2_county(state_code, county_code)
);

INSERT INTO p2_location (
    county_code, msamd, state_code, census_tract_number, population,
    minority_population, hud_median_family_income, tract_to_msamd_income,
    number_of_owner_occupied_units, number_of_1_to_4_family_units
)
SELECT DISTINCT
    county_code, msamd, state_code, census_tract_number, population,
    minority_population, hud_median_family_income, tract_to_msamd_income,
    number_of_owner_occupied_units, number_of_1_to_4_family_units
FROM p2_application;

ALTER TABLE p2_application
ADD COLUMN location_id INTEGER REFERENCES p2_location(location_id);

UPDATE p2_application AS a
SET location_id = l.location_id
FROM p2_location AS l
WHERE a.county_code IS NOT DISTINCT FROM l.county_code
  AND a.msamd IS NOT DISTINCT FROM l.msamd
  AND a.state_code IS NOT DISTINCT FROM l.state_code
  AND a.census_tract_number IS NOT DISTINCT FROM l.census_tract_number
  AND a.population IS NOT DISTINCT FROM l.population
  AND a.minority_population IS NOT DISTINCT FROM l.minority_population
  AND a.hud_median_family_income
      IS NOT DISTINCT FROM l.hud_median_family_income
  AND a.tract_to_msamd_income
      IS NOT DISTINCT FROM l.tract_to_msamd_income
  AND a.number_of_owner_occupied_units
      IS NOT DISTINCT FROM l.number_of_owner_occupied_units
  AND a.number_of_1_to_4_family_units
      IS NOT DISTINCT FROM l.number_of_1_to_4_family_units;

ALTER TABLE p2_application
ALTER COLUMN location_id SET NOT NULL;

CREATE TABLE p2_application_race (
    sequence_number INTEGER REFERENCES p2_application(sequence_number),
    applicant_race INTEGER NOT NULL REFERENCES p2_applicant_race(applicant_race),
    applicant_race_num INTEGER CHECK (applicant_race_num BETWEEN 1 AND 5),
    PRIMARY KEY (sequence_number, applicant_race_num)
);

INSERT INTO p2_application_race (sequence_number, applicant_race, applicant_race_num)
SELECT sequence_number, applicant_race_1, 1
FROM p2_application WHERE applicant_race_1 IS NOT NULL
UNION ALL
SELECT sequence_number, applicant_race_2, 2
FROM p2_application WHERE applicant_race_2 IS NOT NULL
UNION ALL
SELECT sequence_number, applicant_race_3, 3
FROM p2_application WHERE applicant_race_3 IS NOT NULL
UNION ALL
SELECT sequence_number, applicant_race_4, 4
FROM p2_application WHERE applicant_race_4 IS NOT NULL
UNION ALL
SELECT sequence_number, applicant_race_5, 5
FROM p2_application WHERE applicant_race_5 IS NOT NULL;

CREATE TABLE p2_application_co_race (
    sequence_number INTEGER REFERENCES p2_application(sequence_number),
    co_applicant_race INTEGER NOT NULL
        REFERENCES p2_co_applicant_race(co_applicant_race),
    co_applicant_race_num INTEGER CHECK (co_applicant_race_num BETWEEN 1 AND 5),
    PRIMARY KEY (sequence_number, co_applicant_race_num)
);

INSERT INTO p2_application_co_race (
    sequence_number, co_applicant_race, co_applicant_race_num
)
SELECT sequence_number, co_applicant_race_1, 1
FROM p2_application WHERE co_applicant_race_1 IS NOT NULL
UNION ALL
SELECT sequence_number, co_applicant_race_2, 2
FROM p2_application WHERE co_applicant_race_2 IS NOT NULL
UNION ALL
SELECT sequence_number, co_applicant_race_3, 3
FROM p2_application WHERE co_applicant_race_3 IS NOT NULL
UNION ALL
SELECT sequence_number, co_applicant_race_4, 4
FROM p2_application WHERE co_applicant_race_4 IS NOT NULL
UNION ALL
SELECT sequence_number, co_applicant_race_5, 5
FROM p2_application WHERE co_applicant_race_5 IS NOT NULL;

CREATE TABLE p2_application_denial (
    sequence_number INTEGER REFERENCES p2_application(sequence_number),
    denial_reason INTEGER NOT NULL REFERENCES p2_denial_reason(denial_reason),
    denial_reason_num INTEGER CHECK (denial_reason_num BETWEEN 1 AND 3),
    PRIMARY KEY (sequence_number, denial_reason_num)
);

INSERT INTO p2_application_denial (sequence_number, denial_reason, denial_reason_num)
SELECT sequence_number, denial_reason_1, 1
FROM p2_application WHERE denial_reason_1 IS NOT NULL
UNION ALL
SELECT sequence_number, denial_reason_2, 2
FROM p2_application WHERE denial_reason_2 IS NOT NULL
UNION ALL
SELECT sequence_number, denial_reason_3, 3
FROM p2_application WHERE denial_reason_3 IS NOT NULL;

ALTER TABLE p2_application
    DROP COLUMN county_code,
    DROP COLUMN msamd,
    DROP COLUMN state_code,
    DROP COLUMN census_tract_number,
    DROP COLUMN population,
    DROP COLUMN minority_population,
    DROP COLUMN hud_median_family_income,
    DROP COLUMN tract_to_msamd_income,
    DROP COLUMN number_of_owner_occupied_units,
    DROP COLUMN number_of_1_to_4_family_units,
    DROP COLUMN applicant_race_1,
    DROP COLUMN applicant_race_2,
    DROP COLUMN applicant_race_3,
    DROP COLUMN applicant_race_4,
    DROP COLUMN applicant_race_5,
    DROP COLUMN co_applicant_race_1,
    DROP COLUMN co_applicant_race_2,
    DROP COLUMN co_applicant_race_3,
    DROP COLUMN co_applicant_race_4,
    DROP COLUMN co_applicant_race_5,
    DROP COLUMN denial_reason_1,
    DROP COLUMN denial_reason_2,
    DROP COLUMN denial_reason_3;

COMMIT;
