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

const _Kind = "Works"

var (
	currentId     = 0
	currentIdLock sync.RWMutex
)

type AppengineDB struct {
	ctx context.Context
}

func NewAppEngineDB(r *http.Request) AppengineDB {
	return AppengineDB{appengine.NewContext(r)}
}

func NextWorkID() string {
	currentIdLock.Lock()
	defer currentIdLock.Unlock()

	currentId += 1

	return strconv.Itoa(currentId)
}

func (db AppengineDB) GetAllWorks() (work.WorkList, error) {
	query := datastore.NewQuery(_Kind)
	workList := work.WorkList{}
	_, err := query.GetAll(db.ctx, &workList)
	return workList, err
}

func (db AppengineDB) SaveWork(wk work.Work) (work.Work, error) {
	if wk.ID == "" {
		wk.ID = NextWorkID()
	}
	key := datastore.NewKey(db.ctx, _Kind, wk.ID, 0, nil)
	_, err := datastore.Put(db.ctx, key, &wk)
	return wk, err
}

func (db AppengineDB) DeleteWork(wk work.Work) error {
	key := datastore.NewKey(db.ctx, _Kind, wk.ID, 0, nil)
	return datastore.Delete(db.ctx, key)
}
