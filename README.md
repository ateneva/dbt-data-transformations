
# Setup

<!-- markdownlint-disable MD007-->

<!-- TOC -->

- [Setup](#setup)
    - [Enforcing Code Quality](#enforcing-code-quality)
        - [SQL Linting](#sql-linting)
        - [YAML Linting](#yaml-linting)
        - [pre-commit hooks have been set up in this repo to check and fix for](#pre-commit-hooks-have-been-set-up-in-this-repo-to-check-and-fix-for)
- [Data Modelling Principles & Guidelines](#data-modelling-principles--guidelines)
    - [Be Analyst Friendly](#be-analyst-friendly)
    - [Be Subject-Oriented](#be-subject-oriented)
    - [Be Relevant](#be-relevant)
    - [Be Cost Efficient](#be-cost-efficient)
    - [Be Easy to Maintain](#be-easy-to-maintain)
    - [Avoid complex dependencies](#avoid-complex-dependencies)

<!-- /TOC -->

## Enforcing Code Quality

The following linters are in place

- SQL linting with [custom configuration](https://docs.sqlfluff.com/en/stable/reference/rules.html#) for `.sqlfluff`

- YAML linting with [custom configuration](https://yamllint.readthedocs.io/en/stable/configuration.html) for `.yamllint`

- Python linting with default configuration via `pylint`

- Markdown linting with default configuration with `pymarkdownlint`

### SQL Linting

To see if your SQL is compliant to the defined standard, you can run the following commands

```bash
# lint a specific file
sqlfluff lint path/to/file.sql

# lint a file directory
sqlfluff lint directory/of/sql/files

# let the linter fix your code
sqlfluff fix folder/model.sql
```

- SQL linting (and fixing) is enforced via [pre-commit hooks](https://docs.sqlfluff.com/en/latest/production/pre_commit.html) for `sqlfluff`

### YAML Linting

```bash
# check which files will be linted by default
yamllint --list-files .

# lint a specific file
yamllint my_file.yml

# OR
yamllint .
```

### pre-commit hooks have been set up in this repo to check and fix for

- missing lines at the end
- trailing whitespaces
- violations of sql standards

When working with the repo, make sure you've got the pre-commit installed so that they run upon your every commit

```bash
# install the githook scripts
pre-commit install

# run against all existing files
pre-commit run --all-files
```

---

# Data Modelling Principles & Guidelines

The DWH transformations of the Look e-commerce data were architected under the following principles and guidelines

## Be Analyst Friendly

- Analysts shouldn't have to do multiple joins to retrieve meaningful data

## Be Subject-Oriented

- Tables are organized around major topics of interest, such as customers, products, orders

- Each subject represents One-Big-Table with nested arrays and structs
  - child objects should never be orphans
  - child objects will always be queried within the context of the parent object

## Be Relevant

- Data should reflect how current underlying platform functions

- Data should reflect the topics of interest to business

## Be Cost Efficient

- Only process pieces of information that have changed

- Avoid scanning too much data per run

## Be Easy to Maintain

- Backfilling historical data should be possible via the scheduled run without the need for extra code adjustments

- Changes in data should be easy to trace and audit

## Avoid complex dependencies

- Processing by topic instead of monolitic schedules of all topics
