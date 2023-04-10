package server

import (
	"authAPI/internal/model"
	"log"

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
	user := model.User{
		Token: ctx.Request.Header["X-Token"][0],
	}

	logs, _ := s.store.User().LogGet(&user)

	log.Println(logs)

	ctx.JSON(200, logs)
}
