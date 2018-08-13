FROM golang:1.10 as builder
WORKDIR /go/src/github.com/frnksgr/helloworld
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -o helloworld .

# NOTE: cf requires more than scratch
# while K8S is fine with it.
# build image for cf with 
# docker build -t frnksgr/helloworld-cf --build-arg BASEIMAGE=busybox .

FROM scratch
COPY --from=builder /go/src/github.com/frnksgr/helloworld .
ENV FROM=dockerfile
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/helloworld"]
