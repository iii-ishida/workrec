package event

import (
	"time"

	"cloud.google.com/go/datastore"
)

// KindName is a datastore kind name for Event.
const KindName = "Event"

type eventForStore struct {
	ID                string
	PrevID            string
	UserID            string
	WorkID            string
	Action            Action
	CreatedAt         time.Time
	PbSerializedValue []byte `datastore:",noindex"`
}

func (es eventForStore) toEvent() (Event, error) {
	var e Event
	if err := UnmarshalPb(es.PbSerializedValue, &e); err != nil {
		return Event{}, err
	}
	return e, nil
}

// Load loads a Event from datastore.
func (e *Event) Load(ps []datastore.Property) error {
	var es eventForStore
	if err := datastore.LoadStruct(&es, ps); err != nil {
		return err
	}

	evnt, err := es.toEvent()
	if err != nil {
		return err
	}

	*e = evnt
	return nil
}

// Save saves a Event to datastore.
func (e *Event) Save() ([]datastore.Property, error) {
	pbSerializedValue, err := MarshalPb(*e)
	if err != nil {
		return nil, err
	}

	return []datastore.Property{
		{Name: "ID", Value: e.ID},
		{Name: "PrevID", Value: e.PrevID},
		{Name: "UserID", Value: e.UserID},
		{Name: "WorkID", Value: e.WorkID},
		{Name: "Action", Value: int64(e.Action)},
		{Name: "CreatedAt", Value: e.CreatedAt},
		{Name: "PbSerializedValue", Value: pbSerializedValue, NoIndex: true},
	}, nil
}
