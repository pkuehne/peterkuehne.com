FROM ubuntu:20.04

LABEL maintainer='peter@peterkuehne.com'

ENV HUGO_VERSION=0.74.3
ENV HUGO_BASEURL=http://localhost/
ENV HUGO_ENV=production

RUN apt update && apt install -y \
        curl \
        git \
    && curl -SL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
        -o /tmp/hugo.tar.gz \
    && tar -xzf /tmp/hugo.tar.gz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/ \
    && apt remove curl -y \
    && apt autoremove -y \
    && mkdir -p /src \
    && rm -rf /tmp/*

WORKDIR /src

EXPOSE 1313

ARG HUGO_ENV=production
USER 1000:1000
ENTRYPOINT ["/usr/local/bin/hugo"]
CMD ["serve", "-e ${HUGO_ENV}", "--bind=0.0.0.0", "--appendPort=false"]
