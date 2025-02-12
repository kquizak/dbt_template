{% macro create_gcs_stage(stage_name, integration_name, gcs_url, file_format) %}
    CREATE STAGE IF NOT EXISTS {{ stage_name }}
    STORAGE_INTEGRATION = {{ integration_name }}
    URL = '{{ gcs_url }}'
    FILE_FORMAT = (TYPE = {{ file_format }});
{% endmacro %}