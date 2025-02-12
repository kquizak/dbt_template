{% macro create_stage(stage_name, integration_name, url, file_format) %}
    CREATE STAGE IF NOT EXISTS {{ stage_name }}
    STORAGE_INTEGRATION = {{ integration_name }}
    URL = '{{ url }}'
    FILE_FORMAT = (TYPE = {{ file_format }});
{% endmacro %}