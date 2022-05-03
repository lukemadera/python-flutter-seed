import os
import threading

import log

def Restart(doRestart = 1):
    os.system("echo ci_webhook.Restart starting, doRestart3 " + str(doRestart))
    log.log('warn', 'ci_webhook.Restart start3')
    if doRestart:
      thread = threading.Thread(target=RestartIt, args=())
      thread.start()

def RestartIt():
    os.system("cd /var/www/seed_app && \
        git checkout . && git pull origin master && \
        pip3 install -r ./requirements.txt && \
        flutter upgrade && \
        cd frontend && flutter build web && cd ../ && \
        systemctl restart systemd_web_server.service")
    os.system("echo ci_webhook.Restart done")
    log.log('warn', 'ci_webhook.RestartIt done')
