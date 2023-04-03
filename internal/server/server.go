package server

import (
	"github.com/gin-gonic/gin"

	"authAPI/internal/store"
)

type Server struct {
	engine *gin.Engine
	store  *store.Store
}

func New(config *Config) *Server {
	return &Server{
		engine: gin.Default(),
		store:  store.New(config.dbURL),
	}
}

func (s *Server) Start() error {
	s.engine.GET("/auth", s.Auth)

	if err := s.store.Open(); err != nil {
		return err
	}

	defer s.store.Close()

	return s.engine.Run()
}
