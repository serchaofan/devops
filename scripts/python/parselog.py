#!/usr/bin/python3
# -*- coding:utf-8 -*-
__author__ = 'github.com/serchaofan'
import re
import json
import argparse


def readfile(logfile):
    logs = []
    with open(logfile) as f:
        logs = f.readlines()
    return logs


def parse_apache_logs(logfile):
    logs = readfile(logfile)
    regex = r'(\d{1,3}(?:\.\d{1,3}){3}) (\S+) (\S+) \[(.+)\] "(.*)" (\d+) ([\d\-]+) (\d+) "(\S+)" "(.*)"'
    logs_result = []
    for i in logs:
        index = logs.index(i)
        i = i.strip()
        result = re.match(regex, i)
        single_log = {
            'client_ip': result.group(1),
            'datetime': result.group(4),
            'resource': result.group(5),
            'res_code': result.group(6),
            'req_url': result.group(9),
            'agent': result.group(10)
        }
        logs_result.append(json.dumps(single_log))
    return logs_result


def parse_nginx_logs(logfile):
    logs = readfile(logfile)
    regex = r'(\d{1,3}(?:\.\d{1,3}){3}) (\S+) (\S+) \[(.+)\] "(.*)" (\d+) (\d+) "(\S+)" "(.*)" "(\S+)"'
    logs_result = []
    for i in logs:
        index = logs.index(i)
        i = i.strip()
        result = re.match(regex, i)
        single_log = {
            'client_ip': result.group(1),
            'datetime': result.group(4),
            'scheme': result.group(5),
            'res_code': result.group(6),
            'agent': result.group(9),
            # 'agent': result.group(10)
        }
        logs_result.append(json.dumps(single_log))
    return logs_result


if __name__ == '__main__':
    global quiet
    parser = argparse.ArgumentParser(description="Generic log file parser")
    parser.add_argument('-f', '--logfile', required=True, help='Logfile Path')
    parser.add_argument('-t', '--type', required=True,
                        choices=['apache', 'nginx'], help="Logfile Type")
    parser.add_argument('-o', '--output', help="Result Output File")
    args = parser.parse_args()

    logfile = args.logfile
    type = args.type
    output = args.output

    parse_func = globals()[f'parse_{type}_logs']
    parsed_logs = parse_func(logfile)
    if output:
        with open(output, 'w') as f:
            for i in parsed_logs:
                f.write(i)
                f.write("\n")
    else:
        print(json.dump(parsed_logs, indent=2))
