package server

import (
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"authAPI/internal/store"
)

type Server struct {
	engine *gin.Engine
	store  *store.Store
}

func New(config *Config) *Server {
	return &Server{
		engine: gin.Default(),
		store:  store.New(config.DBURL, config.DBReconnectCount),
	}
}

func (s *Server) Start() error {
	s.engine.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	s.engine.POST("/auth", s.Auth)
	s.engine.GET("/log", s.LogGet)
	s.engine.DELETE("/logclean", s.LogClean)

	if err := s.store.Open(); err != nil {
		return err
	}

	defer s.store.Close()

	return s.engine.Run()
}
