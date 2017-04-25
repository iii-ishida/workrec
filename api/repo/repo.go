package repo

import (
	"net/http"
	"workrec/api/event"
	"workrec/api/model"
)

// Repo is a repository for API.
type Repo interface {
	WithRequest(*http.Request) Repo

	RunInTransaction(func() error) error

	GetWork(workID string) (model.Work, error)
	SaveWork(model.Work) error

	GetEvent(eventID string) (event.Event, error)
	SaveEvent(event.Event) error
}
