
# Setup

<!-- markdownlint-disable MD007-->

<!-- TOC -->

- [Setup](#setup)
    - [Set up local DBT](#set-up-local-dbt)
        - [Create virtual environement](#create-virtual-environement)
        - [Install DBT](#install-dbt)
        - [Check the installation has completed](#check-the-installation-has-completed)
        - [Run dbt debug to double check configuration](#run-dbt-debug-to-double-check-configuration)
        - [Configure dbt_project.yml and profiles.yml files](#configure-dbt_projectyml-and-profilesyml-files)
        - [Install Packages by  populating the packages.yml and running dbt deps](#install-packages-by--populating-the-packagesyml-and-running-dbt-deps)
        - [Authenticate to Big Query](#authenticate-to-big-query)
        - [After authenticating run dbt debug again to ensure your profile has been set up correctly](#after-authenticating-run-dbt-debug-again-to-ensure-your-profile-has-been-set-up-correctly)
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

## Set up local DBT

### Create virtual environement

```bash
python3 -m venv dbt_bq
```

### Install DBT

- set up a requirements file

```txt
dbt-core==1.8.2
dbt-bigquery==1.8.1
```

- run the requirements file

```bash
pip3 install -r requirements.txt
```

### Check the installation has completed

```bash
dbt --version

Core:
  - installed: 1.8.2
  - latest:    1.8.2 - Up to date!

Plugins:
  - bigquery: 1.8.1 - Up to date!
```

### Run `dbt debug` to double check configuration

```bash
10:51:05  Running with dbt=1.8.2
10:51:05  dbt version: 1.8.2
10:51:05  python version: 3.9.6
10:51:05  python path: /Users/angelina.teneva/Documents/repos/dbt_bq/bin/python
10:51:05  os info: macOS-14.4.1-arm64-arm-64bit
10:51:05  Using profiles dir at /Users/angelina.teneva/.dbt
10:51:05  Using profiles.yml file at /Users/angelina.teneva/.dbt/profiles.yml
10:51:05  Using dbt_project.yml file at /Users/angelina.teneva/Documents/repos/dbt_project.yml
10:51:05  Configuration:
10:51:05    profiles.yml file [ERROR not found]
10:51:05    dbt_project.yml file [ERROR not found]
10:51:05  Required dependencies:
10:51:05   - git [OK found]

10:51:05  Connection test skipped since no profile was found
10:51:05  2 checks failed:
10:51:05  dbt looked for a profiles.yml file in /Users/angelina.teneva/.dbt/profiles.yml, but did
not find one. For more information on configuring your profile, consult the
documentation:

https://docs.getdbt.com/docs/configure-your-profile


10:51:05  Project loading failed for the following reason:
 project path </Users/angelina.teneva/Documents/repos/dbt_project.yml> not found

(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro repos %
```

### Configure `dbt_project.yml` and `profiles.yml` files

```yml
--profiles.yml
dev_connection:
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: data-geeking-gcp
      dataset: the-look-dev
      location: EU
  target: dev
prod_connection:
  outputs:
    prod:
      type: bigquery
      method: oauth
      project: data-geeking-gcp
      dataset: the-look-prod
      location: EU
  target: prod
```

### Install Packages by  populating the `packages.yml` and running `dbt deps`

```yml
packages:
  - package: calogica/dbt_expectations
    version: 0.10.3

  - package: dbt-labs/dbt_utils
    version: 1.2.0

  - package: dbt-labs/codegen
    version: 0.12.1
```

```bash
(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro dbt-data-transformations % dbt deps
11:30:35  Running with dbt=1.8.2
11:30:35  [WARNING]: Deprecated functionality
The `tests` config has been renamed to `data_tests`. Please see
https://docs.getdbt.com/docs/build/data-tests#new-data_tests-syntax for more
information.
11:30:35  Updating lock file in file path: /Users/angelina.teneva/Documents/repos/dbt-data-transformations/package-lock.yml
11:30:35  Installing calogica/dbt_expectations
11:30:36  Installed from version 0.10.3
11:30:36  Up to date!
11:30:36  Installing dbt-labs/dbt_utils
11:30:36  Installed from version 1.2.0
11:30:36  Up to date!
11:30:36  Installing dbt-labs/codegen
11:30:36  Installed from version 0.12.1
11:30:36  Up to date!
11:30:36  Installing calogica/dbt_date
11:30:36  Installed from version 0.10.1
11:30:36  Up to date!
(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro dbt-data-transformations %
```

### Authenticate to Big Query

```bash
gcloud auth application-default login
```

### After authenticating run `dbt debug` again to ensure your profile has been set up correctly

```bash
(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro dbt-data-transformations % dbt debug
11:39:38  Running with dbt=1.8.2
11:39:38  dbt version: 1.8.2
11:39:38  python version: 3.9.6
11:39:38  python path: /Users/angelina.teneva/Documents/repos/dbt_bq/bin/python
11:39:38  os info: macOS-14.4.1-arm64-arm-64bit
11:39:39  Using profiles dir at /Users/angelina.teneva/Documents/repos/dbt-data-transformations
11:39:39  Using profiles.yml file at /Users/angelina.teneva/Documents/repos/dbt-data-transformations/profiles.yml
11:39:39  Using dbt_project.yml file at /Users/angelina.teneva/Documents/repos/dbt-data-transformations/dbt_project.yml
11:39:39  adapter type: bigquery
11:39:39  adapter version: 1.8.1
11:39:39  Configuration:
11:39:39    profiles.yml file [OK found and valid]
11:39:39    dbt_project.yml file [OK found and valid]
11:39:39  Required dependencies:
11:39:39   - git [OK found]

11:39:39  Connection:
11:39:39    method: oauth
11:39:39    database: data-geeking-gcp
11:39:39    execution_project: data-geeking-gcp
11:39:39    schema: the-look-dev
11:39:39    location: EU
11:39:39    priority: None
11:39:39    maximum_bytes_billed: None
11:39:39    impersonate_service_account: None
11:39:39    job_retry_deadline_seconds: None
11:39:39    job_retries: 1
11:39:39    job_creation_timeout_seconds: None
11:39:39    job_execution_timeout_seconds: None
11:39:39    timeout_seconds: None
11:39:39    client_id: None
11:39:39    token_uri: None
11:39:39    dataproc_region: None
11:39:39    dataproc_cluster_name: None
11:39:39    gcs_bucket: None
11:39:39    dataproc_batch: None
11:39:39  Registered adapter: bigquery=1.8.1
11:39:41    Connection test: [OK connection ok]

11:39:41  All checks passed!
(dbt_bq) angelina.teneva@Angelinas-MacBook-Pro dbt-data-transformations %
```

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
