// Code generated by swaggo/swag. DO NOT EDIT.

package docs

import "github.com/swaggo/swag"

const docTemplate = `{
    "schemes": {{ marshal .Schemes }},
    "swagger": "2.0",
    "info": {
        "description": "{{escape .Description}}",
        "title": "{{.Title}}",
        "contact": {},
        "version": "{{.Version}}"
    },
    "host": "{{.Host}}",
    "basePath": "{{.BasePath}}",
    "paths": {
        "/auth": {
            "post": {
                "description": "Авторизация. Получить токен",
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "auth"
                ],
                "summary": "Авторизация",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Логин пользователя",
                        "name": "X-Login",
                        "in": "header",
                        "required": true
                    },
                    {
                        "type": "string",
                        "description": "Пароль пользователя",
                        "name": "X-Password",
                        "in": "header",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "$ref": "#/definitions/model.Session"
                        }
                    }
                }
            }
        },
        "/log": {
            "get": {
                "description": "Лог авторизации пользователя",
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "log"
                ],
                "summary": "Лог",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Токен",
                        "name": "X-Token",
                        "in": "header",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK",
                        "schema": {
                            "type": "array",
                            "items": {
                                "$ref": "#/definitions/model.UserLog"
                            }
                        }
                    }
                }
            }
        },
        "/logclean": {
            "delete": {
                "description": "Очистка лога авторизации пользователя",
                "produces": [
                    "application/json"
                ],
                "tags": [
                    "log"
                ],
                "summary": "Очистить лог",
                "parameters": [
                    {
                        "type": "string",
                        "description": "Токен",
                        "name": "X-Token",
                        "in": "header",
                        "required": true
                    }
                ],
                "responses": {
                    "200": {
                        "description": "OK"
                    }
                }
            }
        }
    },
    "definitions": {
        "model.Session": {
            "type": "object",
            "properties": {
                "token": {
                    "type": "string"
                }
            }
        },
        "model.UserLog": {
            "type": "object",
            "properties": {
                "log_action": {
                    "type": "string"
                },
                "log_ts": {
                    "type": "string"
                }
            }
        }
    }
}`

// SwaggerInfo holds exported Swagger Info so clients can modify it
var SwaggerInfo = &swag.Spec{
	Version:          "1.0",
	Host:             "localhost:8080",
	BasePath:         "/",
	Schemes:          []string{},
	Title:            "tinyAPI",
	Description:      "Тестовое задание",
	InfoInstanceName: "swagger",
	SwaggerTemplate:  docTemplate,
}

func init() {
	swag.Register(SwaggerInfo.InstanceName(), SwaggerInfo)
}
