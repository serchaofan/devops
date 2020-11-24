#!/usr/bin/env python3
import smtplib
from email.mime.text import MIMEText
import requests
import json
from loguru import logger
import pandas as pd
import pymysql.cursors
from datetime import datetime, timedelta
from dateutil import relativedelta
import argparse

WEIXIN_API_URL = "https://qyapi.weixin.qq.com/cgi-bin"
CORPID = "xxxxx"   #企业ID
CORPSECRET = "xxxxxx"    #调用应用的secret
ACCESS_TOKEN = ""
DEPARTMENT_ID = 105  #企业微信部门id

DBCONN = ""
LASTDAY = (datetime.today() + timedelta(-1)).strftime('%m-%d')
LASTWEEK = f"{(datetime.today() + timedelta(-7)).strftime('%m-%d')}~{(datetime.today() + timedelta(-1)).strftime('%m-%d')}"
LASTMONTH = f"{(datetime.today() + relativedelta.relativedelta(months=-1)).strftime('%m-%d')}~{(datetime.today() + timedelta(-1)).strftime('%m-%d')}"

def generate_token(corpid=CORPID, corpsecret=CORPSECRET):
    logger.debug("Generating Access_Token")
    url = f"{WEIXIN_API_URL}/gettoken"
    result = requests.get(
        url, params={'corpid': CORPID, 'corpsecret': CORPSECRET})
    result.encoding = 'utf-8'
    result = json.loads(result.text)
    logger.debug("Access_Token Got")
    return result['access_token']


def getuserlist():
    logger.debug("Getting User list Dataframe")
    url = f"{WEIXIN_API_URL}/user/list"
    result = requests.get(
        url, params={'access_token': ACCESS_TOKEN, 'department_id': DEPARTMENT_ID})
    result.encoding = "utf-8"
    result = json.loads(result.text)
    users = result['userlist']
    users = pd.DataFrame(users, columns=["userid", "name", "email"])
    userlist = []
    for index, user in users.iterrows():
        userlist.append(user.to_dict())
    logger.debug("User List Got")
    return userlist


def getuser(name):
    logger.debug("Calling function: getuserlist()")
    users = getuserlist()
    user = {}
    logger.debug("Searching user: ", name)
    for user in users:
        if user['name'] == name:
            logger.debug("Found")
            return user


def get_db_conn():
    logger.debug("Connecting to MySQL...")
    conn = pymysql.connect(
        host="xx.xx.xx.xx",   #数据库ip
        user="xx",            #数据库用户
        password="xxxx",      #登录密码
        db="xxxx",            #库名
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor
    )
    return conn


def get_db_data(sql):
    try:
        with DBCONN.cursor() as cursor:
            logger.debug(f"Executing SQL : \n{sql}")
            cursor.execute(sql)
            result = cursor.fetchall()
            logger.debug("MySQL Data Got!")
            data = pd.DataFrame(result)
            return data
    except Exception as e:
        logger.exception(e)
    finally:
        DBCONN.close()


def get_alert_event_lastday():
    COLUMNS = "ticket_code,host_name,host_ip,service,event_data,from_unixtime(alert_time) as alert_time,from_unixtime(close_time) as close_time,status"
    TABLE = "db_smart_ops.tb_alertcenter_event"
    WHERE = "create_time >= unix_timestamp(date_sub(curdate(), interval 1 day)) and create_time <= unix_timestamp(curdate())"
    sql = f'SELECT {COLUMNS} FROM {TABLE} where {WHERE};'
    data = get_db_data(sql=sql)
    for index, item in data.iterrows():
        event_data = json.loads(item['event_data'])
        data.loc[index, 'event_data'] = event_data["value"]
    logger.debug("Result Data Processed!")
    return data

def get_alert_event_lastweek():
    COLUMNS = "ticket_code,host_name,host_ip,service,event_data,from_unixtime(alert_time) as alert_time,from_unixtime(close_time) as close_time,status"
    TABLE = "db_smart_ops.tb_alertcenter_event"
    WHERE = "create_time >= unix_timestamp(date_sub(curdate(), interval 1 week)) and create_time <= unix_timestamp(curdate())"
    sql = f'SELECT {COLUMNS} FROM {TABLE} where {WHERE};'
    data = get_db_data(sql=sql)
    for index, item in data.iterrows():
        event_data = json.loads(item['event_data'])
        data.loc[index, 'event_data'] = event_data["value"]
    logger.debug("Result Data Processed!")
    print(data)
    return data

def get_alert_event_lastmonth():
    COLUMNS = "ticket_code,host_name,host_ip,service,event_data,from_unixtime(alert_time) as alert_time,from_unixtime(close_time) as close_time,status"
    TABLE = "db_smart_ops.tb_alertcenter_event"
    WHERE = "create_time >= unix_timestamp(date_sub(curdate(), interval 1 month)) and create_time <= unix_timestamp(curdate())"
    sql = f'SELECT {COLUMNS} FROM {TABLE} where {WHERE};'
    data = get_db_data(sql=sql)
    for index, item in data.iterrows():
        event_data = json.loads(item['event_data'])
        data.loc[index, 'event_data'] = event_data["value"]
    logger.debug("Result Data Processed!")
    print(data)
    return data


# def generate_weixin_message():
#     data = get_alert_event()
#     logger.debug("Generating Weixin Message Content...")
#     alert_svc_ranting = data.loc[:, ['service', 'host_ip']].value_counts().to_frame(name="次数")
#     content = f'''
# **{LASTDAY}统计结果**
# 主机告警次数
# {alert_svc_ranting.to_markdown()}
#     '''
#     logger.debug(f"{content}")
#     return content
# # tablefmt="grid"

def generate_mail_message(type='lastday'):
    data = None
    email_subject = None
    content = None
    if type == 'lastday':
        data = get_alert_event_lastday()
        logger.debug("Generating Email Message Content...")
        event_count = len(data)
        event_closed = data.loc[:, 'status'].value_counts().to_dict()['CLOSED']
        event_close_percent = event_closed/event_count
        alert_svc_ranting = data.loc[:, ['service', 'host_name', 'host_ip']].value_counts().to_frame(name="次数")
        alert_host_ranting = data.loc[:, ['host_name', 'host_ip', 'service']].value_counts().to_frame(name="次数")
        content = f'''
        <link href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css" rel="stylesheet">
        <h2>{LASTDAY}统计结果<h2>
        <div class="container">
            <h4>当天所有邮件（已对ip排序）<h4>
            {data.sort_values(by=['host_ip']).to_html(classes='table table-striped table-hover table-sm')}
        </div>
        <div class="container">
            <h4>告警服务次数排行<h4>
            {alert_svc_ranting.to_html(classes='table table-striped table-hover table-sm')}
        </div>
        <div class="container">
            <h4>主机告警次数排行<h4>
            {alert_host_ranting.to_html(classes='table table-striped table-hover table-sm')}
        </div>
        <div class="container">
            <h4>事件关闭率<h4>
            共有{event_count}个事件，当天关闭{event_closed}个，关单率{round(event_close_percent*100, 1)}%
        </div>
        '''
        email_subject = f"告警统计日报：{LASTDAY}"
    elif type == 'lastweek':
        data = get_alert_event_lastweek()
        logger.debug("Generating Email Message Content...")
        alert_svc_ranting = data.loc[:, ['service', 'host_name', 'host_ip']].value_counts().to_frame(name="次数")
        alert_host_ranting = data.loc[:, ['host_name', 'host_ip', 'service']].value_counts().to_frame(name="次数")
        content = f'''
        <link href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css" rel="stylesheet">
        <h2>{LASTWEEK}统计结果<h2>
        <div class="container">
            <h4>告警服务次数排行<h4>
            {alert_svc_ranting.to_html(classes='table table-striped table-hover table-sm')}
        </div>
        <div class="container">
            <h4>主机告警次数排行<h4>
            {alert_host_ranting.to_html(classes='table table-striped table-hover table-sm')}
        </div>
        '''
        email_subject = f"告警统计周报：{LASTWEEK}"
    elif type == 'lastmonth':
        data = get_alert_event_lastmonth()
        logger.debug("Generating Email Message Content...")
        alert_svc_ranting = data.loc[:, ['service', 'host_name', 'host_ip']].value_counts().to_frame(name="次数")
        alert_host_ranting = data.loc[:, ['host_name', 'host_ip', 'service']].value_counts().to_frame(name="次数")
        content = f'''
        <link href="https://cdn.bootcdn.net/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css" rel="stylesheet">
        <h2>{LASTMONTH}统计结果<h2>
        <div class="container">
            <h4>告警服务次数排行<h4>
            {alert_svc_ranting.to_html(classes='table table-striped table-hover table-sm')}
        </div>
        <div class="container">
            <h4>主机告警次数排行<h4>
            {alert_host_ranting.to_html(classes='table table-striped table-hover table-sm')}
        </div>
        '''
        email_subject = f"告警统计月报：{LASTMONTH}告警统计结果"
    return email_subject, content


# def send_weixin_message(sendto=[]):
#     url = f"{WEIXIN_API_URL}/message/send?access_token={ACCESS_TOKEN}"
#     users_id = []
#     users_id_str = ""
#     if not sendto:
#         users_id_str = "@all"
#     else:
#         for name in sendto:
#             user = getuser(name=name)
#             if not user:
#                 continue
#             else:
#                 users_id.append(user['userid'])
#         users_id_str = '|'.join(users_id)
#     print(users_id_str)
#     logger.debug(f"Sending to: {users_id_str}")
#     data = json.dumps({
#         "touser": users_id_str,
#         "msgtype": "markdown",
#         "agentid": 1000016,
#         "markdown": {
#             "content": generate_weixin_message()
#         },
#         "safe": 0,
#         "enable_id_trans": 0,
#         "enable_duplicate_check": 0,
#         "duplicate_check_interval": 1800
#     })
#     requests.post(url, data=data)
#     logger.debug("Weixin Messages Sent!!")


def get_user_emails(userlist=[]):
    emails = []
    if not userlist:
        for user in getuserlist():
            emails.append(user['email'])
    else:
        for user in getuserlist():
            if user['name'] in userlist:
                emails.append(user['email'])
    logger.debug(f"All User Found, Return Email List: {emails}")
    return emails


def send_mail_message(userlist=[], type='lastday'):
    emaillist = get_user_emails(userlist)
    email_subject = ''
    content = ''
    if type == 'lastday':
        email_subject, content = generate_mail_message(type='lastday')
    elif type == 'lastweek':
        email_subject, content = generate_mail_message(type='lastweek')
    elif type == 'lastmonth':
        email_subject, content = generate_mail_message(type='lastmonth')

    sender = 'xxxxx'   #发送人邮箱
    receivers = emaillist

    smtp_server = 'smtp.exmail.qq.com'
    smtp_port = 465
    mail_user = 'xxxxx'  #发送人邮箱
    mail_pass = 'xxxxx'  #发送人邮箱密码

    message = MIMEText(content.encode('utf-8'), 'html', 'utf-8')
    message["Subject"] = email_subject
    message['From'] = sender
    # message['To'] = emaillist

    logger.debug(f"SMTP Server: {smtp_server}  SMTP Port: {smtp_port}")
    logger.debug(f"Sender: {mail_user}")
    logger.debug(f"Sendto: {emaillist}")

    try:
        smtpObj = smtplib.SMTP_SSL(smtp_server, smtp_port)
        smtpObj.set_debuglevel(False)
        logger.debug("Connecting to SMTP server")
        smtpObj.ehlo()
        smtpObj.login(mail_user, mail_pass)
        logger.debug("Login Succefully")
        logger.debug("Sending Emails...")
        smtpObj.sendmail(
            sender, receivers, message.as_string())
        logger.debug("Emails Sent!!")
        smtpObj.quit()
    except smtplib.SMTPException as e:
        logger.exception("SMTP ERROR: ", e)


if __name__ == "__main__":
    ACCESS_TOKEN = generate_token()
    DBCONN = get_db_conn()
    sendmail_to = []

    parser = argparse.ArgumentParser()
    parser.add_argument("--lastday", action="store_true")
    parser.add_argument("--lastweek", action="store_true")
    parser.add_argument("--lastmonth", action="store_true")
    args = parser.parse_args()
    if args.lastday == True:
        send_mail_message(sendmail_to, type='lastday')
    elif args.lastweek == True:
        send_mail_message(sendmail_to, type='lastweek')
    elif args.lastmonth == True:
        send_mail_message(sendmail_to, type='lastmonth')
