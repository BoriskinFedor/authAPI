package server

import (
	"authAPI/internal/model"

	"github.com/gin-gonic/gin"
)

// @Summary 	Авторизация
// @Description Авторизация. Получить токен
// @Param 		X-Login header string true "Логин пользователя"
// @Param 		X-Password header string true "Пароль пользователя"
// @Produce 	application/json
// @Tags 		auth
// @Success 	200 {object} model.Session
// @Router		/auth [post]
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
