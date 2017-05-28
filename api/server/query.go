package server

import (
	"io/ioutil"
	"net/http"
	"workrec/libs/util"

	"github.com/gorilla/mux"
)

type queryParam struct {
	ID       string
	RawQuery string
}

func newQueryParam(r *http.Request) queryParam {
	return queryParam{
		ID:       mux.Vars(r)["id"],
		RawQuery: r.URL.RawQuery,
	}
}

type queryHandlerFunc func(Config, queryParam, http.ResponseWriter, *http.Request)

func queryHandler(conf Config, f queryHandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		conf = conf.WithRequest(r)
		p := newQueryParam(r)

		f(conf, p, w, r)
	}
}

func getWorks(conf Config, p queryParam, w http.ResponseWriter, r *http.Request) {
	res, err := conf.HTTPClient.Get(conf.QueryURL + "?" + p.RawQuery)
	if err != nil {
		conf.Log.Errorf("http get error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}
	defer res.Body.Close()

	b, err := ioutil.ReadAll(res.Body)
	if err != nil {
		conf.Log.Errorf("response read error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	util.RespondRaw(w, http.StatusOK, r.Header.Get("Content-Type"), b)
}

func getWork(conf Config, p queryParam, w http.ResponseWriter, r *http.Request) {
	work, err := conf.Repo.GetWork(p.ID)
	if err != nil {
		conf.Log.Errorf("work get error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	if work.IsEmpty() {
		http.NotFound(w, r)
		return
	}
	util.RespondJSON(w, http.StatusOK, work)
}
