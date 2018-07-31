FROM golang:1.10 as builder
WORKDIR /go/src/github.com/frnksgr/helloworld
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -o helloworld .

# NOTE: cf requires more than scratch
# while K8S is fine with it.
# FIX it by providing different images

# FROM scratch 
FROM alpine 
COPY --from=builder /go/src/github.com/frnksgr/helloworld .
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/helloworld"]