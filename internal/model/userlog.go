package model

import "time"

type UserLog struct {
	Time   time.Time `json:"log_ts"`
	Action string    `json:"log_action"`
}
