FROM python

WORKDIR /app

COPY . /app/

RUN pip install -r requirements.txt

EXPOSE 8000

CMD gunicorn cmeadows_tech.wsgi --bind 0.0.0.0:8000