FROM golang:1.10 as builder
WORKDIR /go/src/github.com/frnksgr/helloworld
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -o helloworld .

FROM scratch
COPY --from=builder /go/src/github.com/frnksgr/helloworld .
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/helloworld"]