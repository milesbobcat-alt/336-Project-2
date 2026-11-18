# CS 336 Project 2

## Run order

Run each command from this `Project 2` directory, using the same PostgreSQL
database for every step:

```text
psql -d your_database -f preliminary_upload.sql
psql -d your_database -f normalize_hmda_project2.sql
psql -d your_database -f part3.sql
psql -d your_database -f part4_checks.sql
psql -d your_database -f part4_export.sql
```

`preliminary_upload.sql` loads the CSV from the sibling `Project 1` folder and
creates `preliminary` with a generated `sequence_number` primary key. Re-run
this first script only when the staging and preliminary tables need to be
rebuilt; it drops and recreates both tables.

Step 2 creates the code/name lookup tables and copies all application rows.
Step 3 moves location facts and numbered race/denial values into child tables.
Step 4 applies data-validated constraints, runs three rejected-insert tests,
and reconstructs the original 78-column CSV from the normalized tables. The
export writes `hmda_reconstructed.csv` to the current directory.

The source `respondent_id` values do not determine `agency_code`: the CSV
contains counterexamples. Keep both columns in the application table rather
than imposing that unsupported dependency. County codes are state-scoped, so
the county key is `(state_code, county_code)`. Percentage fields use
unconstrained `NUMERIC` to preserve the source CSV's decimal precision.
Two populated MSAMD codes have blank names in the CSV; the lookup preserves
those names as NULL rather than imposing a non-NULL constraint.

`BCNF_ERD.md` is the current schema diagram. The existing PNG diagram exports
are earlier snapshots and do not show the final Parts 1–4 schema.
