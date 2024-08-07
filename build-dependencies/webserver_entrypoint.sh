#!/bin/bash

# AIRFLOW DB CHECK COMMAND SETTINGS
INPUT_MAX_RETRIES=120
INPUT_RETRY_DELAY=1
echo "$(date): Checking if the airflow database can be reached."
bash ./build/airflow_db_check.sh $INPUT_MAX_RETRIES $INPUT_RETRY_DELAY

# todo - check if NEW scheduler deployment is ready
# kubectl wait --for=condition=available deployment/airflow-scheduler
# todo - handle failures of db check better. Check state of other pod useing kubectl, and possible kill other pod


# Checking if migrations are complete (https://airflow.apache.org/docs/apache-airflow/stable/cli-and-env-variables-ref.html#check-migrations)
if [[ $RUN_DB_MIGRATION_BOOLEAN=='1' ]]; then
    sleep 30
    echo "$(date): Checking if migrations are complete."
    airflow db check-migrations
    echo "$(date): Database migrations are complete"
fi


# creating user for fab auth manager (https://airflow.apache.org/docs/apache-airflow-providers-fab/stable/auth-manager/webserver-authentication.html)
echo ${CREATE_WEBSERVER_USER_BOOLEAN}
if [[ $CREATE_WEBSERVER_USER_BOOLEAN==1 ]]; then
    echo "$(date): Creating admin user for webserver."
    airflow users create \
        --username ${AIRFLOW_WEBSERVER_USERNAME} \
        --password ${AIRFLOW_WEBSERVER_PASSWORD}  \
        --firstname admin \
        --lastname admin \
        --role Admin \
        --email ${AIRFLOW_WEBSERVER_EMAIL}
fi

# starting webserver (https://airflow.apache.org/docs/apache-airflow/2.9.0/start.html)
airflow webserver --port 80