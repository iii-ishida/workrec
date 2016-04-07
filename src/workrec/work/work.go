package work

import (
	"bytes"
	"encoding/json"
	"io"
	"time"

	"workrec/db"
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
	State State     `json:"state"`
	Time  time.Time `json:"time"`
}

type Work struct {
	ID          string   `json:"id"`
	Title       string   `json:"title"`
	Actions     []action `json:"actions"`
	GoalMinutes int      `json:"goal_minutes"`
}

func New(title string, goalMinutes int) Work {
	return Work{
		ID:          db.NextWorkID(),
		Title:       title,
		Actions:     []action{},
		GoalMinutes: goalMinutes,
	}
}

func FromJSON(r io.Reader) (Work, error) {
	var work Work
	decoder := json.NewDecoder(r)
	err := decoder.Decode(&work)

	return work, err
}

func (work *Work) ToJSON() string {
	var buffer bytes.Buffer
	encoder := json.NewEncoder(&buffer)
	encoder.Encode(&work)

	return buffer.String()
}

func (work Work) Equal(another Work) bool {
	isEqual := work.ID == another.ID
	isEqual = isEqual && work.Title == another.Title
	isEqual = isEqual && len(work.Actions) == len(another.Actions)
	isEqual = isEqual && work.GoalMinutes == another.GoalMinutes
	for i, action := range work.Actions {
		anotherAction := another.Actions[i]
		isEqual = isEqual && action.State == anotherAction.State
		isEqual = isEqual && action.Time.Equal(anotherAction.Time)
		if !isEqual {
			break
		}
	}

	return isEqual
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
