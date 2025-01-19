FROM python:3.13

ADD . .

RUN pip3 install -r requirements.txt

EXPOSE 8080

CMD gunicorn main:app  -c uvicorn_conf.py --log-level error