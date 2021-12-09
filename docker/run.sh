#!/bin/bash
export PYTHONPATH=/Savior/
if [ -f /Savior/docker/firstrun ]; then
    . /Savior/.env
    if [ "$DB_HOST" != "mysql" ]; then
        echo -e "$DB_HOST\tmysql" >> /etc/hosts
    fi
    /Savior/docker/wait-for-it.sh -t 0 mysql:3306
    python3 /Savior/manage.py makemigrations api
    python3 /Savior/manage.py migrate
    python3 /Savior/manage.py init_admin
    mkdir /Savior/preview
    chown nobody:nobody -R /Savior
    rm -f /Savior/docker/firstrun
fi
/Savior/docker/wait-for-it.sh -t 0 mysql:3306
supervisord -n -c /etc/supervisord.conf

