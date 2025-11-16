{{
  config(
    materialized='table',
    alias='compare_multiple_table_columns'
  )
}}

{% set old_table = adapter.get_relation(
      database = "data-geeking-gcp",
      schema = "the_data_challenge",
      identifier = "data_engineer_jobs"
) -%}

{% set new_table = "data-geeking-gcp.the_data_challenge.data_engineer_jobs_copy" %} -- noqa: LT05

{{ audit_helper.quick_are_relations_identical(
    a_relation = old_table,
    b_relation = new_table,
    columns = ['job_title', 'salary_estimate', 'job_description']
) }}
