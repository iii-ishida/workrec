package model

import (
	"time"

	"cloud.google.com/go/datastore"
)

type eventForStore struct {
	ID                EventID
	PrevID            EventID
	WorkID            WorkID
	Type              EventType
	CreatedAt         time.Time
	PbSerializedValue []byte `datastore:",noindex"`
}

func (e eventForStore) toEvent() (Event, error) {
	var event Event
	if err := UnmarshalEventPb(e.PbSerializedValue, &event); err != nil {
		return Event{}, err
	}
	return event, nil
}

// Load loads a Event from datastore.
func (e *Event) Load(ps []datastore.Property) error {
	var forStore eventForStore
	if err := datastore.LoadStruct(&forStore, ps); err != nil {
		return err
	}

	evnt, err := forStore.toEvent()
	if err != nil {
		return err
	}

	*e = evnt
	return nil
}

// Save saves a Event to datastore.
func (e *Event) Save() ([]datastore.Property, error) {
	pbSerializedValue, err := MarshalEventPb(*e)
	if err != nil {
		return nil, err
	}

	return []datastore.Property{
		{Name: "ID", Value: string(e.ID)},
		{Name: "PrevID", Value: string(e.PrevID)},
		{Name: "WorkID", Value: string(e.WorkID)},
		{Name: "Type", Value: int64(e.Type)},
		{Name: "CreatedAt", Value: e.CreatedAt},
		{Name: "PbSerializedValue", Value: pbSerializedValue, NoIndex: true},
	}, nil
}
