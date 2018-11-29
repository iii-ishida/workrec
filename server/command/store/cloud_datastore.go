package store

import (
	"context"
	"net/http"

	"cloud.google.com/go/datastore"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
)

// CloudDataStore is a Store for Cloud Datastore.
type CloudDataStore struct {
	ctx    context.Context
	client *datastore.Client
	tx     *datastore.Transaction
}

// NewCloudDatastore returns a CloudDataStore.
func NewCloudDatastore(r *http.Request) (CloudDataStore, error) {
	ctx := r.Context()

	client, err := datastore.NewClient(ctx, util.GetProjectID())
	if err != nil {
		return CloudDataStore{}, err
	}
	return CloudDataStore{ctx: ctx, client: client}, nil
}

// RunTransaction runs f in transaction.
func (s CloudDataStore) RunTransaction(f func(Store) error) error {
	_, err := s.client.RunInTransaction(s.ctx, func(tx *datastore.Transaction) error {
		return f(CloudDataStore{ctx: s.ctx, client: s.client, tx: tx})
	})
	return err
}

// GetWork loads the work stored for id into dst
func (s CloudDataStore) GetWork(id string, dst *model.Work) error {
	key := datastore.NameKey(model.KindNameWork, id, nil)

	err := s.get(key, dst)
	if err == datastore.ErrNoSuchEntity {
		return ErrNotfound
	}
	return err
}

// PutWork saves the work into the datastore.
func (s CloudDataStore) PutWork(work model.Work) error {
	key := datastore.NameKey(model.KindNameWork, work.ID, nil)

	return s.put(key, &work)
}

// DeleteWork deletes the work for the given id from datastore.
func (s CloudDataStore) DeleteWork(id string) error {
	key := datastore.NameKey(model.KindNameWork, id, nil)

	return s.delete(key)
}

// PutEvent saves the event into the datastore.
func (s CloudDataStore) PutEvent(e event.Event) error {
	key := datastore.NameKey(event.KindName, e.ID, nil)

	return s.put(key, &e)
}

func (s CloudDataStore) get(key *datastore.Key, dst interface{}) error {
	if s.tx != nil {
		return s.tx.Get(key, dst)
	}
	return s.client.Get(s.ctx, key, dst)
}
func (s CloudDataStore) put(key *datastore.Key, src interface{}) error {
	if s.tx != nil {
		_, err := s.tx.Put(key, src)
		return err
	}
	_, err := s.client.Put(s.ctx, key, src)
	return err
}
func (s CloudDataStore) delete(key *datastore.Key) error {
	if s.tx != nil {
		return s.tx.Delete(key)
	}
	return s.client.Delete(s.ctx, key)
}
