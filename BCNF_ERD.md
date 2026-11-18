# HMDA Project 2 - BCNF ER Diagram

This design follows the functional dependencies in `part1_functional_dependencies.txt`.
`PK` marks every primary-key attribute; composite keys are marked on each component.

```mermaid
erDiagram
    APPLICATION {
        int sequence_number PK
        int as_of_year
        string respondent_id FK
        int loan_type FK
        int property_type FK
        int loan_purpose FK
        int owner_occupancy FK
        decimal loan_amount_000s
        int preapproval FK
        int action_taken FK
        int locationID FK
        int applicant_ethnicity FK
        int co_applicant_ethnicity FK
        int applicant_sex FK
        int co_applicant_sex FK
        int applicant_income_000s
        int purchaser_type FK
        decimal rate_spread
        int hoepa_status FK
        int lien_status FK
        int edit_status FK
        int application_date_indicator
    }
    RESPONDENT {
        string respondent_id PK
        int agency_code FK
    }
    AGENCY {
        int agency_code PK
        string agency_name
        string agency_abbr
    }
    LOCATION {
        int locationID PK
        int msamd FK
        int county_code FK
        decimal census_tract_number
        int population
        decimal minority_population
        int hud_median_family_income
        decimal tract_to_msamd_income
        int number_of_owner_occupied_units
        int number_of_1_to_4_family_units
    }
    STATE {
        int state_code PK
        string state_name
        string state_abbr
    }
    COUNTY {
        int county_code PK
        string county_name
        int state_code FK
    }
    MSAMD {
        int msamd PK
        string msamd_name
    }
    LOAN_TYPE {
        int loan_type PK
        string loan_type_name
    }
    PROPERTY_TYPE {
        int property_type PK
        string property_type_name
    }
    LOAN_PURPOSE {
        int loan_purpose PK
        string loan_purpose_name
    }
    OWNER_OCCUPANCY {
        int owner_occupancy PK
        string owner_occupancy_name
    }
    PREAPPROVAL {
        int preapproval PK
        string preapproval_name
    }
    ACTION_TAKEN {
        int action_taken PK
        string action_taken_name
    }
    APPLICANT_ETHNICITY {
        int applicant_ethnicity PK
        string applicant_ethnicity_name
    }
    CO_APPLICANT_ETHNICITY {
        int co_applicant_ethnicity PK
        string co_applicant_ethnicity_name
    }
    APPLICANT_SEX {
        int applicant_sex PK
        string applicant_sex_name
    }
    CO_APPLICANT_SEX {
        int co_applicant_sex PK
        string co_applicant_sex_name
    }
    APPLICANT_RACE_CODE {
        int applicant_race PK
        string applicant_race_name
    }
    CO_APPLICANT_RACE_CODE {
        int co_applicant_race PK
        string co_applicant_race_name
    }
    APPLICANT_RACE_SELECTION {
        int sequence_number PK, FK
        int applicant_race_num PK
        int applicant_race FK
    }
    CO_APPLICANT_RACE_SELECTION {
        int sequence_number PK, FK
        int co_applicant_race_num PK
        int co_applicant_race FK
    }
    PURCHASER_TYPE {
        int purchaser_type PK
        string purchaser_type_name
    }
    DENIAL_REASON_CODE {
        int denial_reason PK
        string denial_reason_name
    }
    APPLICATION_DENIAL_REASON {
        int sequence_number PK, FK
        int denial_reason_num PK
        int denial_reason FK
    }
    HOEPA_STATUS {
        int hoepa_status PK
        string hoepa_status_name
    }
    LIEN_STATUS {
        int lien_status PK
        string lien_status_name
    }
    EDIT_STATUS {
        int edit_status PK
        string edit_status_name
    }

    AGENCY ||--o{ RESPONDENT : has
    RESPONDENT ||--o{ APPLICATION : files
    LOCATION ||--o{ APPLICATION : locates
    STATE ||--o{ COUNTY : contains
    COUNTY ||--o{ LOCATION : contains
    MSAMD ||--o{ LOCATION : identifies
    LOAN_TYPE ||--o{ APPLICATION : classifies
    PROPERTY_TYPE ||--o{ APPLICATION : classifies
    LOAN_PURPOSE ||--o{ APPLICATION : classifies
    OWNER_OCCUPANCY ||--o{ APPLICATION : classifies
    PREAPPROVAL ||--o{ APPLICATION : classifies
    ACTION_TAKEN ||--o{ APPLICATION : records
    APPLICANT_ETHNICITY ||--o{ APPLICATION : classifies
    CO_APPLICANT_ETHNICITY ||--o{ APPLICATION : classifies
    APPLICANT_SEX ||--o{ APPLICATION : classifies
    CO_APPLICANT_SEX ||--o{ APPLICATION : classifies
    PURCHASER_TYPE ||--o{ APPLICATION : classifies
    HOEPA_STATUS ||--o{ APPLICATION : classifies
    LIEN_STATUS ||--o{ APPLICATION : classifies
    EDIT_STATUS ||--o{ APPLICATION : classifies
    APPLICATION ||--o{ APPLICANT_RACE_SELECTION : records
    APPLICANT_RACE_CODE ||--o{ APPLICANT_RACE_SELECTION : describes
    APPLICATION ||--o{ CO_APPLICANT_RACE_SELECTION : records
    CO_APPLICANT_RACE_CODE ||--o{ CO_APPLICANT_RACE_SELECTION : describes
    APPLICATION ||--o{ APPLICATION_DENIAL_REASON : records
    DENIAL_REASON_CODE ||--o{ APPLICATION_DENIAL_REASON : describes
```

## What changed from the 1NF diagram

- Keep application facts in `APPLICATION`, keyed by `sequence_number`. Move agency
  ownership to `RESPONDENT`, because `respondent_id -> agency_code`; `AGENCY` then
  holds the agency code/name dependency.
- Keep geography in `LOCATION`, keyed by `locationID`. Move state, county, and
  MSAMD names to their own code-keyed tables. `LOCATION` references the county
  and MSAMD; state is determined through county.
- For each code/name dependency, keep the code and its name together in its own
  lookup table. Applications store the code as a foreign key, not the name.
- Replace numbered applicant-race, co-applicant-race, and denial-reason fields
  with selection tables. Their composite primary keys preserve the slot number
  and the given dependencies; each selected code references its code/name table.
- Do not use a singleton "null fields" table. `edit_status` and
  `application_date_indicator` remain application attributes, even if the
  current source data happens to contain only NULL values.

## BCNF and losslessness notes

Each listed dependency is represented by a relation in which its determinant is
a primary key (or is implied by a key through the foreign-key path). Thus no
non-key determinant remains within a relation. I treated the application,
geography, code/name, and numbered-selection dependencies as their respective
source relations, rather than pretending all independent one-to-many facts
form one flat relation. The FD-based splits within each source relation are
lossless. Selection tables retain the application key and ordinal, so their
values can be reconstructed by pivoting on the ordinal if the original wide
CSV layout is needed. Joining multiple independent selection tables directly
into one flat result would produce a cross product and is not the intended
reconstruction.

An automated FD-closure, BCNF, and chase check parsed all 27 supplied
dependencies: all were preserved, no projected BCNF violations were found,
and the application, geography, applicant-race, co-applicant-race, and denial
reason source-relation decompositions each passed the lossless chase.

The supplied county dependency says `county_code -> county_name, state_code`.
Accordingly, `county_code` is the primary key here. This is appropriate for the
NJ-only source dataset. For a multi-state dataset, county codes are not globally
unique: revise that dependency to `(state_code, county_code) -> county_name`,
and use that pair as the county key and location foreign key.
