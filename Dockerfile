FROM golang:1.21.8 as builder
WORKDIR /app
COPY go.mod ./
COPY go.sum* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go-echo-server

# Second stage: setup the runtime container
FROM scratch
WORKDIR /
COPY --from=builder /go-echo-server /go-echo-server
EXPOSE 8080
ENTRYPOINT ["/go-echo-server"]
