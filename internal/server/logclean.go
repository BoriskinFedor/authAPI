package server

import (
	"authAPI/internal/model"
	"net/http"

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
	session := model.Session{
		Token: ctx.Request.Header["X-Token"][0],
	}

	if session.Token == "" {
		ctx.JSON(http.StatusForbidden, gin.H{
			"message": "token not found",
		})
	}

	if err := s.store.User().LogClean(&session); err != nil {
		ctx.JSON(http.StatusForbidden, gin.H{
			"message": err,
		})
	}

	ctx.JSON(http.StatusOK, gin.H{
		"message": "success",
	})
}
