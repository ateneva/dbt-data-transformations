{{
  config(
    materialized='table',
    alias='compare_multiple_query_columns'
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

{{ audit_helper.quick_are_queries_identical(
    query_a = old_query,
    query_b = new_query,
    columns = ['job_title', 'salary_estimate', 'job_description']
  )
}}
