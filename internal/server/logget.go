package server

import (
	"authAPI/internal/model"
	"encoding/json"

	"github.com/gin-gonic/gin"
)

func (s *Server) LogGet(ctx *gin.Context) {
	user := model.User{
		Token: ctx.Request.Header["X-Token"][0],
	}

	logs, _ := s.store.User().LogGet(&user)

	jsonlogs, _ := json.Marshal(logs)

	ctx.JSON(200, gin.H{
		"message": string(jsonlogs),
	})
}
