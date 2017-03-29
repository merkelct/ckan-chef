#! /usr/bin/env python
import csv
import subprocess
import os
import sys
import json
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
    paste =  subprocess.Popen('./paster --plugin=ckan tracking export /usr/lib/ckan/default/src/tracking.csv '
                              + d30f_paster + ' -c /etc/ckan/default/development.ini', shell=True, cwd=bin_dir)
    paste.wait()
    print paste.returncode
    get_api_tracking()

def get_api_tracking():
    ##test data
    esret = {"took": 11,"timed_out": False,"_shards": {"total": 81,"successful": 81,"failed": 0},"hits": {"total": 171957,"max_score": 0,"hits": []}}
    total = esret['hits']['total']

    # url = "http://search-geospatial-platform-34744iniqtaew24wyrukmfwomu.us-east-1.es.amazonaws.com/akanametrics%2A/_search"
    #
    # payload = "{\n  \"size\": 0,\n  \"query\": {\n    \"range\": {\n      \"request-date\": {\n        " \
    #           "\"gte\": \"" + d30f + "\",\n        \"lte\": \"" + d + "\"\n      }\n    }\n  }\n}"
    #
    # headers = {
    #     'content-type': "application/json",
    #     'cache-control': "no-cache"
    # }
    # response = requests.request("POST", url, data=payload, headers=headers)
    # print "this is the response back from geospatial-platfrom ES + str(response.text)
    # res = response.json()
    # total = res['hits']['total']
    with open('/usr/lib/ckan/default/src/tracking.csv', 'ab') as csvfile:
        twriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        twriter.writerow(['API_COUNT', 'API_DATA', total, total])
    update_csv_total()


def update_csv_total():
    total = []

    with open('/usr/lib/ckan/default/src/tracking.csv', 'a+r+b') as csvfile:
        reader = csv.DictReader(csvfile)

        for row in reader:
            # print(row['total views'])
            total.append(row['total views'])

    results = map(int, total)
    with open('/usr/lib/ckan/default/src/tracking_total.csv', 'w+b') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames = ["Total", "Count"])
        writer.writeheader()

        twriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        twriter.writerow(['TOTAL_VIEWS', sum(results)])

if __name__ == '__main__':

    update_tracking()

    export_tracking()

