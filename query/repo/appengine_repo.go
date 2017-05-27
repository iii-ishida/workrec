package repo

import (
	"net/http"
	"workrec/query/model"

	"golang.org/x/net/context"

	"google.golang.org/appengine"
	"google.golang.org/appengine/datastore"
)

const (
	_KindWork    = "QueryWork"
	_DefaultLmit = 100
)

type appengineRepo struct {
	ctx context.Context
}

// AppengineRepo is an Appengine implementation of Repo.
var AppengineRepo = appengineRepo{}

func (appengineRepo) WithRequest(req *http.Request) Repo {
	return appengineRepo{ctx: appengine.NewContext(req)}
}

func (r appengineRepo) GetList(limit int, cursor string) (model.List, error) {
	start, err := datastore.DecodeCursor(cursor)
	if err != nil {
		return model.List{}, err
	}

	if limit <= 0 {
		limit = _DefaultLmit
	}

	works := []model.Work{}
	q := datastore.NewQuery(_KindWork).Order("-UpdatedAt").Limit(limit).Start(start)
	t := q.Run(r.ctx)
	for {
		var w model.Work
		if _, err := t.Next(&w); err != nil {
			if err == datastore.Done {
				break
			} else {
				return model.List{}, err
			}
		}
		works = append(works, w)
	}

	c, err := t.Cursor()
	if err != nil {
		return model.List{}, err
	}

	next := ""
	if r.hasNext(q, c) {
		next = c.String()
	}

	return model.List{Works: works, Next: next}, nil
}

func (r appengineRepo) GetWork(id string) (model.Work, error) {
	k := r.newWorkKey(id)

	var w model.Work
	if err := datastore.Get(r.ctx, k, &w); err != nil {
		if err == datastore.ErrNoSuchEntity {
			return model.Work{}, nil
		}

		return model.Work{}, err
	}
	return w, nil
}

func (r appengineRepo) SaveWork(w model.Work) error {
	k := r.newWorkKey(w.ID)
	if _, err := datastore.Put(r.ctx, k, &w); err != nil {
		return err
	}
	return nil
}

func (r appengineRepo) DeleteWork(id string) error {
	return datastore.Delete(r.ctx, r.newWorkKey(id))
}

func (r appengineRepo) hasNext(q *datastore.Query, c datastore.Cursor) bool {
	if _, err := q.Limit(1).Start(c).Run(r.ctx).Next(nil); err == nil {
		return true
	}
	return false
}

func (r appengineRepo) newWorkKey(id string) *datastore.Key {
	return datastore.NewKey(r.ctx, _KindWork, id, 0, nil)
}
