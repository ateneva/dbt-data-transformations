
# Project

<!-- markdownlint-disable MD007 -->
<!-- TOC -->

- [Project](#project)
    - [Data Modelling Principles](#data-modelling-principles)
    - [Code Quality Principles](#code-quality-principles)
    - [Data Quality Principles](#data-quality-principles)
    - [Testing source freshnes](#testing-source-freshnes)
    - [Running tests on sources](#running-tests-on-sources)

<!-- /TOC -->

## Data Modelling Principles

The project uses [thelook_ecommerce public dataset](https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=thelook_ecommerce&page=dataset&invt=Abt44Q&project=data-geeking-gcp&ws=!1m4!1m3!3m2!1sbigquery-public-data!2sthelook_ecommerce)

---

## Code Quality Principles

[dbt pre-commit hooks](https://github.com/dbt-checkpoint/dbt-checkpoint) have been set up to check that:

- there are no compilation errors

- [no dbt script is directly referring to a table](https://github.com/dbt-checkpoint/dbt-checkpoint/blob/main/HOOKS.md#check-script-has-no-table-name)

- [script contains only existing sources or macros](https://github.com/dbt-checkpoint/dbt-checkpoint/blob/main/HOOKS.md#check-script-ref-and-source)

- [no semi-colons have been forgotten at the end of sql queries](https://github.com/dbt-checkpoint/dbt-checkpoint/blob/main/HOOKS.md#remove-script-semicolon)

```yaml
- repo: https://github.com/dbt-checkpoint/dbt-checkpoint
  rev: v1.2.1
  hooks:
    - id: dbt-compile
    - id: check-script-semicolon
    - id: check-script-ref-and-source
    - id: check-script-has-no-table-name
```

## Data Quality Principles

> The following packages are used to ensure that each model has a set of pre-defined data quality checks and business logic checks.
>> Additional source freshness checks are in place to ensure that the latest data is captured and updated in a timely manner.

```yaml
packages:
  - package: calogica/dbt_expectations
    version: 0.10.3

  - package: dbt-labs/dbt_utils
    version: 1.2.0
```

Each model should have a set of pre-defined:

- data integrity & consistency checks

    - checks for recent data

        - [expect_row_values_to_have_recent_data](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_row_values_to_have_recent_data)

        - [expect_grouped_row_values_to_have_recent_data](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_grouped_row_values_to_have_recent_data)

        - [expect_row_values_to_have_data_for_every_n_datepart](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_row_values_to_have_data_for_every_n_datepart)

    - checks for nulls and empty strings
        - [expect_column_values_to_be_null](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_values_to_be_null)

        - [expect_column_values_to_not_be_null](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_values_to_not_be_null)

        - [expect not null proportion](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#not_null_proportion-source)

        - [expect_column_values_to_not_be_empty_string](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#not_empty_string-source)

    - checks for unique values

        - [expect_column_values_to_be_unique](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_values_to_be_unique)

        - [expect_column_unique_value_count_to_be_between](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_unique_value_count_to_be_between)

        - [expect_column_proportion_of_unique_values_to_be_between](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_proportion_of_unique_values_to_be_between)

        - [expect_compound_columns_to_be_unique](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_compound_columns_to_be_unique)

        - [expect unique combination of columns](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#unique_combination_of_columns-source)

        - [expect_column_distinct_count_to_equal_other_table](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_distinct_count_to_equal_other_table)

    - checks for referential integrity

        - [expect_referential_integrity_where](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#relationships_where-source)

        - [strict referential integrity](https://docs.getdbt.com/reference/resource-properties/data-tests?version=1.11#relationships)

- business logic checks

    - [expect_column_values_to_be_in_set](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#expect_column_values_to_be_in_set)

    - [not accepted values](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#not_accepted_values-source)

    - [expect_column_values to be within a given range](https://github.com/dbt-labs/dbt-utils/tree/1.3.3/#accepted_range-source)

    - [expect_column_values_to_be_between](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_values_to_be_between)

    - [expect_column_max_to_be_between](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_max_to_be_between)

    - [expect_column_min_to_be_between](https://github.com/metaplane/dbt-expectations/tree/0.10.10/#expect_column_min_to_be_between)

## Testing source freshnes

```bash
dbt source freshness
```

```plain
16:47:10  Found 1 test, 7 sources, 875 macros
16:47:10
16:47:11  Concurrency: 1 threads (target='dev')
16:47:11
16:47:11  1 of 1 START freshness of thelook_ecommerce.orders ............................. [RUN]
16:47:11  1 of 1 PASS freshness of thelook_ecommerce.orders .............................. [PASS in 0.38s]
16:47:11
16:47:11  Finished running 1 source in 0 hours 0 minutes and 1.51 seconds (1.51s).
16:47:12  Done.
```

## Running tests on sources

```bash
# run test on ALL sources
dbt test --select "source:*"

# run the tests on a specific source
dbt test --select "source:thelook_ecommerce"
```
