package model

import (
	"time"

	"cloud.google.com/go/datastore"
)

// KindNameWorkListItem is a datastore kind name for WorkListItem.
const KindNameWorkListItem = "WorkListItem"

type workListItemForStore struct {
	UserID            string
	ID                string
	CreatedAt         time.Time
	UpdatedAt         time.Time
	PbSerializedValue []byte `datastore:",noindex"`
}

func (w workListItemForStore) toWork() (WorkListItem, error) {
	var work WorkListItem
	if err := UnmarshalWorkListItemPb(w.PbSerializedValue, &work); err != nil {
		return WorkListItem{}, err
	}
	work.UserID = w.UserID
	return work, nil
}

// Load loads a Work from datastore.
func (w *WorkListItem) Load(ps []datastore.Property) error {
	var forStore workListItemForStore
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
func (w *WorkListItem) Save() ([]datastore.Property, error) {
	pbSerializedValue, err := MarshalWorkListItemPb(*w)
	if err != nil {
		return nil, err
	}

	return []datastore.Property{
		{Name: "UserID", Value: w.UserID},
		{Name: "ID", Value: w.ID},
		{Name: "CreatedAt", Value: w.CreatedAt},
		{Name: "UpdatedAt", Value: w.UpdatedAt},
		{Name: "PbSerializedValue", Value: pbSerializedValue, NoIndex: true},
	}, nil
}
