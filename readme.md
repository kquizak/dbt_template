# get airflow
> docker pull apache/airflow
# build image 
docker build --pull --rm -f 'Dockerfile' -t 'dbttemplate:latest' '.' 
# start container
> docker run --rm -d -v airflow:/opt/airflow -p 8080:8080/tcp dbttemplate:latest 
