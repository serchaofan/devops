#!/usr/bin/python3
# -*- coding:utf-8 -*-
__author__ = 'github.com/serchaofan'
import argparse
import socket
import re


def connPort(host, port):
    try:
        connSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        connSocket.connect((host, port))
        print(f"[+] {host}/{port} Opened")
        connSocket.close()
    except:
        print(f"[-] {host}/{port} Closed")


def portScan(host, ports):
    try:
        ip = socket.gethostbyname(host)
    except:
        print(f"[-] Can't Resolve Host '{host}', Unknown Host")
        return
    try:
        # hostname = socket.gethostbyaddr(ip)
        print(f"\n[+] Scan Results for: {host}")
    except:
        print(f"\n[+] Scan Results for: {ip}")
    socket.setdefaulttimeout(1)
    for port in ports:
        print(f"Scanning Port: {port}")
        connPort(host, int(port))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="PortScanner")
    parser.add_argument('-H', '--host', required=True,
                        help="Target Host's Hostname or IPaddress")
    parser.add_argument('-P', '--port', required=True,
                        action="append", help="")
    args = parser.parse_args()

    host = args.host
    port = args.port
    port = map(int, port)

    ip_match_regex = r'(\d{1,3}(?:\.\d{1,3}){3})'
    fqdn_match_regex = r'^(?=^.{3,255}$)[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$'

    if not re.match(ip_match_regex, host):
        if not re.match(fqdn_match_regex, host):
            print("Wrong Input")
            exit()
    portScan(host, port)
