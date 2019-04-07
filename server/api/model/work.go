package model

import (
	"time"
)

// Work is a Work.
type Work struct {
	ID        string
	EventID   string
	UserID    string
	Title     string
	Time      time.Time
	State     WorkState
	UpdatedAt time.Time
}
