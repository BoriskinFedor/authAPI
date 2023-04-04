package server

import (
	"authAPI/internal/model"

	"github.com/gin-gonic/gin"
)

func (s *Server) Auth(ctx *gin.Context) {
	user := model.User{
		Login:    ctx.Request.Header["X-Login"][0],
		Password: ctx.Request.Header["X-Password"][0],
	}

	s.store.User().Auth(&user)

	ctx.JSON(200, gin.H{
		"X-Token": user.Token,
	})
}
