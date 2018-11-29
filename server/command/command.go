package command

import (
	"errors"
	"fmt"
	"time"

	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/command/store"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
)

// Dependency is a dependency for the command.
type Dependency struct {
	Store store.Store
}

// Command is a workrec command.
type Command struct {
	dep Dependency
}

// New returns a new Command.
func New(dep Dependency) Command {
	return Command{dep: dep}
}

// ValidationError is a error for the validation.
type ValidationError string

func (v ValidationError) Error() string {
	return string(v)
}

// ErrNotfound is error for the notfound.
var ErrNotfound = errors.New("not found")

// CreateWorkParam is a param for CreateWork.
type CreateWorkParam struct {
	Title string
}

// CreateWork creates a work and returns the created work id.
func (c Command) CreateWork(param CreateWorkParam) (string, error) {
	now := time.Now()

	var ret string
	err := c.dep.Store.RunInTransaction(func(s store.Store) error {
		eventID := util.NewUUID()
		workID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    "",
			WorkID:    workID,
			Action:    event.CreateWork,
			Title:     param.Title,
			CreatedAt: now,
		}
		if err := s.PutEvent(e); err != nil {
			return err
		}

		w := model.Work{
			ID:        workID,
			EventID:   eventID,
			Title:     param.Title,
			Time:      time.Time{},
			State:     model.Unstarted,
			UpdatedAt: now,
		}
		if err := s.PutWork(w); err != nil {
			return err
		}

		ret = workID
		return nil
	})

	if err != nil {
		return "", err
	}

	return ret, nil
}

// UpdateWorkParam is a param for UpdateWork.
type UpdateWorkParam struct {
	Title string
}

// UpdateWork updates the work.
func (c Command) UpdateWork(workID string, param UpdateWorkParam) error {
	now := time.Now()

	return c.dep.Store.RunInTransaction(func(s store.Store) error {
		var source model.Work
		if err := s.GetWork(workID, &source); err != nil {
			if err == store.ErrNotfound {
				return ErrNotfound
			}
			return err
		}

		eventID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    source.EventID,
			WorkID:    source.ID,
			Action:    event.UpdateWork,
			Title:     param.Title,
			CreatedAt: now,
		}
		if err := s.PutEvent(e); err != nil {
			return err
		}

		w := model.Work{
			ID:        source.ID,
			EventID:   eventID,
			Title:     param.Title,
			Time:      source.Time,
			State:     source.State,
			UpdatedAt: now,
		}
		if err := s.PutWork(w); err != nil {
			return err
		}

		return nil
	})
}

// DeleteWork deletes the work.
func (c Command) DeleteWork(workID string) error {
	now := time.Now()

	return c.dep.Store.RunInTransaction(func(s store.Store) error {
		var source model.Work
		if err := s.GetWork(workID, &source); err != nil {
			if err == store.ErrNotfound {
				return ErrNotfound
			}
			return err
		}

		eventID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    source.EventID,
			WorkID:    source.ID,
			Action:    event.DeleteWork,
			CreatedAt: now,
		}
		if err := s.PutEvent(e); err != nil {
			return err
		}

		if err := s.DeleteWork(source.ID); err != nil {
			return err
		}

		return nil
	})
}

// ChangeWorkStateParam is a param for changeWorkState.
type ChangeWorkStateParam struct {
	Time  time.Time
	state model.WorkState
}

// StartWork starts the work.
func (c Command) StartWork(workID string, param ChangeWorkStateParam) error {
	return c.changeWorkState(workID, param, event.StartWork, func(source model.Work) error {
		switch source.State {
		case model.Unstarted:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Started))
		}
	})
}

// PauseWork pauses the work.
func (c Command) PauseWork(workID string, param ChangeWorkStateParam) error {
	return c.changeWorkState(workID, param, event.PauseWork, func(source model.Work) error {
		switch source.State {
		case model.Started, model.Resumed:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Paused))
		}
	})
}

// ResumeWork resumes the work.
func (c Command) ResumeWork(workID string, param ChangeWorkStateParam) error {
	return c.changeWorkState(workID, param, event.ResumeWork, func(source model.Work) error {
		switch source.State {
		case model.Paused:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Resumed))
		}
	})
}

// FinishWork finishes the work.
func (c Command) FinishWork(workID string, param ChangeWorkStateParam) error {
	return c.changeWorkState(workID, param, event.FinishWork, func(source model.Work) error {
		switch source.State {
		case model.Started, model.Paused, model.Resumed:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Finished))
		}
	})
}

// CancelFinishWork cancels the finish state for the work.
func (c Command) CancelFinishWork(workID string, param ChangeWorkStateParam) error {
	return c.changeWorkState(workID, param, event.CancelFinishWork, func(source model.Work) error {
		switch source.State {
		case model.Finished:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s (Cancel Finish))", source.State, model.Paused))
		}
	})
}

func (c Command) changeWorkState(workID string, param ChangeWorkStateParam, eventAction event.Action, validationFunc func(model.Work) error) error {
	now := time.Now()

	return c.dep.Store.RunInTransaction(func(s store.Store) error {
		var source model.Work
		if err := s.GetWork(workID, &source); err != nil {
			if err == store.ErrNotfound {
				return ErrNotfound
			}
			return err
		}

		if source.Time.After(param.Time) {
			return ValidationError("invalid time")
		}

		if err := validationFunc(source); err != nil {
			return err
		}

		eventID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    source.EventID,
			WorkID:    source.ID,
			Action:    eventAction,
			Time:      param.Time,
			CreatedAt: now,
		}
		if err := s.PutEvent(e); err != nil {
			return err
		}

		w := model.Work{
			ID:        source.ID,
			EventID:   eventID,
			Title:     source.Title,
			Time:      param.Time,
			State:     workStateFromEventAction(eventAction),
			UpdatedAt: now,
		}
		if err := s.PutWork(w); err != nil {
			return err
		}

		return nil
	})

}

func workStateFromEventAction(eventAction event.Action) model.WorkState {
	switch eventAction {
	case event.StartWork:
		return model.Started
	case event.PauseWork:
		return model.Paused
	case event.ResumeWork:
		return model.Resumed
	case event.FinishWork:
		return model.Finished
	case event.CancelFinishWork:
		return model.Paused
	default:
		return model.UnknownState
	}
}
