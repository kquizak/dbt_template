from airflow import DAG
from airflow.providers.google.cloud.sensors.gcs import GCSObjectsWithPrefixExistenceSensor
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago

# Define Variables
GCS_BUCKET = "snow_source_data"
GCS_PREFIX = "/"  # Folder inside the bucket where JSON files arrive
DBT_PROJECT_DIR = "/app/snowflake_pipe"
DBT_PROFILES_DIR = "/home/airflow/.dbt"

# Define the DAG
with DAG(
    "gcs_dbt_trigger",
    schedule_interval=None,  # Only run when triggered by sensor
    start_date=days_ago(1),
    catchup=False,
) as dag:

        # Check if objects exist in GCS bucket with a specific prefix
    gcs_sensor = GCSObjectsWithPrefixExistenceSensor(
        task_id="check_new_json_arival",
        bucket=GCS_BUCKET,  # Replace with your GCS bucket
        prefix="",  # Prefix to check
        google_cloud_conn_id="google_cloud_default",
        deferrable = True
    ) 

    # Step 2: Run dbt if JSON files are found
    run_dbt = BashOperator(
        task_id="run_dbt",
        bash_command=f"""
        source /app/env.sh
        dbt run --project-dir {DBT_PROJECT_DIR} --profiles-dir {DBT_PROFILES_DIR}
        """,
    )

    # Define task sequence
    gcs_sensor >> run_dbt
