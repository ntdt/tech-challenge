FROM python:3.8-slim

ENV DATASET "/dataset"
ENV OUTPUT "/output"

RUN apt-get update && apt-get -y upgrade

ADD process.py .
ADD requirements.txt .

RUN pip install -r requirements.txt

ENTRYPOINT /usr/local/bin/python process.py $DATASET $OUTPUT
