# DBT Guidelines
<!-- TOC -->

- [DBT Guidelines](#dbt-guidelines)
    - [USEFUL CLI commands](#useful-cli-commands)
    - [Model Development guidelines](#model-development-guidelines)
    - [In-built Materialization](#in-built-materialization)
        - [What if the columns of my incremental model change?](#what-if-the-columns-of-my-incremental-model-change)
    - [Options for Data Quality Tests](#options-for-data-quality-tests)
        - [DBT Native Tests](#dbt-native-tests)
        - [DBT-utils package](#dbt-utils-package)
        - [DBT-expectations package](#dbt-expectations-package)
    - [Storing Failing Test records](#storing-failing-test-records)

<!-- /TOC -->

## USEFUL CLI commands

```bash
# docs
dbt docs generate && dbt docs serve          # see lineage in the generated URL

dbt debug                                    # check if your dbt setup is configured properly
dbt --version                                # check which dbt version you're running
dbt compile                                  # check for syntax errors 

# models
dbt run                                      # run all models for the project
dbt run -m <model name>                      # run only a specific model
dbt run -m +<model name>                     # run a model and its upstream dependencies
dbt run -m <model_name>+                     # run a model and its downstream dependencies
dbt run -m +<model name>+                    # run a model and its upstream and downstream dependencies
dbt run -m source:<source name>+             # run all models that depend on a given source
dbt run --full-refresh -m +<model name>      # re-create your incremental model

# As of dbt 1.0.3 you can also use the --select flag to run models
dbt run --select <model name>                # run only a specific model
dbt run --select +<model name>               # run a model and its upstream dependencies
dbt run --select <model_name>+               # run a model and its downstream dependencies
dbt run --select +<model name>+              # run a model and its upstream and downstream dependencies
dbt run --select source:<source name>+       # run all models that depend on a given source
dbt run --select <folder path>               # run all models in a specific directory
dbt run --select <folder path>.<sub foilder>.* # run all models in a specific sub-directory

# run all models except the specified one and its upstream dependencies
dbt run --select <folder path> --exclude +<model name> 
dbt run --full-refresh --select <model name> # re-create your incremental model

# tests
dbt test --select <model name>
dbt test --select <subdirectory_where_test_files_exist>
dbt test --select source:<source name>+      # run all tests defined on a source
dbt test --select <folder path>              # run all tests in a particular folder
dbt test --select <parent folder> --exclude <parent folder>.<subfolder>  # exclude tests from a sub-folder
```

More about CLI is [here](https://docs.getdbt.com/reference/node-selection/syntax).

---

## Model Development guidelines

- **USE** incremental models as much as possible to avoid processing huge volumes of data
  - in-built incremental
  - custom incremental models

- **TRY AVOID REPETITION** by making use of jinja templates - <https://docs.getdbt.com/guides/advanced/using-jinja>

---

## In-built Materialization

1. `view`         - equivalent to the combination of `DROP` and `CREATE VIEW AS`
2. `table`        - equivalent to the combination of `DROP` and `CREATE TABLE AS`
3. `incremental`  - equivalent to `INSERT` and `UPDATE` statements depending on if a record is found
4. `ephemeral`    - equivalent to a `CTE`

**PROs and CONs** of using each can be found on [dbt in-built materialization](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations)

### What if the columns of my incremental model change?

[With version 1.0, you can specify what should happen to your incremental model](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/configuring-incremental-models)
using `on_schema_change`

```bash
{{
    config(
        materialized='incremental',
        unique_key='date_day',
        on_schema_change='fail'
    )
}}
```

The possible values for `on_schema_change` are:

- `ignore`: Default behavior

- `fail`: Triggers an error message when the source and target schemas diverge

- `append_new_columns`: Append new columns to the existing table.
- This does not remove columns from the existing table that are not present in the new data

- `sync_all_columns`: Adds any new columns to the existing table, and removes any columns that are now missing.
  - This is inclusive of data type changes.

**NB: None of the `on_schema_change` behaviors backfill values in old records for newly added columns**

- If you need to populate those values, you need to trigger `dbt run --full-refresh --select <model name>`

---

## Options for Data Quality Tests

### DBT Native Tests

- generic tests - <https://docs.getdbt.com/docs/build/data-tests#generic-data-tests>
- singular tests - <https://docs.getdbt.com/docs/build/data-tests#singular-data-tests>

### DBT-utils package

- `dbt_utils` is an open-source package by `dbt-labs` that we've enabled in this repo. You can find more about the tests avaialable through this package in <https://hub.getdbt.com/dbt-labs/dbt_utils/latest/>

### DBT-expectations package

- `dbt_expectations` is an open-source package created by `catalogica` that we've enabled in this repo.
  
  Inspired by the Great Expectations package for Python, its intent is to allow dbt users to deploy GE-like tests in their data warehouse directly from dbt, vs having to add another integration with their data warehouse.

  You can find more about the pre-defined test it offers on <https://hub.getdbt.com/calogica/dbt_expectations/latest/>

## Storing Failing Test records

The failing records of every data quality test that runs in DBT are being stored by default in tables specified in `dbt_project.yml` file

- the table has the same schema structure as the original table

  - if there are no failing test, the table of the test is empty

- the table only contains the records that have failed to pass the pre-defined test

  - A test's results will always replace previous failures for the same test.

This makes it very easy to root-cause/identify where the data quality issues detected by the test are
