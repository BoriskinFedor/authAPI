package server

import (
	"authAPI/internal/model"

	"github.com/gin-gonic/gin"
)

// @Summary 	Очистить лог
// @Description Очистка лога авторизации пользователя
// @Param 		X-Token header string true "Токен"
// @Produce 	application/json
// @Tags 		log
// @Success 	200
// @Router		/logclean [delete]
func (s *Server) LogClean(ctx *gin.Context) {
	user := model.User{
		Token: ctx.Request.Header["X-Token"][0],
	}

	s.store.User().LogClean(&user)

	ctx.JSON(200, gin.H{
		"status": "ok",
	})
}
