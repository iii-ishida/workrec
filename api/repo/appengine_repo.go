package repo

import (
	"net/http"
	"workrec/api/event"
	"workrec/api/model"

	"golang.org/x/net/context"
	"google.golang.org/appengine"
	"google.golang.org/appengine/datastore"
)

const (
	_KindWork  = "Work"
	_KindEvent = "Event"
)

// AppengineRepo is implements Repo for Appengine.
var AppengineRepo = &appengineRepo{}

type appengineRepo struct {
	ctx context.Context
}

func (*appengineRepo) WithRequest(req *http.Request) Repo {
	return &appengineRepo{ctx: appengine.NewContext(req)}
}

func (r *appengineRepo) RunInTransaction(f func() error) error {
	return datastore.RunInTransaction(r.ctx, func(tranCtx context.Context) error {
		originCtx := r.ctx
		defer func() { r.ctx = originCtx }()

		r.ctx = tranCtx
		return f()
	}, &datastore.TransactionOptions{XG: true})
}

func (r *appengineRepo) GetWork(workID string) (model.Work, error) {
	k := r.newWorkKey(workID)

	var w model.Work
	if err := datastore.Get(r.ctx, k, &w); err != nil {
		if err == datastore.ErrNoSuchEntity {
			return model.Work{}, nil
		}

		return model.Work{}, err
	}
	return w, nil
}

func (r *appengineRepo) SaveWork(w model.Work) error {
	if w.IsDeleted() {
		return r.deleteWork(w)
	}

	return r.putWork(w)
}

func (r *appengineRepo) GetEvent(eventID string) (event.Event, error) {
	k := r.newEventKey(eventID)

	var e event.Event
	if err := datastore.Get(r.ctx, k, &e); err != nil {
		if err == datastore.ErrNoSuchEntity {
			return event.Event{}, nil
		}

		return event.Event{}, err
	}
	return e, nil
}

func (r *appengineRepo) SaveEvent(e event.Event) error {
	k := r.newEventKey(e.ID)
	if _, err := datastore.Put(r.ctx, k, &e); err != nil {
		return err
	}
	return nil
}

func (r *appengineRepo) deleteWork(w model.Work) error {
	k := r.newWorkKey(w.ID)
	return datastore.Delete(r.ctx, k)
}

func (r *appengineRepo) putWork(w model.Work) error {
	k := r.newWorkKey(w.ID)
	if _, err := datastore.Put(r.ctx, k, &w); err != nil {
		return err
	}
	return nil
}

func (r *appengineRepo) newWorkKey(id string) *datastore.Key {
	return datastore.NewKey(r.ctx, _KindWork, id, 0, nil)
}

func (r *appengineRepo) newEventKey(id string) *datastore.Key {
	return datastore.NewKey(r.ctx, _KindEvent, id, 0, nil)
}
