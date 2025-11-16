# Setting up local Airflow instance

<!-- markdownlint-disable MD007-->

<!-- TOC -->

- [Setting up local Airflow instance](#setting-up-local-airflow-instance)
    - [Set up directory with the following structure and contents](#set-up-directory-with-the-following-structure-and-contents)
    - [Build a custom docker image that extends the official one](#build-a-custom-docker-image-that-extends-the-official-one)
    - [Use the docker-compose.yml available in the official documentation](#use-the-docker-composeyml-available-in-the-official-documentation)
    - [Push the image to Artefact registry](#push-the-image-to-artefact-registry)
    - [Spin up the local instance](#spin-up-the-local-instance)
    - [Gracefully stop the local instance](#gracefully-stop-the-local-instance)

<!-- /TOC -->

## Set up directory with the following structure and contents

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

## Build a custom docker image that extends the official one

```bash
docker build . --tag dbt-cosmos
```

## Use the `docker-compose.yml` available in the [official documentation](https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml)

- replace the `image` with the one you've built

```yml
x-airflow-common:
  &airflow-common
  image: ${AIRFLOW_IMAGE_NAME:-dbt-cosmos}
  environment:
  ...
```

## Push the image to Artefact registry

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

## Spin up the local instance

You can test a DAG locally by spinning up a local airflow instance using `docker compose`

```bash
docker compose --file docker-compose.yml up
```

You should be able to access Airflow UI on <http://localhost:8080>

## Gracefully stop the local instance

Once finished testing, you can bring down your airflow instance by running

```bash
docker compose down
```
