-- PART 4: reconstruct original 78-column HMDA CSV from normalized tables ONLY.
-- Prerequisites: preliminary_upload.sql, normalize_hmda_project2.sql,
-- part3.sql, and part4_checks.sql; do not use preliminary/raw for the export.
-- Run inside psql: \i part4_export.sql
-- Output: hmda_reconstructed.csv in the psql client's current working directory.

\set ON_ERROR_STOP on

CREATE OR REPLACE TEMP VIEW hmda_reconstructed_export AS
SELECT
    trim_scale(a.as_of_year)::text AS as_of_year,
    a.respondent_id AS respondent_id,
    agency.agency_name::text AS agency_name,
    agency.agency_abbr::text AS agency_abbr,
    trim_scale(a.agency_code)::text AS agency_code,
    loan_type.loan_type_name::text AS loan_type_name,
    trim_scale(a.loan_type)::text AS loan_type,
    property_type.property_type_name::text AS property_type_name,
    trim_scale(a.property_type)::text AS property_type,
    loan_purpose.loan_purpose_name::text AS loan_purpose_name,
    trim_scale(a.loan_purpose)::text AS loan_purpose,
    owner_occupancy.owner_occupancy_name::text AS owner_occupancy_name,
    trim_scale(a.owner_occupancy)::text AS owner_occupancy,
    trim_scale(a.loan_amount_000s)::text AS loan_amount_000s,
    preapproval.preapproval_name::text AS preapproval_name,
    trim_scale(a.preapproval)::text AS preapproval,
    action_taken.action_taken_name::text AS action_taken_name,
    trim_scale(a.action_taken)::text AS action_taken,
    msamd.msamd_name::text AS msamd_name,
    trim_scale(loc.msamd)::text AS msamd,
    state.state_name::text AS state_name,
    state.state_abbr::text AS state_abbr,
    trim_scale(loc.state_code)::text AS state_code,
    county.county_name::text AS county_name,
    trim_scale(loc.county_code)::text AS county_code,
    to_char(loc.census_tract_number, 'FM0000.00') AS census_tract_number,
    applicant_ethnicity.applicant_ethnicity_name::text AS applicant_ethnicity_name,
    trim_scale(a.applicant_ethnicity)::text AS applicant_ethnicity,
    co_applicant_ethnicity.co_applicant_ethnicity_name::text AS co_applicant_ethnicity_name,
    trim_scale(a.co_applicant_ethnicity)::text AS co_applicant_ethnicity,
    arc1.applicant_race_name::text AS applicant_race_name_1,
    ar.applicant_race_1::text AS applicant_race_1,
    arc2.applicant_race_name::text AS applicant_race_name_2,
    ar.applicant_race_2::text AS applicant_race_2,
    arc3.applicant_race_name::text AS applicant_race_name_3,
    ar.applicant_race_3::text AS applicant_race_3,
    arc4.applicant_race_name::text AS applicant_race_name_4,
    ar.applicant_race_4::text AS applicant_race_4,
    arc5.applicant_race_name::text AS applicant_race_name_5,
    ar.applicant_race_5::text AS applicant_race_5,
    crc1.co_applicant_race_name::text AS co_applicant_race_name_1,
    cr.co_applicant_race_1::text AS co_applicant_race_1,
    crc2.co_applicant_race_name::text AS co_applicant_race_name_2,
    cr.co_applicant_race_2::text AS co_applicant_race_2,
    crc3.co_applicant_race_name::text AS co_applicant_race_name_3,
    cr.co_applicant_race_3::text AS co_applicant_race_3,
    crc4.co_applicant_race_name::text AS co_applicant_race_name_4,
    cr.co_applicant_race_4::text AS co_applicant_race_4,
    crc5.co_applicant_race_name::text AS co_applicant_race_name_5,
    cr.co_applicant_race_5::text AS co_applicant_race_5,
    applicant_sex.applicant_sex_name::text AS applicant_sex_name,
    trim_scale(a.applicant_sex)::text AS applicant_sex,
    co_applicant_sex.co_applicant_sex_name::text AS co_applicant_sex_name,
    trim_scale(a.co_applicant_sex)::text AS co_applicant_sex,
    trim_scale(a.applicant_income_000s)::text AS applicant_income_000s,
    purchaser_type.purchaser_type_name::text AS purchaser_type_name,
    trim_scale(a.purchaser_type)::text AS purchaser_type,
    drc1.denial_reason_name::text AS denial_reason_name_1,
    dr.denial_reason_1::text AS denial_reason_1,
    drc2.denial_reason_name::text AS denial_reason_name_2,
    dr.denial_reason_2::text AS denial_reason_2,
    drc3.denial_reason_name::text AS denial_reason_name_3,
    dr.denial_reason_3::text AS denial_reason_3,
    to_char(a.rate_spread, 'FM00.00') AS rate_spread,
    hoepa.hoepa_status_name::text AS hoepa_status_name,
    trim_scale(a.hoepa_status)::text AS hoepa_status,
    lien.lien_status_name::text AS lien_status_name,
    trim_scale(a.lien_status)::text AS lien_status,
    nulls.edit_status_name::text AS edit_status_name,
    nulls.edit_status::text AS edit_status,
    NULL::text AS sequence_number,
    trim_scale(loc.population)::text AS population,
    loc.minority_population::text AS minority_population,
    trim_scale(loc.hud_median_family_income)::text AS hud_median_family_income,
    loc.tract_to_msamd_income::text AS tract_to_msamd_income,
    trim_scale(loc.number_of_owner_occupied_units)::text AS number_of_owner_occupied_units,
    trim_scale(loc.number_of_1_to_4_family_units)::text AS number_of_1_to_4_family_units,
    nulls.application_date_indicator::text AS application_date_indicator
FROM p2_application a
LEFT JOIN p2_location loc ON loc.location_id = a.location_id
LEFT JOIN p2_state state ON state.state_code = loc.state_code
LEFT JOIN p2_county county ON county.county_code = loc.county_code AND county.state_code = loc.state_code
LEFT JOIN p2_msamd msamd ON msamd.msamd = loc.msamd
LEFT JOIN p2_null_only_fields nulls ON nulls.singleton_id = 1
LEFT JOIN p2_agency agency ON agency.agency_code = a.agency_code
LEFT JOIN p2_loan_type loan_type ON loan_type.loan_type = a.loan_type
LEFT JOIN p2_property_type property_type ON property_type.property_type = a.property_type
LEFT JOIN p2_loan_purpose loan_purpose ON loan_purpose.loan_purpose = a.loan_purpose
LEFT JOIN p2_owner_occupancy owner_occupancy ON owner_occupancy.owner_occupancy = a.owner_occupancy
LEFT JOIN p2_preapproval preapproval ON preapproval.preapproval = a.preapproval
LEFT JOIN p2_action_taken action_taken ON action_taken.action_taken = a.action_taken
LEFT JOIN p2_applicant_ethnicity applicant_ethnicity ON applicant_ethnicity.applicant_ethnicity = a.applicant_ethnicity
LEFT JOIN p2_co_applicant_ethnicity co_applicant_ethnicity ON co_applicant_ethnicity.co_applicant_ethnicity = a.co_applicant_ethnicity
LEFT JOIN p2_applicant_sex applicant_sex ON applicant_sex.applicant_sex = a.applicant_sex
LEFT JOIN p2_co_applicant_sex co_applicant_sex ON co_applicant_sex.co_applicant_sex = a.co_applicant_sex
LEFT JOIN p2_purchaser_type purchaser_type ON purchaser_type.purchaser_type = a.purchaser_type
LEFT JOIN p2_hoepa_status hoepa ON hoepa.hoepa_status = a.hoepa_status
LEFT JOIN p2_lien_status lien ON lien.lien_status = a.lien_status
LEFT JOIN (
    SELECT sequence_number,
           MAX(applicant_race) FILTER (WHERE applicant_race_num = 1) AS applicant_race_1,
           MAX(applicant_race) FILTER (WHERE applicant_race_num = 2) AS applicant_race_2,
           MAX(applicant_race) FILTER (WHERE applicant_race_num = 3) AS applicant_race_3,
           MAX(applicant_race) FILTER (WHERE applicant_race_num = 4) AS applicant_race_4,
           MAX(applicant_race) FILTER (WHERE applicant_race_num = 5) AS applicant_race_5
    FROM p2_application_race
    GROUP BY sequence_number
) ar ON ar.sequence_number = a.sequence_number
LEFT JOIN p2_applicant_race arc1 ON arc1.applicant_race = ar.applicant_race_1
LEFT JOIN p2_applicant_race arc2 ON arc2.applicant_race = ar.applicant_race_2
LEFT JOIN p2_applicant_race arc3 ON arc3.applicant_race = ar.applicant_race_3
LEFT JOIN p2_applicant_race arc4 ON arc4.applicant_race = ar.applicant_race_4
LEFT JOIN p2_applicant_race arc5 ON arc5.applicant_race = ar.applicant_race_5
LEFT JOIN (
    SELECT sequence_number,
           MAX(co_applicant_race) FILTER (WHERE co_applicant_race_num = 1) AS co_applicant_race_1,
           MAX(co_applicant_race) FILTER (WHERE co_applicant_race_num = 2) AS co_applicant_race_2,
           MAX(co_applicant_race) FILTER (WHERE co_applicant_race_num = 3) AS co_applicant_race_3,
           MAX(co_applicant_race) FILTER (WHERE co_applicant_race_num = 4) AS co_applicant_race_4,
           MAX(co_applicant_race) FILTER (WHERE co_applicant_race_num = 5) AS co_applicant_race_5
    FROM p2_application_co_race
    GROUP BY sequence_number
) cr ON cr.sequence_number = a.sequence_number
LEFT JOIN p2_co_applicant_race crc1 ON crc1.co_applicant_race = cr.co_applicant_race_1
LEFT JOIN p2_co_applicant_race crc2 ON crc2.co_applicant_race = cr.co_applicant_race_2
LEFT JOIN p2_co_applicant_race crc3 ON crc3.co_applicant_race = cr.co_applicant_race_3
LEFT JOIN p2_co_applicant_race crc4 ON crc4.co_applicant_race = cr.co_applicant_race_4
LEFT JOIN p2_co_applicant_race crc5 ON crc5.co_applicant_race = cr.co_applicant_race_5
LEFT JOIN (
    SELECT sequence_number,
           MAX(denial_reason) FILTER (WHERE denial_reason_num = 1) AS denial_reason_1,
           MAX(denial_reason) FILTER (WHERE denial_reason_num = 2) AS denial_reason_2,
           MAX(denial_reason) FILTER (WHERE denial_reason_num = 3) AS denial_reason_3
    FROM p2_application_denial
    GROUP BY sequence_number
) dr ON dr.sequence_number = a.sequence_number
LEFT JOIN p2_denial_reason drc1 ON drc1.denial_reason = dr.denial_reason_1
LEFT JOIN p2_denial_reason drc2 ON drc2.denial_reason = dr.denial_reason_2
LEFT JOIN p2_denial_reason drc3 ON drc3.denial_reason = dr.denial_reason_3
ORDER BY a.sequence_number;

DO $$
DECLARE
    application_count BIGINT;
    export_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO application_count FROM p2_application;
    SELECT COUNT(*) INTO export_count FROM hmda_reconstructed_export;

    IF export_count <> application_count THEN
        RAISE EXCEPTION
            'Reconstruction row count mismatch: % applications, % export rows',
            application_count, export_count;
    END IF;
END;
$$;

\copy hmda_reconstructed_export TO 'hmda_reconstructed.csv' WITH (FORMAT CSV, HEADER TRUE, NULL '');
