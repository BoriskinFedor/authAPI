package main

import (
	"authAPI/internal/server"
	"log"
)

func main() {
	config := &server.Config{
		DBURL: "postgres://postgres:postgrespw@localhost:32768?sslmode=disable",
	}

	srv := server.New(config)

	if err := srv.Start(); err != nil {
		log.Fatal(err)
	}
}
