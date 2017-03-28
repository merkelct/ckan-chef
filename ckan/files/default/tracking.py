#! /usr/bin/env python
import csv
import subprocess
import os
import sys
import requests
from datetime import datetime, timedelta

d = datetime.today().strftime("%Y-%m-%d" + "T" + "%H:%M")
d30 = datetime.today() - timedelta(days=30)
d30f = d30.strftime("%Y-%m-%d" + "T" + "%H:%M")
d30f_paster = d30.strftime("%Y-%m-%d")

bin_dir = '/usr/lib/ckan/default/bin/'


def update_tracking():
    subprocess.Popen('./paster --plugin=ckan tracking update -c /etc/ckan/default/development.ini', shell=True, cwd=bin_dir)
    subprocess.Popen('./paster --plugin=ckan search-index rebuild -r -c /etc/ckan/default/development.ini', shell=True, cwd=bin_dir)

def export_tracking():
    subprocess.Popen('./paster --plugin=ckan tracking export /usr/lib/ckan/default/src/tracking.csv '
         + d30f_paster + ' -c /etc/ckan/default/development.ini', shell=True, cwd=bin_dir)


def get_api_tracking():
    esret = {"took": 11,"timed_out": False,"_shards": {"total": 81,"successful": 81,"failed": 0},"hits": {"total": 171957,"max_score": 0,"hits": []}}

    # url = "http://search-geospatial-platform-34744iniqtaew24wyrukmfwomu.us-east-1.es.amazonaws.com/akanametrics%2A/_search"
    #
    # payload = "{\n  \"size\": 0,\n  \"query\": {\n    \"range\": {\n      \"request-date\": {\n        " \
    #           "\"gte\": \"" + d30f + "\",\n        \"lte\": \"" + d + "\"\n      }\n    }\n  }\n}"
    #
    # headers = {
    #     'content-type': "application/json",
    #     'cache-control': "no-cache"
    # }
    #
    # response = requests.request("POST", url, data=payload, headers=headers)
    #
    # total = response['hits']['total']
    total = esret['hits']['total']
    with open('/usr/lib/ckan/default/src/tracking.csv', 'ab') as csvfile:
        twriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        twriter.writerow(['API_COUNT', 'API_DATA', total, total])


if __name__ == '__main__':

    update_tracking()

    export_tracking()

    get_api_tracking()

