#Lib
import smtplib
from smtplib import SMTPException
import datetime
import socket
import sys

#Variables
vardate = datetime.datetime.now().strftime("%d-%m-%Y %X")
topic_error = sys.argv[1]
path_alert_log= sys.argv[2]
FROM = 'insert_email'
TO = ['insert_email', 'insert_email', 'insert_email']
host_name = socket.gethostname()

SUBJECT = '{}: {} "{}"'.format(host_name, topic_error.replace("_", " "), vardate)
with open(path_alert_log, "r") as f:
    alert_log = f.read()

TEXT = '''
We would like to acknowledge that we have received.
A support representative will be reviewing request (usually within 24 hours).

Error message:

{}
'''.format(alert_log)

Message = 'Subject: {}\n\n{}'.format(SUBJECT, TEXT)

# SMTP
server = smtplib.SMTP('insert_smtp_host',insert_smtp_port)
server.sendmail(FROM, TO, Message)
server.quit()
