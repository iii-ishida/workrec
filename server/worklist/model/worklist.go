package model

import (
	"fmt"
	"time"
)

// WorkList is a work list.
type WorkList struct {
	Works         []WorkListItem
	NextPageToken string
}

// WorkListItem is a item of WorkList.
type WorkListItem struct {
	ID        string
	Title     string
	State     WorkState
	StartedAt time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
	IsDeleted bool
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
