package model

import "time"

type UserLog struct {
	Time   time.Time
	Action string
}
