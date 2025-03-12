FROM apache/airflow:latest

# Copy the contents of the current directory to /app in the container
COPY . /app

# Set the working directory to /app
WORKDIR /app

# Switch to the root user to perform operations that require elevated permissions
USER root

# Create the .dbt directory and set the correct permissions
RUN mkdir -p /home/airflow/.dbt && \
    cp /app/profiles.yml /home/airflow/.dbt/profiles.yml && \
    chmod -R 775 /home/airflow/.dbt && \
    chmod -R 775 /app && \
    python -m pip install dbt-core dbt-snowflake && \
    apt-get update && \
    apt-get -y install git && \
    apt-get clean && \
    chmod +x /app/env.sh && \
    mkdir -p /home/airflow/.gcp && \
    mv /app/free-tier-295114-ac4c7b23fc5a.json /home/airflow/.gcp/


#repair dbt project
RUN dbt deps --project-dir /app/snowflake_pipe
RUN dbt clean --profiles-dir /home/airflow/.dbt --project-dir /app/snowflake_pipe
#RUN dbt compile --profiles-dir /home/airflow/.dbt --project-dir /app/snowflake_pipe

#copy dags into container
COPY airflow/dags /opt/airflow/dags/
RUN chown -R airflow:root /opt/airflow/dags

# Command to run Airflow in standalone mode
CMD ["airflow", "standalone"]
