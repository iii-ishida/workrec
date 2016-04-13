package db

import (
	"net/http"
	"strconv"
	"sync"

	"golang.org/x/net/context"
	"google.golang.org/appengine"
	"google.golang.org/appengine/datastore"

	"workrec/work"
)

const (
	_UnInitializedId = -1
	_Kind            = "Works"
)

var (
	currentId     = _UnInitializedId
	currentIdLock sync.RWMutex
)

type AppengineDB struct {
	ctx context.Context
}

func NewAppEngineDB(r *http.Request) AppengineDB {
	return AppengineDB{appengine.NewContext(r)}
}

func (db AppengineDB) NextWorkID() string {
	currentIdLock.Lock()
	defer currentIdLock.Unlock()

	if currentId == _UnInitializedId {
		currentId = db.maxWorkID()
	}
	currentId += 1

	return strconv.Itoa(currentId)
}

func (db AppengineDB) maxWorkID() int {
	query := datastore.NewQuery(_Kind).Order("-ID").Limit(1)
	workList := work.WorkList{}
	if _, err := query.GetAll(db.ctx, &workList); err != nil {
		return 0
	}
	if len(workList) == 0 {
		return 0
	}

	i, err := strconv.Atoi(workList[0].ID)
	if err != nil {
		return 0
	}
	return i
}

func (db AppengineDB) GetAllWorks() (work.WorkList, error) {
	query := datastore.NewQuery(_Kind)
	workList := work.WorkList{}
	_, err := query.GetAll(db.ctx, &workList)
	return workList, err
}

func (db AppengineDB) SaveWork(wk work.Work) (work.Work, error) {
	if wk.ID == "" {
		wk.ID = db.NextWorkID()
	}
	key := datastore.NewKey(db.ctx, _Kind, wk.ID, 0, nil)
	_, err := datastore.Put(db.ctx, key, &wk)
	return wk, err
}

func (db AppengineDB) DeleteWork(wk work.Work) error {
	key := datastore.NewKey(db.ctx, _Kind, wk.ID, 0, nil)
	return datastore.Delete(db.ctx, key)
}
