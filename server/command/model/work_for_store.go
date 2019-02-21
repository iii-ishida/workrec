package model

import (
	"bytes"
	"encoding/gob"
	"time"

	"cloud.google.com/go/datastore"
)

// KindNameWork is a datastore kind name for Work.
const KindNameWork = "CommandWork"

type workForStore struct {
	ID        string
	EventID   string
	UserID    string
	Content   []byte `datastore:",noindex"`
	UpdatedAt time.Time
}

type workContentForStore struct {
	Title string
	Time  time.Time
	State WorkState
}

func (w workForStore) toWork() (Work, error) {
	var c workContentForStore

	dec := gob.NewDecoder(bytes.NewReader(w.Content))
	if err := dec.Decode(&c); err != nil {
		return Work{}, err
	}

	return Work{
		ID:        w.ID,
		EventID:   w.EventID,
		UserID:    w.UserID,
		Title:     c.Title,
		Time:      c.Time,
		State:     c.State,
		UpdatedAt: w.UpdatedAt,
	}, nil
}

// Load loads a Work from datastore.
func (w *Work) Load(ps []datastore.Property) error {
	var forStore workForStore
	if err := datastore.LoadStruct(&forStore, ps); err != nil {
		return err
	}

	wk, err := forStore.toWork()
	if err != nil {
		return err
	}

	*w = wk
	return nil
}

// Save saves a Work to datastore.
func (w *Work) Save() ([]datastore.Property, error) {
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)
	err := enc.Encode(workContentForStore{
		Title: w.Title,
		Time:  w.Time,
		State: w.State,
	})

	if err != nil {
		return nil, err
	}

	return []datastore.Property{
		{Name: "ID", Value: w.ID},
		{Name: "EventID", Value: w.EventID},
		{Name: "UserID", Value: w.UserID},
		{Name: "UpdatedAt", Value: w.UpdatedAt},
		{Name: "Content", Value: buf.Bytes(), NoIndex: true},
	}, nil
}
