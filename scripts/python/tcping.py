#!/usr/bin/python3
# -*- coding:utf-8 -*-
__author__ = 'github.com/serchaofan'
import argparse
import re
import socket
import time
import numpy as np


def host2ip(host):
    try:
        return socket.gethostbyname(host)
    except Exception:
        return None


def connPort(host, port):
    connSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    connSocket.settimeout(1)
    try:
        time_start = time.time()
        connSocket.connect((host, port))
        time_end = time.time()
        connSocket.close()
        spendtime = round(float((time_end - time_start) * 1000), 2)
        print(f"[+] {host}:{port} Opened, time: {spendtime}ms")
        return True, spendtime
    except:
        print(f"[-] {host}:{port} Closed")
        spendtime = 1000
        return False, spendtime


def start_tcping(host, port, count, interval, t):
    success = 0
    failed = 0
    try:
        spendtime_list = []
        if t:
            print("\nContinuously Tcping, Press Ctrl-C To Stop\n")
            while True:
                time.sleep(interval)
                result, spendtime = connPort(host, port)
                spendtime_list.append(spendtime)
                if result:
                    success += 1
                else:
                    failed += 1
        else:
            for i in range(count):
                time.sleep(interval)
                result, spendtime = connPort(host, port)
                spendtime_list.append(spendtime)
                if result:
                    success += 1
                else:
                    failed += 1
            success_per = round(float(success / count) * 100, 2)
            MaxRespTime = max(spendtime_list)
            MinRespTime = min(spendtime_list)
            AverRespTime = round(np.mean(spendtime_list), 2)
        print(f'''
Tcping Results: {host}:{port}
  send = {count}, success = {success}, failed = {failed}, success_percent = {success_per}%
  MaxRespTime = {MaxRespTime}ms, MinRespTime = {MinRespTime}ms, AverRespTime = {AverRespTime}ms
      ''')
    except KeyboardInterrupt:
        print("Ctrl-C")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Tcping")
    parser.add_argument("-H", "--host", help="host", required=True)
    parser.add_argument("-P", "--port", help="port, default: 80")
    parser.add_argument(
        "-t", help="continously, default: False", action="store_true")
    parser.add_argument("-c", "--count", help="count, default: 4")
    parser.add_argument("-i", "--interval", help="interval, default: 1")
    args = parser.parse_args()

    host = args.host
    port = args.port
    if not port:
        port = 80
    else:
        port = int(port)
    t = args.t
    if not t:
        t = False
    count = args.count
    if not count:
        count = 4
    else:
        count = int(count)
    interval = args.interval
    if not interval:
        interval = 1
    else:
        interval = int(interval)
    ip_match_regex = r'(\d{1,3}(?:\.\d{1,3}){3})'
    fqdn_match_regex = r'^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$'
    if not re.match(ip_match_regex, host):
        if not re.match(fqdn_match_regex, host):
            print("Wrong Input")
            exit()
        else:
            if not host2ip(host):
                print("Parse Wrong, Pls Check your Host")
            else:
                ip = host2ip(host)
    else:
        ip = host
    start_tcping(host, port, count, interval, t)
