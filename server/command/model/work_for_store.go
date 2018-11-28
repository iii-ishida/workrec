package model

import (
	"time"

	"cloud.google.com/go/datastore"
)

type workForStore struct {
	ID                string
	UpdatedAt         time.Time
	PbSerializedValue []byte `datastore:",noindex"`
}

func (w workForStore) toWork() (Work, error) {
	var work Work
	if err := UnmarshalWorkPb(w.PbSerializedValue, &work); err != nil {
		return Work{}, err
	}
	return work, nil
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
	pbSerializedValue, err := MarshalWorkPb(*w)
	if err != nil {
		return nil, err
	}

	return []datastore.Property{
		{Name: "ID", Value: w.ID},
		{Name: "UpdatedAt", Value: w.UpdatedAt},
		{Name: "PbSerializedValue", Value: pbSerializedValue, NoIndex: true},
	}, nil
}
