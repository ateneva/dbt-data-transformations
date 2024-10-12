
# Setup
<!-- TOC -->

- [Setup](#setup)
  - [Set up local Airflow instance](#set-up-local-airflow-instance)
    - [Set up directory with the following structure and contents](#set-up-directory-with-the-following-structure-and-contents)
    - [Build a custom docker image that extends the official one](#build-a-custom-docker-image-that-extends-the-official-one)
    - [Use the docker-compose.yml available in the official documentation](#use-the-docker-composeyml-available-in-the-official-documentation)
    - [Push the image to Artefact registry](#push-the-image-to-artefact-registry)
    - [Spin up the local instance](#spin-up-the-local-instance)
  - [Set up local DBT](#set-up-local-dbt)
    - [Create virtual environement](#create-virtual-environement)
    - [Install DBT](#install-dbt)
    - [Check the installation has completed](#check-the-installation-has-completed)
    - [Run dbt debug to double check configuration](#run-dbt-debug-to-double-check-configuration)
    - [Configure dbt_project.yml and profiles.yml files](#configure-dbt_projectyml-and-profilesyml-files)
    - [Install Packages by  populating the packages.yml and running dbt deps](#install-packages-by--populating-the-packagesyml-and-running-dbt-deps)
    - [Authenticate to Big Query](#authenticate-to-big-query)
    - [After authenticating run dbt debug again to ensure your profile has been set up correctly](#after-authenticating-run-dbt-debug-again-to-ensure-your-profile-has-been-set-up-correctly)
  - [Linting](#linting)

<!-- /TOC -->

## Set up local Airflow instance

### Set up directory with the following structure and contents

```plain
airflow
├── Dockerfile
├── docker-compose.yml
└── requirements.txt
```

- `Dockerfile`

```Dockerfile
FROM apache/airflow:slim-2.9.3-python3.9
COPY requirements.txt .
RUN pip install -r requirements.txt
```

- `requirements.txt`

```txt
dbt-core==1.8.2
dbt-bigquery==1.8.1
astronomer-cosmos>=1.0.2
```

### Build a custom docker image that extends the official one

```bash
docker build . --tag dbt-cosmos
```

### Use the `docker-compose.yml` available in the [official documentation](https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml)

- replace the `image` with the one you've built

```yml
x-airflow-common:
  &airflow-common
  image: ${AIRFLOW_IMAGE_NAME:-dbt-cosmos}
  environment:
  ...
```

### Push the image to Artefact registry

```bash
# authenticate and configure docker
gcloud auth login
gcloud auth configure-docker europe-west1-docker.pkg.dev

# tag image
docker tag `SOURCE-IMAGE` `LOCATION`-docker.pkg.dev/`PROJECT-ID`/`REPOSITORY`/`IMAGE`:`TAG`

docker tag dbt-cosmos europe-west1-docker.pkg.dev/data-geeking-gcp/dbt-cosmos/dbt-cosmos

# push the image
docker push `LOCATION`-docker.pkg.dev/`PROJECT-ID`/`REPOSITORY`/`IMAGE`
```

### Spin up the local instance

```bash
docker compose --file docker-compose.yml up
```

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

## Linting

The following linters are in place

- SQL linting with [custom configuration](https://docs.sqlfluff.com/en/stable/reference/rules.html#) for `.sqlfluff`

- YAML linting with [custom configuration](https://yamllint.readthedocs.io/en/stable/configuration.html) for `.yamllint`

- Python linting with default configuration via `pylint`

- Markdwown linting with default configuration with `pymarkdownlint`

### SQL Linting

To see you your SQL is compliant to the defined standard, you can run the following commands

```bash
# lint a specific file
sqlfluff lint path/to/file.sql

# lint a file directory
sqlfluff lint directory/of/sql/files

# let the linter fix your code
sqlfluff fix folder/model.sql
```

- SQL linting is also enforced via `sqlfluff` [pre-commit hooks](https://docs.sqlfluff.com/en/latest/production/pre_commit.html)

### YAML Linting

```bash
# check which files will be linted by default
yamllint --list-files .

# lint a specific file
yamllint my_file.yml

# OR
yamllint .
```

### pre-commit hooks have been set up in this repo to help check for

- automated fix of missing lines at the end of file
- automated fix of trailing whitespaces and files
- autoamted detection of violations of sql standards

```bash

# install the githook scripts
pre-commit install

# run against all existing files
pre-commit run --all-files
```
