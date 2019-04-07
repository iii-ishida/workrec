package api

import (
	"fmt"
	"time"

	"github.com/iii-ishida/workrec/server/api/model"
	"github.com/iii-ishida/workrec/server/api/store"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
)

// CreateWorkParam is a param for CreateWork.
type CreateWorkParam struct {
	Title string
}

// UpdateWorkParam is a param for UpdateWork.
type UpdateWorkParam struct {
	Title string
}

// ChangeWorkStateParam is a param for changeWorkState.
type ChangeWorkStateParam struct {
	Time  time.Time
	state model.WorkState
}

// CreateWork creates a work and returns the created work id.
func (a API) CreateWork(userID string, param CreateWorkParam) (string, error) {
	if userID == "" {
		return "", ErrForbidden
	}

	now := time.Now()

	var ret string
	err := a.dep.Store.RunInTransaction(func(s store.Store) error {
		eventID := util.NewUUID()
		workID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    "",
			UserID:    userID,
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
			UserID:    userID,
			Title:     param.Title,
			Time:      time.Time{},
			State:     model.Unstarted,
			UpdatedAt: now,
		}
		if err := s.PutWork(w); err != nil {
			return err
		}

		if err := a.publishEvent(e); err != nil {
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

// UpdateWork updates the work.
func (a API) UpdateWork(userID, workID string, param UpdateWorkParam) error {
	now := time.Now()

	return a.dep.Store.RunInTransaction(func(s store.Store) error {
		var source model.Work
		if err := s.GetWork(workID, &source); err != nil {
			if err == store.ErrNotfound {
				return ErrNotfound
			}
			return err
		}

		if source.UserID != userID {
			return ErrForbidden
		}

		eventID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    source.EventID,
			UserID:    userID,
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
			UserID:    source.UserID,
			Title:     param.Title,
			Time:      source.Time,
			State:     source.State,
			UpdatedAt: now,
		}
		if err := s.PutWork(w); err != nil {
			return err
		}

		return a.publishEvent(e)
	})
}

// DeleteWork deletes the work.
func (a API) DeleteWork(userID, workID string) error {
	now := time.Now()

	return a.dep.Store.RunInTransaction(func(s store.Store) error {
		var source model.Work
		if err := s.GetWork(workID, &source); err != nil {
			if err == store.ErrNotfound {
				return ErrNotfound
			}
			return err
		}

		if source.UserID != userID {
			return ErrForbidden
		}

		eventID := util.NewUUID()

		e := event.Event{
			ID:        eventID,
			PrevID:    source.EventID,
			UserID:    userID,
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

		return a.publishEvent(e)
	})
}

// StartWork starts the work.
func (a API) StartWork(userID, workID string, param ChangeWorkStateParam) error {
	return a.changeWorkState(userID, workID, param, event.StartWork, func(source model.Work) error {
		switch source.State {
		case model.Unstarted:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Started))
		}
	})
}

// PauseWork pauses the work.
func (a API) PauseWork(userID, workID string, param ChangeWorkStateParam) error {
	return a.changeWorkState(userID, workID, param, event.PauseWork, func(source model.Work) error {
		switch source.State {
		case model.Started, model.Resumed:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Paused))
		}
	})
}

// ResumeWork resumes the work.
func (a API) ResumeWork(userID, workID string, param ChangeWorkStateParam) error {
	return a.changeWorkState(userID, workID, param, event.ResumeWork, func(source model.Work) error {
		switch source.State {
		case model.Paused:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Resumed))
		}
	})
}

// FinishWork finishes the work.
func (a API) FinishWork(userID, workID string, param ChangeWorkStateParam) error {
	return a.changeWorkState(userID, workID, param, event.FinishWork, func(source model.Work) error {
		switch source.State {
		case model.Started, model.Paused, model.Resumed:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s)", source.State, model.Finished))
		}
	})
}

// CancelFinishWork cancels the finish state for the work.
func (a API) CancelFinishWork(userID, workID string, param ChangeWorkStateParam) error {
	return a.changeWorkState(userID, workID, param, event.CancelFinishWork, func(source model.Work) error {
		switch source.State {
		case model.Finished:
			return nil
		default:
			return ValidationError(fmt.Sprintf("invalid state (%s -> %s (Cancel Finish))", source.State, model.Paused))
		}
	})
}

func (a API) changeWorkState(userID, workID string, param ChangeWorkStateParam, eventAction event.Action, validationFunc func(model.Work) error) error {
	now := time.Now()

	return a.dep.Store.RunInTransaction(func(s store.Store) error {
		var source model.Work
		if err := s.GetWork(workID, &source); err != nil {
			if err == store.ErrNotfound {
				return ErrNotfound
			}
			return err
		}

		if source.UserID != userID {
			return ErrForbidden
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
			UserID:    userID,
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
			UserID:    source.UserID,
			Title:     source.Title,
			Time:      param.Time,
			State:     workStateFromEventAction(eventAction),
			UpdatedAt: now,
		}
		if err := s.PutWork(w); err != nil {
			return err
		}

		return a.publishEvent(e)
	})
}

func (a API) publishEvent(e event.Event) error {
	b, err := event.MarshalPb(e)
	if err != nil {
		return err
	}

	return a.dep.Publisher.Publish(b)
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
