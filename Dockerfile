FROM frolvlad/alpine-python3
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt && \
    apk update && \
		apk add bash
ADD ./mysite/ /code/

COPY ./start.sh /start.sh

EXPOSE 8000
CMD ["/start.sh"]
