# syntax=docker/dockerfile:1

FROM python:3.11-slim as production

RUN apt-get update && apt-get install --yes --no-install-recommends g++

ENV PYTHONUNBUFFERED True

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD exec gunicorn app.main:app --bind :8080 --workers 1 --threads 8 --timeout 0 -k uvicorn.workers.UvicornWorker
