package server

import (
	"authAPI/internal/model"
	"net/http"

	"github.com/gin-gonic/gin"
)

// @Summary 	Лог
// @Description Лог авторизации пользователя
// @Param 		X-Token header string true "Токен"
// @Produce 	application/json
// @Tags 		log
// @Success 	200 {object} []model.UserLog
// @Router		/log [get]
func (s *Server) LogGet(ctx *gin.Context) {
	session := model.Session{
		Token: ctx.Request.Header["X-Token"][0],
	}

	logs, err := s.store.User().LogGet(&session)

	if err != nil {
		ctx.JSON(http.StatusForbidden, gin.H{
			"message": err,
		})
	} else {
		ctx.JSON(http.StatusOK, logs)
	}
}
