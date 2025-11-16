{{
  config(
    materialized='table',
    alias='compare_single_query_column'
  )
}}


{% set old_query %}
    SELECT *, CONCAT(company_name, location) AS unique_identifier
    FROM `data-geeking-gcp.the_data_challenge.data_engineer_jobs`
{% endset %}

{% set new_query %}
    SELECT *, CONCAT(company_name, location) AS unique_identifier
    FROM `data-geeking-gcp.the_data_challenge.data_engineer_jobs_copy`
{% endset %}

{{ audit_helper.compare_column_values(
    a_query = old_query,
    b_query = new_query,
    primary_key = 'unique_identifier',
    column_to_compare = 'job_title'
  )
}}


{#
    [{
    "column_name": "job_title",
    "match_status": "✅: perfect match",
    "count_records": "2830",
    "percent_of_total": "45.88"
    }, {
    "column_name": "job_title",
    "match_status": "❌: ‍values do not match",
    "count_records": "3338",
    "percent_of_total": "54.12"
    }]
#}
