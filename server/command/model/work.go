package model

import (
	"fmt"
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

// WorkState is a state for a work.
type WorkState int8

// States for a work.
const (
	UnknownState WorkState = 0
	Unstarted    WorkState = 1
	Started      WorkState = 2
	Paused       WorkState = 3
	Resumed      WorkState = 4
	Finished     WorkState = 5
)

func (s WorkState) String() string {
	switch s {
	case UnknownState:
		return "Unknown"
	case Unstarted:
		return "Unstarted"
	case Started:
		return "Started"
	case Paused:
		return "Paused"
	case Resumed:
		return "Resumed"
	case Finished:
		return "Finished"
	default:
		panic(fmt.Sprintf("unknown WorkState: %d", s))
	}
}
