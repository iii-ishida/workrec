package store

import (
	"errors"
	"time"

	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/worklist/model"
)

// ErrNotfound is error for the notfound.
var ErrNotfound = errors.New("not found")

// DefaultPageSize is default pageSize.
var DefaultPageSize = 50

// Store is a repository for the worklist.
type Store interface {
	GetWorks(pageSize int, pageToken string, dst *[]model.WorkListItem) (nextPageToken string, err error)
	GetWork(id string, dst *model.WorkListItem) error
	PutWork(w model.WorkListItem) error
	DeleteWork(id string) error

	GetLastConstructedAt(id string, dst *model.LastConstructedAt) error
	PutLastConstructedAt(l model.LastConstructedAt) error

	GetEvents(lastConstructedAt time.Time, pageSize int, pageToken string, dst *[]event.Event) (nextPageToken string, err error)
}
