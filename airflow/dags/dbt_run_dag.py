from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# Define default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2025, 3, 1),
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


# Define the BashOperator to run the dbt command
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command='source /app/env.sh && dbt run --project-dir /app/snowflake_pipe --profiles-dir /home/airflow/.dbt',
    dag=dag,
)

# Set task dependencies (if any)
# In this simple example, there are no dependencies
