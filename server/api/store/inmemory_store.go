package store

import (
	"time"

	"github.com/iii-ishida/workrec/server/api/model"
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

// GetEvents loads the events stored into dst.
func (*InmemoryStore) GetEvents(userID string, lastConstructedAt time.Time, pageSize int, pageToken string, dst *[]event.Event) (nextPageToken string, err error) {
	return "", nil
}

// GetWorkList loads the WorkList stored into dst.
func (*InmemoryStore) GetWorkList(userID string, pageSize int, pageToken string, dst *[]model.WorkListItem) (nextPageToken string, err error) {
	return "", nil
}

// GetWorkListItem loads the WorkListItem stored for id into dst.
func (*InmemoryStore) GetWorkListItem(id string, dst *model.WorkListItem) error {
	return nil
}

// PutWorkListItem saves the work into the datastore.
func (*InmemoryStore) PutWorkListItem(work model.WorkListItem) error {
	return nil
}

// DeleteWorkListItem deletes the WorkListItem for the given id from datastore.
func (*InmemoryStore) DeleteWorkListItem(id string) error {
	return nil
}

// GetLastConstructedAt loads the lastConstructedAt stored into dst.
func (*InmemoryStore) GetLastConstructedAt(id string, dst *model.LastConstructedAt) error {
	return nil
}

// PutLastConstructedAt saves the lastConstructedAt into the datastore.
func (*InmemoryStore) PutLastConstructedAt(model.LastConstructedAt) error {
	return nil
}

// Close nothing to do..
func (s *InmemoryStore) Close() error {
	return s.CloseError
}
