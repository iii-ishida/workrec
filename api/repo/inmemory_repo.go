package repo

import (
	"net/http"
	"workrec/api/event"
	"workrec/api/model"
)

// InmemoryRepo is implements Repo for Inmemory.
var InmemoryRepo = inmemoryRepo{}

type inmemoryRepo struct{}

var works = map[string]model.Work{}
var events = map[string]event.Event{}
var latestSavedWork = model.Work{}
var latestSavedEvent = event.Event{}

func (inmemoryRepo) Reset() {
	works = map[string]model.Work{}
	events = map[string]event.Event{}
	latestSavedWork = model.Work{}
	latestSavedEvent = event.Event{}
}

func (inmemoryRepo) WithRequest(_ *http.Request) Repo {
	return inmemoryRepo{}
}

func (r inmemoryRepo) RunInTransaction(f func() error) error {
	return f()
}

func (inmemoryRepo) GetWork(workID string) (model.Work, error) {
	if w, ok := works[workID]; ok {
		return w, nil
	}
	return model.Work{}, nil
}

func (inmemoryRepo) SaveWork(w model.Work) error {
	if w.IsDeleted() {
		delete(works, w.ID)
	} else {
		latestSavedWork = w
		works[w.ID] = w
	}
	return nil
}

func (inmemoryRepo) GetEvent(eventID string) (event.Event, error) {
	if e, ok := events[eventID]; ok {
		return e, nil
	}
	return event.Event{}, nil
}

func (inmemoryRepo) SaveEvent(e event.Event) error {
	latestSavedEvent = e
	events[e.ID] = e
	return nil
}

func (inmemoryRepo) LatestSavedWork() model.Work {
	return latestSavedWork
}

func (inmemoryRepo) LatestSavedEvent() event.Event {
	return latestSavedEvent
}
