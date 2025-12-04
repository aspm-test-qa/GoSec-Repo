FROM golang:alpine@sha256:26111811bc967321e7b6f852e914d14bede324cd1accb7f81811929a6a57fea9 as builder

RUN apk add --no-cache \
        git \
        make \
        gcc \
        musl-dev

ENV REPOSITORY github.com/future-architect/vuls
COPY . $GOPATH/src/$REPOSITORY
RUN cd $GOPATH/src/$REPOSITORY && make install

FROM alpine:3.23@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375

ENV LOGDIR /var/log/vuls
ENV WORKDIR /vuls

RUN apk add --no-cache \
        openssh-client \
        ca-certificates \
        git \
        nmap \
    && mkdir -p $WORKDIR $LOGDIR

COPY --from=builder /go/bin/vuls /usr/local/bin/

VOLUME ["$WORKDIR", "$LOGDIR"]
WORKDIR $WORKDIR
ENV PWD $WORKDIR

ENTRYPOINT ["vuls"]
CMD ["--help"]
