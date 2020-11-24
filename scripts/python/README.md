所有的python脚本我都将编写为命令的模式，可传递参数

- [格式化日志，输出为json](./parselog.py)
	```
	$ python parselog.py -h
	usage: parselog.py [-h] -f LOGFILE -t {apache,nginx} [-o OUTPUT]
	Generic log file parser
	optional arguments:
	  -h, --help            show this help message and exit
	  -f LOGFILE, --logfile LOGFILE
	                        Logfile Path
	  -t {apache,nginx}, --type {apache,nginx}
	                        Logfile Type
	  -o OUTPUT, --output OUTPUT
	                        Result Output File

	$ cat access.log
	192.168.60.17 - - [19/Aug/2020:14:09:38 +0800] "GET / HTTP/1.0" 200 4833 "-" "ApacheBench/2.3" "-"
	192.168.60.17 - - [19/Aug/2020:14:09:38 +0800] "GET / HTTP/1.0" 200 4833 "-" "ApacheBench/2.3" "-"

	$ python parselog.py -f access.log -t nginx -o access_json.log

	$ cat access_json.log
	{"client_ip": "192.168.60.17", "datetime": "19/Aug/2020:14:09:38 +0800", "scheme": "GET / HTTP/1.0", "res_code": "200", "agent": "ApacheBench/2.3"}
	{"client_ip": "192.168.60.17", "datetime": "19/Aug/2020:14:09:38 +0800", "scheme": "GET / HTTP/1.0", "res_code": "200", "agent": "ApacheBench/2.3"}
	```
- [扫描端口](./portscanner.py)
  ```
	$ python portscanner.py -h
	usage: portscanner.py [-h] -H HOST -P PORT

	PortScanner

	optional arguments:
		-h, --help            show this help message and exit
		-H HOST, --host HOST  Target Host's Hostname or IPaddress
		-P PORT, --port PORT

	$ python portscanner.py -H www.baidu.com -P 80 -P 22 -P 33
	[+] Scan Results for: www.baidu.com
	Scanning Port: 80
	[+] www.baidu.com/80 Opened
	Scanning Port: 22
	[-] www.baidu.com/22 Closed
	Scanning Port: 33
	[-] www.baidu.com/33 Closed
	```
- [TCPing](./tcping.py)
  ```
	$ python tcping.py -h
	usage: tcping.py [-h] -H HOST [-P PORT] [-t] [-c COUNT] [-i INTERVAL]

	Tcping

	optional arguments:
		-h, --help            show this help message and exit
		-H HOST, --host HOST  host
		-P PORT, --port PORT  port, default: 80
		-t                    continously, default: False
		-c COUNT, --count COUNT
													count, default: 4
		-i INTERVAL, --interval INTERVAL
													interval, default: 1

	$ python tcping.py -H www.baidu.com -P 80 -c 5 -i 2
	[+] www.baidu.com:80 Opened, time: 16.15ms
	[+] www.baidu.com:80 Opened, time: 15.45ms
	[+] www.baidu.com:80 Opened, time: 14.73ms
	[+] www.baidu.com:80 Opened, time: 15.46ms
	[+] www.baidu.com:80 Opened, time: 20.17ms

	Tcping Results: www.baidu.com:80
		send = 5, success = 5, failed = 0, success_percent = 100.0%
		MaxRespTime = 20.17ms, MinRespTime = 14.73ms, AverRespTime = 16.39ms
	```
- [AlertAnalysis](./alertanalysis.py)
	```
	收集数据库中记录的告警信息并发送邮件告警统计
	通过pandas dataframe对数据进行初步统计，并绘制成html表格
	调用了企业微信API获取部门的所有人邮箱。可单发、可群发
	最后调用smtplib库进行邮件发送

	python3 alertanalysis.py --lastday   发送昨日统计
	python3 alertanalysis.py --lastweek  发送上周统计
	python3 alertanalysis.py --lastmonth 发送上月统计
	```