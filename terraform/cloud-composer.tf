provider "google-beta" {
  project = "data-geeking-gcp"
  region  = "europe-west1"
}

resource "google_project_service" "composer_api" {
  provider = google-beta
  project = "data-geeking-gcp"
  service = "composer.googleapis.com"
  // Disabling Cloud Composer API might irreversibly break all other
  // environments in your project.
  disable_on_destroy = false
}

resource "google_service_account" "composer-service-account" {
  provider = google-beta
  account_id   = "composer-service-account"
  display_name = "airflow-cloud-composer-service-account"
}

resource "google_project_iam_member" "composer-service-account" {
  provider = google-beta
  project  = "data-geeking-gcp"
  member   = format("serviceAccount:%s", google_service_account.composer-service-account.email)
  // Role for Public IP environments
  role     = "roles/composer.worker"
}

resource "google_service_account_iam_member" "composer-service-account" {
  provider = google-beta
  service_account_id = google_service_account.composer-service-account.name
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-275589915638@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_composer_environment" "cloud_composer" {
  provider = google-beta
  name = "cloud-composer"
  config {
    software_config {
      image_version = "composer-2.8.7-airflow-2.7.3"
      pypi_packages = {
        dbt-core = "==1.8.2"
        dbt-bigquery = "==1.8.1"
        astronomer-cosmos = ">=1.0.2"
        }
    }
    node_config {
      service_account = google_service_account.composer-service-account.email
    }
  }
}
