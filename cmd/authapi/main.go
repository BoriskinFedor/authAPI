package main

import (
	"authAPI/internal/server"
	"log"
)

func main() {
	config := &server.Config{
		DBURL: "postgres://postgres:123456@db:5432?sslmode=disable",
	}

	srv := server.New(config)

	if err := srv.Start(); err != nil {
		log.Fatal(err)
	}
}
