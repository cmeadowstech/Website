FROM python:3.11-slim-bullseye

WORKDIR /app

COPY . /app/

RUN pip install -r requirements.txt --no-cache-dir

EXPOSE 8000

CMD gunicorn cmeadows_tech.wsgi --bind 0.0.0.0:8000