package model

type User struct {
	Login    string
	Password string
	Token    string `json:"token"`
}
