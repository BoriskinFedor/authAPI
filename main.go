package main

import (
	_ "authAPI/docs"
	"authAPI/internal/server"
	"log"
)

// @title API авторизации по токену
// @version 1.0
// @description Тестовое задание на GO-разработчика

// @host localhost:8080
// @BasePath /
func main() {
	config := &server.Config{
		DBURL:            "postgres://postgres:123456@db:5432?sslmode=disable",
		DBReconnectCount: 40,
	}

	srv := server.New(config)

	if err := srv.Start(); err != nil {
		log.Fatal(err)
	}
}
