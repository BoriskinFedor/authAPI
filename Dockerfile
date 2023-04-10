FROM golang

RUN go version
ENV GOPATH=/

COPY ./ ./

RUN go mod download
RUN go build -o authapi main.go

CMD ["./authapi"]