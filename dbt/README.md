# DBT Guidelines

<!-- TOC -->

- [DBT Guidelines](#dbt-guidelines)
  - [DBT DEFAULT FOLDER STRUCTURE](#dbt-default-folder-structure)
  - [USEFUL CLI commands](#useful-cli-commands)
  - [Model Development guidelines](#model-development-guidelines)
  - [Native Materialization Strategies](#native-materialization-strategies)
    - [What if the columns of my incremental model change?](#what-if-the-columns-of-my-incremental-model-change)
  - [JINJA Templates](#jinja-templates)
    - [MACROS](#macros)
  - [Using Packages](#using-packages)
    - [dbt_date](#dbt_date)
    - [codegen](#codegen)
    - [dbt-audit-helper](#dbt-audit-helper)
    - [dbt_project_evaluator](#dbt_project_evaluator)
  - [Options for Data Quality Tests](#options-for-data-quality-tests)
    - [DBT DATA Tests](#dbt-data-tests)
    - [DBT-utils package](#dbt-utils-package)
    - [DBT-expectations package](#dbt-expectations-package)
  - [Storing Failing Test records](#storing-failing-test-records)
  - [Configuring Test Severity](#configuring-test-severity)
    - [at the poject level](#at-the-poject-level)
    - [at the model level](#at-the-model-level)
  - [Testing Guidelines](#testing-guidelines)

<!-- /TOC -->
## DBT DEFAULT FOLDER STRUCTURE

```bash

```

## [USEFUL CLI commands](https://docs.getdbt.com/reference/dbt-commands)

```bash
# docs
dbt docs generate                            # prodcues `manifest.json` and `catalog.json`
dbt docs generate --no-compile               # skip project re-compilation for `manifest.json`
dbt docs generate --empty-catalog            # skip database queries for `catalog.json`
dbt docs serve                               # starts a webserver on port 8080 to serve your documentation locally

dbt docs generate && dbt docs serve          # see lineage in the generated URL

dbt debug                                    # check if your dbt setup is configured properly
dbt --version                                # check which dbt version you're running
dbt compile                                  # generates executable SQL from model, test, and analysis
dbt deps                                     # updates to latest version of dependencies listed in packages.yml

dbt source freshness                         # determine freshnesss of all defined sources

dbt build                                    # run models, tests, snapshots and seeds at once
dbt build --fail-fast                        # stops execution after encountering the first error

# models
dbt run                                      # run all models for the project
dbt run --fail-fast                          # stops execution after encountering the first error
dbt run -m <file name>                       # run only a specific model
dbt run -m +<file name>                      # run a model and its upstream dependencies
dbt run -m <file name>+                      # run a model and its downstream dependencies
dbt run -m +<file name>+                     # run a model and its upstream and downstream dependencies
dbt run -m source:<source name>+             # run all models that depend on a given source
dbt run --full-refresh -m +<file name>       # re-create your incremental model

# As of dbt 1.0.3 you can also use the --select flag to run models
dbt run --select <file name>                  # run only a specific model
dbt run --select +<file name>                 # run a model and its upstream dependencies
dbt run --select <file name>+                 # run a model and its downstream dependencies
dbt run --select +<file name>+                # run a model and its upstream and downstream dependencies
dbt run --select source:<source name>+        # run all models that depend on a given source
dbt run --select <folder path>                # run all models in a specific directory
dbt run --select <folder path>.<sub foilder>.* # run all models in a specific sub-directory

# run all models except the specified one and its upstream dependencies
dbt run --select <folder path> --exclude +<model name> 
dbt run --full-refresh --select <model name> # re-create your incremental model

# tests
dbt test --select <model name>
dbt test --select <subdirectory_where_test_files_exist>
dbt test --select <folder path>                # run all tests in a particular folder
dbt test --select <parent folder>.<subfolder>  # run all tests in a particularsub folder
dbt test --select <parent folder> --exclude <parent folder>.<subfolder>  # exclude tests from a sub-folder

dbt test --select source:*                     # run ONLY tests defined on sources
dbt test --select --exclude source:*           # run ONLY tests defined on models
dbt test --select source:<source name>         # run all tests defined on a source and all its tables
```

More about CLI is [here](https://docs.getdbt.com/reference/node-selection/syntax).

---

## Model Development guidelines

- **DO USE** [`source`](https://docs.getdbt.com/reference/dbt-jinja-functions/source) and [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) functions to ensure the data lineage of your models is properly captured in the `manifest` file

- **TRY AVOIDING REPETITION** by making use of jinja templates - <https://docs.getdbt.com/guides/advanced/using-jinja>

- **DO USE** [incremental models](https://docs.getdbt.com/docs/build/incremental-models) as much as possible to avoid processing huge volumes of data

- **DO explore** what [`incremental_strategy` configs](https://docs.getdbt.com/docs/build/incremental-strategy) are available for your database and consider their impact on cost generation

- **DO** stick to the `SQL Best Practices` applicable to your database provider (DBT does not solve for bad SQL/SQL anti-pattens)

---

## Native Materialization Strategies

1. `view`         - equivalent to the combination of `DROP` and `CREATE VIEW AS`
2. `table`        - equivalent to the combination of `DROP` and `CREATE TABLE AS`
3. `incremental`  - equivalent to `INSERT` and `UPDATE` statements depending on if a record is found
4. `ephemeral`    - equivalent to a `CTE`

5. `materialized_views` - combine the query performance of a table with the data freshness of a view; [as of version 1.6](https://docs.getdbt.com/blog/announcing-materialized-views)

```bash
{{
config(
    materialized = 'materialized_view',
)
}}
```

**PROs and CONs** of using each can be found on <https://docs.getdbt.com/docs/building-a-dbt-project/building-models/materializations>

### What if the columns of my incremental model change?

[With version 1.0, you can specify what should happen to your incremental model](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/configuring-incremental-models)
using `on_schema_change`

```bash
{{
    config(
        materialized='incremental',
        incremental_strategy = 'merge',
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

## [JINJA Templates](https://docs.getdbt.com/docs/build/jinja-macros)

- `{% … %}` is used for statements
These perform any function programming such as setting a variable or starting a for loop.

- `{{ … }}` is used for expressions
These will print text to the rendered file. In most cases in dbt, this will compile your Jinja to pure SQL.

- `{# … #}` is used for comments
This allows us to document our code inline. This will not be rendered in the pure SQL that you create when you run dbt compile or dbt run.

### [MACROS](https://docs.getdbt.com/docs/build/jinja-macros#macros)

- Macros serve as functions.

- They are used for setting up generic logic that can be re-used throughout your project

- In that sense they DO enable writing `DRY` code (`DO NOT REPEAT YOURSELF`)

- NB! Converting everything to macros, however, can make your code `less readable` and ultimately less maintainable

---

## [Using Packages](https://docs.getdbt.com/docs/build/packages#how-do-i-add-a-package-to-my-project)

### [dbt_date]((<https://hub.getdbt.com/calogica/dbt_date/latest/>))

- `dbt_date` is an open-source package created by [`catalogica`](https://hub.getdbt.com/calogica/) that offers a number of macros that allow you to easily calculate time between different dates, making your code easily portable between differnet SQL dialects

### [codegen](https://hub.getdbt.com/dbt-labs/codegen/latest/)

- `codegen` is a handy open-source package created by [`dbt-labs`] that allows the automatic generation of `.yml` files describing your models

  Thanks to [`persist_docs`](https://docs.getdbt.com/reference/resource-configs/persist_docs) defined in `dbt_project` file the descriptions you provide in your `.yml` files will be persisted as metadata in the database you use

```bash
      +persist_docs:
        relation: true
        columns: true
```

### [dbt-audit-helper](https://hub.getdbt.com/dbt-labs/audit_helper/latest/)

- `dbt-audit-helper` by [`dbt-labs`] provides a set of macros to compare data audits and can be incredibly useful when migrating from one database to another

```sql
{% set old_relation = adapter.get_relation(
      database = "old_database",
      schema = "old_schema",
      identifier = "fct_orders"
) -%}

{% set dbt_relation = ref('fct_orders') %}
```

- `compare_relations` - returns a summary of the count of rows that are unique to a, unique to b, identical + % diff

```python
{{ audit_helper.compare_relations(
    a_relation = old_relation,
    b_relation = dbt_relation,
    exclude_columns = ["loaded_at"],
    primary_key = "order_id"
) }}
```

- `compare_row_counts` - simple comparison of the row counts in two relations

```python
{{ audit_helper.compare_row_counts(
    a_relation = old_relation,
    b_relation = dbt_relation
) }}
```

- `compare_which_columns_differ` - which common columns between two relations contain any value level changes

```python
{{ audit_helper.compare_which_columns_differ(
    a_relation = old_relation,
    b_relation = dbt_relation,
    exclude_columns = ["loaded_at"],
    primary_key = "order_id"
) }}
```

- `compare_all_columns` - Similar to compare_column_values, except it can be used to compare `all columns' values` across two relations.

```python
{{ audit_helper.compare_all_columns(
    a_relation = old_relation,
    b_relation = dbt_relation,
    primary_key = "order_id"
) }}
```

### [dbt_project_evaluator](https://hub.getdbt.com/dbt-labs/dbt_project_evaluator/latest/)

- `dbt_project_evaluator` by [`dbt-labs`] helps you determine if your dbt setup/usage is in line with best practices in terms of:

  - Modeling
  - Testing
  - Documentation
  - Structure
  - Performance
  - Governance

---

## Options for Data Quality Tests

### [DBT DATA Tests](https://docs.getdbt.com/docs/build/data-tests)

- singular tests - <https://docs.getdbt.com/docs/build/data-tests#singular-data-tests>

```sql
select
    order_id,
    sum(amount) as total_amount
from {{ ref('fct_payments' )}}
group by 1
having total_amount < 0
```

- generic `out-of-the-box` tests - <https://docs.getdbt.com/docs/build/data-tests#generic-data-tests>

```yml
version: 2

models:
  - name: orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed', 'returned']
      - name: customer_id
        tests:
          - relationships:
              to: ref('customers')
              field: id
```

- defining your own generic tests - <https://docs.getdbt.com/best-practices/writing-custom-generic-tests>

```sql
{% test is_even(model, column_name) %}
with validation as (
    select
        {{ column_name }} as even_field
    from {{ model }}
),
validation_errors as (
    select
        even_field
    from validation
    -- if this is true, then even_field is actually odd!
    where (even_field % 2) = 1
)
select *
from validation_errors
{% endtest %}
```

### [DBT-utils package](<https://hub.getdbt.com/dbt-labs/dbt_utils/latest/>)

- `dbt_utils` is an open-source package by `dbt-labs` that is enabled in this repo.

Some of its most useful tests are:

```yml
models:
  - name: model_name
    columns:
      - name: column_name
        tests:
          - dbt_utils.not_empty_string
```

```yml
models:
  - name: my_model
    columns:
      - name: id
        tests:
          - dbt_utils.not_null_proportion:
              at_least: 0.95
```

```yml
models:
  - name: model_name
    columns:
      - name: id
        tests:
          - dbt_utils.relationships_where:
              to: ref('other_model_name')
              field: client_id
              from_condition: id <> '-1'
              to_condition: created_date >= '2020-01-01'
```

```yml
models:
  - name: orders
    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - country_code
            - order_id
```

### [DBT-expectations package](<https://hub.getdbt.com/calogica/dbt_expectations/latest/>)

- `dbt_expectations` is an open-source package created by `catalogica` that is enabled in this repo.
  
  Inspired by the Great Expectations package for Python, its intent is to allow dbt users to deploy GE-like tests in their data warehouse directly from dbt, vs having to add another integration with their data warehouse.

Some useful tests are :

```yml
tests:
  - dbt_expectations.expect_row_values_to_have_recent_data:
      datepart: day
      interval: 1
      row_condition: 'id is not null' #optional
```

```yml
tests:
  - dbt_expectations.expect_column_values_to_not_be_null:
      row_condition: "id is not null" # (Optional)
```

```yml
tests:
  - dbt_expectations.expect_column_values_to_be_unique:
      row_condition: "id is not null" # (Optional)
```

```yml
tests:
  - dbt_expectations.expect_column_values_to_match_regex:
      regex: "[at]+"
      row_condition: "id is not null" # (Optional)
      is_raw: True # (Optional)
      flags: i # (Optional)
```

```yml
models: # or seeds:
  - name: my_model
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1 # (Optional)
          max_value: 4 # (Optional)
          group_by: [group_id, other_group_id, ...] # (Optional)
          row_condition: "id is not null" # (Optional)
          strictly: false # (Optional. Adds an 'or equal to' to the comparison operator for min/max)
```

```yml
tests:
  - dbt_expectations.expect_compound_columns_to_be_unique:
      column_list: ["date_col", "col_string_b"]
      ignore_row_if: "any_value_is_missing" # (Optional. Default is 'all_values_are_missing')
      quote_columns: false # (Optional)
      row_condition: "id is not null" # (Optional)
```

## [Storing Failing Test records](https://docs.getdbt.com/docs/build/data-tests#storing-test-failures)

DBT has been configurted to store the failing records of every data quality test

```yml
data_tests:
  +store_failures: true  
  +schema: the_look_data_quality
```

- the table has the same schema structure as the `model` table

  - if there are no failing tests, the table of the test is empty

- the table only contains the records that have failed to pass the pre-defined test

  - A test's results will always replace previous failures for the same test.

This makes it very easy to root-cause/identify where the data quality issues detected by the test are

## [Configuring Test Severity](https://docs.getdbt.com/reference/resource-configs/severity)

- `severity`: error or warn (default: error)
- `error_if`: conditional expression (default: !=0)
- `warn_if`: conditional expression (default: !=0)

Conditional expressions can be any comparison logic that is supported by your SQL syntax with an integer number of failures:  `> 5`, `= 0`, `between 5 and 10`, and so on.

### at the poject level

```yml
tests:
  +severity: warn  # all tests

```

### at the model level

```yml
models:
  - name: large_table
    columns:
      - name: slightly_unreliable_column
        tests:
          - unique:
              config:
                severity: error
                error_if: ">1000"
                warn_if: ">10"
```

```sql
-- tests/filename.sql
{{ config(error_if = '>50') }}

select ...
```

```sql
-- macros/filename.sql

{% test <testname>(model, column_name) %}

{{ config(severity = 'warn') }}

select ...

{% endtest %}
```

## Testing Guidelines

- Tests on one database object can be what should be contained within the columns, what should be `the constraints of the table, or simply what is the grain.`

- Test h`ow one database object refers to another` database object by checking data in one table and comparing it to another table that is either a source of truth or is less modified, has less joins

- Test `something unique about your data` like specific business logic.

- Test the `freshness of your raw source data` (pipeline tests) to ensure models don’t run on stale data
