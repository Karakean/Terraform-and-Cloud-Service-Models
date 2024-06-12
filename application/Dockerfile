FROM python:3.13.0b2-alpine3.20

WORKDIR /app

COPY requirements.txt /app
RUN pip3 install -r requirements.txt

COPY . /app

EXPOSE 8080/tcp

ENTRYPOINT [ "python3" ]
CMD [ "app.py"]
