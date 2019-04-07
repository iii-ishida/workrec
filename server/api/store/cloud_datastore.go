package store

import (
	"context"
	"net/http"
	"time"

	"cloud.google.com/go/datastore"
	"github.com/iii-ishida/workrec/server/api/model"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
	"google.golang.org/api/iterator"
)

// CloudDataStore is a Store for Cloud Datastore.
type CloudDataStore struct {
	ctx    context.Context
	client *datastore.Client
	tx     *datastore.Transaction
}

// NewCloudDataStore returns a CloudDataStore.
func NewCloudDataStore(r *http.Request) (CloudDataStore, error) {
	ctx := r.Context()

	client, err := datastore.NewClient(ctx, util.ProjectID())
	if err != nil {
		return CloudDataStore{}, err
	}
	return CloudDataStore{ctx: ctx, client: client}, nil
}

// RunInTransaction runs f in transaction.
func (s CloudDataStore) RunInTransaction(f func(Store) error) error {
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

// GetWorkList loads the works stored into dst.
func (s CloudDataStore) GetWorkList(userID string, pageSize int, pageToken string, dst *[]model.WorkListItem) (string, error) {
	var ws []model.WorkListItem

	q := datastore.NewQuery(model.KindNameWorkListItem).Order("UserID").Order("-CreatedAt").Filter("UserID=", userID).Limit(pageSize)
	if cursor, err := datastore.DecodeCursor(pageToken); err == nil {
		q = q.Start(cursor)
	}

	t := s.client.Run(s.ctx, q)
	for {
		var w model.WorkListItem
		_, err := t.Next(&w)
		if err == iterator.Done {
			break
		}
		if err != nil {
			return "", err
		}

		ws = append(ws, w)
	}

	cursor, err := t.Cursor()
	if err != nil {
		return "", err
	}

	*dst = ws

	if s.hasNext(q, cursor) {
		return cursor.String(), nil
	}
	return "", nil
}

// GetWorkListItem loads the work stored for id into dst.
func (s CloudDataStore) GetWorkListItem(id string, dst *model.WorkListItem) error {
	key := datastore.NameKey(model.KindNameWorkListItem, id, nil)

	err := s.client.Get(s.ctx, key, dst)
	if err == datastore.ErrNoSuchEntity {
		return ErrNotfound
	}
	return err
}

// PutWorkListItem saves the work into the datastore.
func (s CloudDataStore) PutWorkListItem(work model.WorkListItem) error {
	key := datastore.NameKey(model.KindNameWorkListItem, work.ID, nil)

	_, err := s.client.Put(s.ctx, key, &work)
	return err
}

// DeleteWorkListItem deletes the work for the given id from datastore.
func (s CloudDataStore) DeleteWorkListItem(id string) error {
	key := datastore.NameKey(model.KindNameWorkListItem, id, nil)

	return s.client.Delete(s.ctx, key)
}

// GetEvents loads the events stored into dst.
func (s CloudDataStore) GetEvents(userID string, createdAt time.Time, pageSize int, pageToken string, dst *[]event.Event) (string, error) {
	var events []event.Event

	q := datastore.NewQuery(event.KindName).Order("UserID").Order("CreatedAt").Filter("UserID=", userID).Filter("CreatedAt>", createdAt).Limit(pageSize)
	if cursor, err := datastore.DecodeCursor(pageToken); err == nil {
		q = q.Start(cursor)
	}

	t := s.client.Run(s.ctx, q)
	for {
		var e event.Event
		_, err := t.Next(&e)
		if err == iterator.Done {
			break
		}
		if err != nil {
			return "", err
		}

		events = append(events, e)
	}

	cursor, err := t.Cursor()
	if err != nil {
		return "", err
	}

	*dst = events

	if s.hasNext(q, cursor) {
		return cursor.String(), nil
	}
	return "", nil
}

// GetLastConstructedAt loads the lastConstructedAt stored into dst.
func (s CloudDataStore) GetLastConstructedAt(id string, dst *model.LastConstructedAt) error {
	key := datastore.NameKey(model.KindNameLastConstructedAt, id, nil)

	err := s.client.Get(s.ctx, key, dst)
	if err == datastore.ErrNoSuchEntity {
		return ErrNotfound
	}
	return err
}

// PutLastConstructedAt saves the lastConstructedAt into the datastore.
func (s CloudDataStore) PutLastConstructedAt(lastConstructedAt model.LastConstructedAt) error {
	key := datastore.NameKey(model.KindNameLastConstructedAt, lastConstructedAt.ID, nil)

	_, err := s.client.Put(s.ctx, key, &lastConstructedAt)
	return err
}

// Close closes the Store.
func (s CloudDataStore) Close() error {
	return s.client.Close()
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

func (s CloudDataStore) hasNext(q *datastore.Query, cursor datastore.Cursor) bool {
	_, err := s.client.Run(s.ctx, q.Start(cursor).Limit(1)).Next(nil)
	return err != iterator.Done
}
