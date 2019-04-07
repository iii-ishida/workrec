package api

import (
	"errors"
	"net/http"

	"github.com/iii-ishida/workrec/server/api/store"
	"github.com/iii-ishida/workrec/server/publisher"
)

// ValidationError is a error for the validation.
type ValidationError string

func (v ValidationError) Error() string {
	return string(v)
}

var (
	// ErrNotfound is error for the notfound.
	ErrNotfound = errors.New("not found")

	// ErrForbidden is error for the Forbidden.
	ErrForbidden = errors.New("forbidden")
)

// Dependency is a dependency for the command.
type Dependency struct {
	store.Store
	publisher.Publisher
}

// NewCloudDataStore returns a new CloudDataStore.
func NewCloudDataStore(r *http.Request) (store.Store, error) {
	return store.NewCloudDataStore(r)
}

// NewCloudPublisher returns a new CloudPublisher.
func NewCloudPublisher(r *http.Request) publisher.Publisher {
	return publisher.NewCloudPublisher(r)
}

// API is a Work API interface.
type API struct {
	dep Dependency
}

// New returns a new API.
func New(dep Dependency) API {
	return API{dep: dep}
}

// Close closes the Store.
func (a API) Close() error {
	if a.dep.Store == nil {
		return nil
	}
	return a.dep.Store.Close()
}
