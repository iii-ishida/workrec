package server

import (
	"io/ioutil"
	"net/http"
	"strconv"
	"workrec/api/event"
	"workrec/libs/logger"
	"workrec/libs/util"
	"workrec/query/repo"

	"github.com/gorilla/mux"
)

// Config is a a router configuration.
type Config struct {
	Repo repo.Repo
	Log  logger.Log
}

// WithRequest returns a Config with r.
func (c Config) WithRequest(r *http.Request) Config {
	c.Repo = c.Repo.WithRequest(r)
	c.Log = c.Log.WithRequest(r)
	return c
}

// NewRouterForQuery returns query router.
func NewRouterForQuery(conf Config) http.Handler {
	r := mux.NewRouter()
	r.HandleFunc("/query/v1/works", getWorks(conf)).Methods("GET")
	r.HandleFunc("/query/v1/works", updateWork(conf)).Methods("POST")
	return r
}

func getWorks(conf Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conf = conf.WithRequest(r)

		q := r.URL.Query()
		l, _ := strconv.Atoi(q.Get("limit"))
		n := q.Get("next")

		list, err := conf.Repo.GetList(l, n)
		if err != nil {
			conf.Log.Errorf("get error: %v", err)
			util.RespondHTTPErr(w, http.StatusInternalServerError, err)
			return
		}

		util.RespondJSON(w, http.StatusOK, list)
	}
}

func updateWork(conf Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conf = conf.WithRequest(r)

		b, err := ioutil.ReadAll(r.Body)
		if err != nil {
			conf.Log.Errorf("request body parse error: %v", err)
			util.RespondHTTPErr(w, http.StatusBadRequest, err)
			return
		}

		e, err := event.UnmarshalPb(b)
		if err != nil {
			conf.Log.Errorf("unmarshal error: %v", err)
			util.RespondHTTPErr(w, http.StatusBadRequest, err)
			return
		}

		if e.Type == event.Deleted {
			deleteWork(conf, e, w, r)
			return
		}
		processWork(conf, e, w, r)
	}
}

func processWork(conf Config, e event.Event, w http.ResponseWriter, r *http.Request) {
	wk, err := conf.Repo.GetWork(e.WorkID)
	if err != nil {
		conf.Log.Errorf("get work error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	if err := conf.Repo.SaveWork(wk.Process(e)); err != nil {
		conf.Log.Errorf("save work error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	util.RespondJSON(w, http.StatusOK, wk)
}

func deleteWork(conf Config, e event.Event, w http.ResponseWriter, r *http.Request) {
	if err := conf.Repo.DeleteWork(e.WorkID); err != nil {
		conf.Log.Errorf("delete work error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
	} else {
		util.RespondJSON(w, http.StatusOK, nil)
	}
}
