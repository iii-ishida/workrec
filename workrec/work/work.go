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

func (state State) String() string {
	switch state {
	case Unknown:
		return "Unknown"
	case Start:
		return "Start"
	case Pause:
		return "Pause"
	case Resume:
		return "Resume"
	case Finish:
		return "Finish"
	default:
		return "Unknown"
	}
}

type action struct {
	State State
	Time  time.Time
}

type Work struct {
	Title       string
	Actions     []action
	GoalMinutes int
}

func New(title string, goalMinutes int) Work {
	return Work{
		Title:       title,
		Actions:     []action{},
		GoalMinutes: goalMinutes,
	}
}

func (work Work) Start(time time.Time) Work {
	if work.CurrentState() != Unknown {
		return work
	}

	work.Actions = append(work.Actions, action{State: Start, Time: time})
	return work
}

func (work Work) Toggle(time time.Time) Work {
	nextState := work.nextState()
	if nextState == Unknown {
		return work
	}

	work.Actions = append(work.Actions, action{State: nextState, Time: time})
	return work
}

func (work Work) Finish(time time.Time) Work {
	if work.CurrentState() == Unknown {
		return work
	}

	work.Actions = append(work.Actions, action{State: Finish, Time: time})
	return work
}

func (work Work) CurrentState() State {
	len := len(work.Actions)
	if len == 0 {
		return Unknown
	}
	return work.Actions[len-1].State
}

func (work Work) nextState() State {
	switch work.CurrentState() {
	case Unknown:
		return Unknown
	case Start:
		return Pause
	case Pause:
		return Resume
	case Resume:
		return Pause
	case Finish:
		return Unknown
	default:
		return Unknown
	}
}

func (work Work) StartTime() time.Time {
	if len(work.Actions) == 0 {
		return time.Time{}
	}
	return work.Actions[0].Time
}
