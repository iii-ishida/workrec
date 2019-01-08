package worklist

import (
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/worklist/model"
	"github.com/iii-ishida/workrec/server/worklist/store"
	"net/http"
	"time"
)

// Dependency is a dependency for the worklist.
type Dependency struct {
	Store store.Store
}

// Query is a workrec query for work list.
type Query struct {
	dep Dependency
}

// NewQuery returns a new Query.
func NewQuery(dep Dependency) Query {
	return Query{dep: dep}
}

// NewCloudDataStore returns a new CloudDataStore
func NewCloudDataStore(r *http.Request) (store.CloudDataStore, error) {
	return store.NewCloudDataStore(r)
}

// MarshalWorkListPb takes a WorkList and encodes it into the wire format, returning the data.
func MarshalWorkListPb(list model.WorkList) ([]byte, error) {
	return model.MarshalWorkListPb(list)
}

// Param is a param for Get.
type Param struct {
	PageSize  int
	PageToken string
}

// Get returns a work list.
func (q Query) Get(param Param) (model.WorkList, error) {
	var works []model.WorkListItem
	nextPageToken, err := q.dep.Store.GetWorks(param.PageSize, param.PageToken, &works)

	if err != nil {
		return model.WorkList{}, err
	}

	return model.WorkList{
		Works:         works,
		NextPageToken: nextPageToken,
	}, nil
}

// ConstructWorks constructs works from events.
func (q Query) ConstructWorks() error {
	var lastConstructedAt model.LastConstructedAt
	if err := q.dep.Store.GetLastConstructedAt(model.LastConstructedAtID, &lastConstructedAt); err != nil {
		if err != store.ErrNotfound {
			return err
		}
	}

	var (
		pageSize  = 100
		pageToken = ""
		err       error
	)
	for {
		var events []event.Event
		pageToken, err = q.dep.Store.GetEvents(lastConstructedAt.Time, pageSize, pageToken, &events)

		if err != nil {
			return err
		}

		if err = q.applyEvents(events); err != nil {
			return err
		}

		if pageToken == "" {
			if len(events) != 0 {
				lastConstructedAt.ID = model.LastConstructedAtID
				lastConstructedAt.Time = events[len(events)-1].CreatedAt
				err = q.dep.Store.PutLastConstructedAt(lastConstructedAt)
				if err != nil {
					return err
				}
			}

			return nil
		}
	}
}

func (q Query) applyEvents(events []event.Event) error {
	grouped := map[string][]event.Event{}
	for _, e := range events {
		eventsForWork := grouped[e.WorkID]
		if eventsForWork == nil {
			eventsForWork = []event.Event{}
		}

		eventsForWork = append(eventsForWork, e)
		grouped[e.WorkID] = eventsForWork
	}

	for workID, eventsForWork := range grouped {
		var work model.WorkListItem
		if err := q.dep.Store.GetWork(workID, &work); err != nil {
			if err != store.ErrNotfound {
				return err
			}
		}

		applied := applyToWork(work, eventsForWork)

		if !applied.IsDeleted {
			if err := q.dep.Store.PutWork(applied); err != nil {
				return err
			}
		} else {
			if err := q.dep.Store.DeleteWork(applied.ID); err != nil {
				return err
			}
		}
	}

	return nil
}

func applyToWork(work model.WorkListItem, events []event.Event) model.WorkListItem {
	for _, e := range events {
		switch e.Action {
		case event.CreateWork:
			work = model.WorkListItem{
				ID:              string(e.WorkID),
				Title:           e.Title,
				State:           model.Unstarted,
				BaseWorkingTime: time.Time{},
				PausedAt:        time.Time{},
				StartedAt:       time.Time{},
				CreatedAt:       e.CreatedAt,
				UpdatedAt:       e.CreatedAt,
			}

		case event.UpdateWork:
			work.Title = e.Title
			work.UpdatedAt = e.CreatedAt

		case event.DeleteWork:
			work.IsDeleted = true

		case event.StartWork:
			work.State = model.Started
			work.BaseWorkingTime = e.Time
			work.StartedAt = e.Time
			work.UpdatedAt = e.CreatedAt

		case event.PauseWork:
			work.State = model.Paused
			work.PausedAt = e.Time
			work.UpdatedAt = e.CreatedAt

		case event.ResumeWork:
			work.State = model.Resumed
			work.BaseWorkingTime = work.CalculateBaseWorkingTime(e.Time)
			work.PausedAt = time.Time{}
			work.UpdatedAt = e.CreatedAt

		case event.FinishWork:
			if work.State != model.Paused {
				work.PausedAt = e.Time
			}

			work.State = model.Finished
			work.UpdatedAt = e.CreatedAt

		case event.CancelFinishWork:
			work.State = model.Paused
			work.UpdatedAt = e.CreatedAt
		}
	}
	return work
}

// Close closes the Store.
func (q Query) Close() error {
	if q.dep.Store == nil {
		return nil
	}

	return q.dep.Store.Close()
}
