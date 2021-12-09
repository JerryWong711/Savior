FROM alpine:latest

RUN echo -e "http://mirrors.sjtug.sjtu.edu.cn/alpine/v3.15/main\nhttp://mirrors.sjtug.sjtu.edu.cn/alpine/v3.15/community\nhttp://mirrors.sjtug.sjtu.edu.cn/alpine/edge/testing" > /etc/apk/repositories \
        && apk update \
        && apk upgrade \
        && apk add --no-cache bash tzdata nginx python3 uwsgi uwsgi-python3 supervisor py3-pip pandoc py3-mysqlclient py3-lxml py3-pillow py3-wheel \
        && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && apk del tzdata \
        && rm -rf /var/cache/apk/* /etc/avahi/services/* /etc/nginx/http.d/default.conf \
        && sed -i 's/\/etc\/supervisor.d\/\*.ini/\/Savior\/docker\/supervisor-app.conf/g' /etc/supervisord.conf \
        && sed -i '1,/;user=chrism/{s#;user=chrism#user=root#}' /etc/supervisord.conf

COPY .env manage.py requirements.txt /Savior/
COPY docker/ /Savior/docker/
COPY server/ /Savior/server/
COPY app/ /Savior/app/
COPY output /Savior/output/
COPY static/ /Savior/static/

RUN ln -s /Savior/docker/savior.conf /etc/nginx/http.d/ \
    && chmod +x /Savior/docker/*.sh \
    && pip3 install -r /Savior/requirements.txt -i http://pypi.doubanio.com/simple --trusted-host pypi.doubanio.com \
    && find /Savior/ -type f -name '.*' ! -path '/Savior/.env' -delete \
    && rm -f /Savior/requirements.txt

WORKDIR /Savior/

ENV LANG C.UTF-8

EXPOSE 80

CMD ["/Savior/docker/run.sh"]