package store

import (
	"errors"
	"time"

	"github.com/iii-ishida/workrec/server/api/model"
	"github.com/iii-ishida/workrec/server/event"
)

// ErrNotfound is error for the notfound.
var ErrNotfound = errors.New("not found")

// DefaultPageSize is default pageSize.
var DefaultPageSize = 50

// Store is a repository.
type Store interface {
	RunInTransaction(func(Store) error) error

	PutEvent(e event.Event) error
	GetEvents(userID string, lastConstructedAt time.Time, pageSize int, pageToken string, dst *[]event.Event) (nextPageToken string, err error)

	GetWork(id string, dst *model.Work) error
	PutWork(model.Work) error
	DeleteWork(id string) error

	GetWorkList(userID string, pageSize int, pageToken string, dst *[]model.WorkListItem) (nextPageToken string, err error)
	GetWorkListItem(id string, dst *model.WorkListItem) error
	PutWorkListItem(model.WorkListItem) error
	DeleteWorkListItem(id string) error

	GetLastConstructedAt(id string, dst *model.LastConstructedAt) error
	PutLastConstructedAt(model.LastConstructedAt) error

	Close() error
}
