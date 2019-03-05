package store

import (
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/event"
)

// InmemoryStore is a Store for Inmemory.
type InmemoryStore struct {
	event.Event
	model.Work
	GetWorkError    error
	PutWorkError    error
	DeleteWorkError error
	PutEventError   error
	CloseError      error
}

// NewInmemoryStore returns a new InmemoryStore.
func NewInmemoryStore() *InmemoryStore {
	return &InmemoryStore{}
}

// RunInTransaction runs f in transaction.
func (s *InmemoryStore) RunInTransaction(f func(Store) error) error {
	return f(s)
}

// GetWork loads the work stored for id into dst
func (s *InmemoryStore) GetWork(id string, dst *model.Work) error {
	*dst = s.Work
	return s.GetWorkError
}

// PutWork saves the work into the memory.
func (s *InmemoryStore) PutWork(w model.Work) error {
	s.Work = w
	return s.PutWorkError
}

// DeleteWork deletes the work for the given id from memory.
func (s *InmemoryStore) DeleteWork(id string) error {
	s.Work = model.Work{}
	return s.DeleteWorkError
}

// PutEvent saves the event into the memory.
func (s *InmemoryStore) PutEvent(e event.Event) error {
	s.Event = e
	return s.PutEventError
}

// Close nothing to do..
func (s *InmemoryStore) Close() error {
	return s.CloseError
}
