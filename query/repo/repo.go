package repo

import (
	"net/http"
	"workrec/query/model"
)

// Repo is the repository for Works.
type Repo interface {
	WithRequest(*http.Request) Repo

	GetList(limit int, next string) (model.List, error)
	GetWork(id string) (model.Work, error)
	SaveWork(model.Work) error
	DeleteWork(id string) error
}
