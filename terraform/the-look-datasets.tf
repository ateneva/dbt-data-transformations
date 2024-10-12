resource "google_bigquery_dataset" "the-look-prod" {
  dataset_id                  = "the_look_prod"
  friendly_name               = "the-look-prod"
  description                 = "This dataset has the transformations applied to The Look Ecoomerce"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_dataset" "the-look-dev" {
  dataset_id                  = "the_look_dev"
  friendly_name               = "the-look-dev"
  description                 = "This dataset tests the transformations applied to The Look Ecoomerce"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_dataset" "the-look-data-quality" {
  dataset_id                  = "the_look_data_quality"
  friendly_name               = "the-look-data-quality"
  description                 = "This dataset stores the data quality test results of the transformations applied to The Look Ecoomerce"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}
