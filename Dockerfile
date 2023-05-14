FROM ubuntu:22.04

RUN apt update && apt upgrade -y
RUN apt-get install -y socat libgphobos-dev

COPY product_key_check /product_key_check
RUN chmod +x /product_key_check

ENTRYPOINT socat -T30 TCP-LISTEN:3232,reuseaddr,fork EXEC:/product_key_check,pty,raw,stderr,echo=0