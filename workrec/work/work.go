package work

import (
	"time"
)

type State int

const (
	Unknown State = iota
	Start
	Pause
	Resume
	Finish
)

type action struct {
	State State
	Time  time.Time
}

type Work struct {
	Title       string
	Actions     []action
	GoalMinutes int
}

func (work Work) Start(time time.Time) Work {
	return work
}

func (work Work) Toggle(time time.Time) Work {
	return work
}

func (work Work) Finish(time time.Time) Work {
	return work
}
