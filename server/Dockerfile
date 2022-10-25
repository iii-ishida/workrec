# syntax=docker/dockerfile:1

FROM python:3.10-slim as production

ENV PYTHONUNBUFFERED True

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD exec gunicorn app.main:app --bind :8080 -w 4 -k uvicorn.workers.UvicornWorker

