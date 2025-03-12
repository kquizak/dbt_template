from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
from airflow.models import Variable

# Define default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 3, 9),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'dbt_run_dag',
    default_args=default_args,
    description='A simple DAG to run dbt',
    schedule_interval=timedelta(days=1),  # Adjust the schedule as needed
)

#if variables defined then use those else use those defined in env.sh
dbt_run_command = """
if [ -z "$(echo {{ var.get('DBT_GCS_STAGE', '') }})" ]; then
    source /app/env.sh
else
    export SNOWFLAKE_ACCOUNT={{ var.get('SNOWFLAKE_ACCOUNT', '') }}
    export SNOWFLAKE_USER={{ var.get('SNOWFLAKE_USER', '') }}
    export SNOWFLAKE_PASSWORD={{ var.get('SNOWFLAKE_PASSWORD', '') }}
    export SNOWFLAKE_ROLE={{ var.get('SNOWFLAKE_ROLE', '') }}
    export SNOWFLAKE_DATABASE={{ var.get('SNOWFLAKE_DATABASE', '') }}
    export SNOWFLAKE_WAREHOUSE={{ var.get('SNOWFLAKE_WAREHOUSE', '') }}
    export DBT_GCS_STAGE={{ var.get('DBT_GCS_STAGE', '') }}
fi

dbt run --project-dir /app/snowflake_pipe --profiles-dir /home/airflow/.dbt
"""

# Define the BashOperator to run the dbt command
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command=dbt_run_command,
    dag=dag,
)

# Set task dependencies (if any)
