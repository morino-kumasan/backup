FROM ubuntu:latest

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install openssl tar gzip pv

RUN mkdir -p /work
COPY ./entrypoint.sh /work/entrypoint.sh
RUN chmod +x /work/entrypoint.sh

WORKDIR /work
ENTRYPOINT ["/work/entrypoint.sh"]
