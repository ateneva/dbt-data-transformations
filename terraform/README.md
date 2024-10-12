
# Updating resources with Terraform

## Locally

- Open Cloud Shell Editor in GCP

- Create a file with your terraform configuration

```json
resource "google_bigquery_dataset" "the-look-dev" {
  dataset_id                  = "the_look_dev"
  friendly_name               = "the-look-dev"
  description                 = "DEV: The Look Ecoomerce"
  location                    = "EU"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}
```

- Go back to Cloud Shell Terminal and execute the following commands

```bash
# initialize terraform
terraform init

# verify what is going to be changed
terraform plan

# apply the change if all okay
terraform apply
```

- Expected outcome

```plain
Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_bigquery_dataset.the-look-prod: Creating...
google_bigquery_dataset.the-look-data-quality: Creating...
google_bigquery_dataset.the-look-dev: Creating...
google_bigquery_dataset.the-look-dev: Creation complete after 2s [id=projects/data-geeking-gcp/datasets/the_look_dev]
google_bigquery_dataset.the-look-prod: Creation complete after 3s [id=projects/data-geeking-gcp/datasets/the_look_prod]
google_bigquery_dataset.the-look-data-quality: Creation complete after 4s [id=projects/data-geeking-gcp/datasets/the_look_data_quality]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
tenevaa21@cloudshell:~ (data-geeking-gcp)$
```

## Configs Automatic Deployment (GitHub Actions)
