import json
import logging
from operator import truediv
import requests
logger = logging.getLogger()
logger.setLevel(logging.INFO)

GITHUB_REPO_URL='https://github.com/rhabed/pdf_merger'
GIT_REPO_REGISTRATION_URL='https://api.github.com/repos/rhabed/pdf_merger/actions/runners/registration-token'
GITHUB_USER='rhabed'
GITHUB_USER_TOKEN='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'
CODEFRESH_API_KEY='6281d837131a03139abcd183.3b769ac654a1abb4f465a654fdbab2dc'
CODEFRESH_PIPELINE_API_RUN='https://g.codefresh.io/api/pipelines/run'
PIPELINE_ID='6284820519fe92c9a4f89405'

BRANCH_STR= "main"
TRIGGER_STR="my-trigger"
VARIABLES_OBJ={'ACTION':'deploy', 'HOST_ID':'NA'}
NO_CACHE_BOOL="true"
NO_CF_CACHE_BOOL="true"
RESET_VOLUME_BOOL="true"
ENABLE_NOTIFICATIONS_BOOL="true"
DATA = {"branch":"main","trigger":"my-trigger", "variables":{VARIABLES_OBJ}}
## ,"variables":${VARIABLES_OBJ},"options":{"noCache":${NO_CACHE_BOOL},"noCfCache":${NO_CF_CACHE_BOOL},"resetVolume":${RESET_VOLUME_BOOL},"enableNotifications":${ENABLE_NOTIFICATIONS_BOOL}}}'

def initiate_pipeline():
    headers = {
    'Authorization': f"{CODEFRESH_API_KEY}",
    'Content-Type': 'application/json'
    }
    logger.info(headers)
    response = requests.post(f'https://g.codefresh.io/api/pipelines/run/{PIPELINE_ID}', headers=headers, data=DATA)
    logger.info(response.text.encode('utf8'))

def lambda_handler(event, context):
    logger.info(event)
    initiate_pipeline()
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
