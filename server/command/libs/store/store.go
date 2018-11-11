package store

import (
	"errors"

	"github.com/iii-ishida/workrec/server/command/libs/model"
)

// ErrNotfound is error for the notfound.
var ErrNotfound = errors.New("not found")

// Store is a repository for the command.
type Store interface {
	RunTransaction(func(Store) error) error

	GetWork(id model.WorkID, dst *model.Work) error
	PutWork(w model.Work) error
	DeleteWork(id model.WorkID) error

	PutEvent(e model.Event) error
}
