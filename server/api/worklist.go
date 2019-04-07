package api

import (
	"github.com/iii-ishida/workrec/server/api/model"
	"github.com/iii-ishida/workrec/server/api/store"
	"github.com/iii-ishida/workrec/server/event"
)

// GetWorkListParam is a param for GetWorkList.
type GetWorkListParam struct {
	PageSize  int
	PageToken string
}

// ConstructWorkList constructs WorkListItem from events.
func (a API) ConstructWorkList(userID string) error {
	if userID == "" {
		return ErrForbidden
	}

	var lastConstructedAt model.LastConstructedAt
	if err := a.dep.Store.GetLastConstructedAt(userID, &lastConstructedAt); err != nil {
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
		pageToken, err = a.dep.Store.GetEvents(userID, lastConstructedAt.Time, pageSize, pageToken, &events)

		if err != nil {
			return err
		}

		if err = a.applyEvents(events); err != nil {
			return err
		}

		if pageToken == "" {
			if len(events) != 0 {
				lastConstructedAt.ID = userID
				lastConstructedAt.Time = events[len(events)-1].CreatedAt
				err = a.dep.Store.PutLastConstructedAt(lastConstructedAt)
				if err != nil {
					return err
				}
			}

			return nil
		}
	}
}

func (a API) applyEvents(events []event.Event) error {
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
		if err := a.dep.Store.GetWorkListItem(workID, &work); err != nil {
			if err != store.ErrNotfound {
				return err
			}
		}

		applied := model.ApplyEventsToWork(work, eventsForWork)

		if !applied.IsDeleted {
			if err := a.dep.Store.PutWorkListItem(applied); err != nil {
				return err
			}
		} else {
			if err := a.dep.Store.DeleteWork(applied.ID); err != nil {
				return err
			}
		}
	}

	return nil
}

// GetWorkList returns a work list.
func (a API) GetWorkList(userID string, param GetWorkListParam) (model.WorkList, error) {
	if userID == "" {
		return model.WorkList{}, ErrForbidden
	}

	var works []model.WorkListItem
	nextPageToken, err := a.dep.Store.GetWorkList(userID, param.PageSize, param.PageToken, &works)

	if err != nil {
		return model.WorkList{}, err
	}

	return model.WorkList{
		Works:         works,
		NextPageToken: nextPageToken,
	}, nil
}

// MarshalWorkListPb takes a WorkList and encodes it into the wire format, returning the data.
func MarshalWorkListPb(list model.WorkList) ([]byte, error) {
	return model.MarshalWorkListPb(list)
}
