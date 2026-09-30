from datetime import datetime
from airflow.sdk import dag, task

@dag(
    schedule = None,
    start_date = datetime(2026, 1, 1),
    catchup = False
)
def hello_aml():
    @task
    def ping():
        print("AML/KYC pipeline: dziala")
    ping()

hello_aml()