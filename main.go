package main

import (
	_ "authAPI/docs"
	"authAPI/internal/server"
	"log"
)

// @title tinyAPI
// @version 1.0
// @description Тестовое задание

// @host localhost:8080
// @BasePath /
func main() {
	config, err := server.NewConfig("config.yaml")
	if err != nil {
		log.Fatal(err)
	}

	srv := server.New(config)

	if err := srv.Start(); err != nil {
		log.Fatal(err)
	}
}
