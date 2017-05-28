package server

import (
	"encoding/json"
	"errors"
	"net/http"
	"workrec/api/event"
	"workrec/api/model"
	"workrec/libs/util"

	"github.com/gorilla/mux"
)

var (
	// ErrWorkNotFound means that the requested work is not found.
	ErrWorkNotFound = errors.New("work is not found")
)

type commandParam struct {
	ID    string `json:"-"`
	Title string `json:"title,omitempty"`
	Time  int64  `json:"time,omitempty"`
}

func newCommandParam(r *http.Request) (commandParam, error) {
	var p commandParam
	if r.ContentLength > 0 {
		if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
			return commandParam{}, err
		}
	}

	p.ID = mux.Vars(r)["id"]
	return p, nil
}

type commandFunc func(Config, commandParam) (int, model.Work, error)
type updateCommandFunc func(model.Work, commandParam) model.Work

func toCommandFunc(f updateCommandFunc) commandFunc {
	return func(conf Config, p commandParam) (int, model.Work, error) {
		work, err := conf.Repo.GetWork(p.ID)
		if err != nil {
			conf.Log.Errorf("work get error: %v", err)
			return http.StatusInternalServerError, model.Work{}, err
		}
		if work.IsEmpty() {
			return http.StatusNotFound, model.Work{}, ErrWorkNotFound
		}
		updated := f(work, p)
		return http.StatusOK, updated, nil
	}
}

func commandHandler(conf Config, f commandFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		status, work, err := func() (int, model.Work, error) {
			conf = conf.WithRequest(r)

			p, err := newCommandParam(r)
			if err != nil {
				conf.Log.Errorf("commandParam parse error: %v", err)
				return http.StatusBadRequest, model.Work{}, err
			}

			status, work, err := commandInTransaction(conf, p, f)
			if err != nil {
				return status, model.Work{}, err
			}

			if pb, err := event.MarshalPb(work.Change()); err != nil {
				conf.Log.Errorf("event = %#v marshal error: %v", work.Change(), err)
			} else {
				if err := conf.HTTPClient.AsyncPost(conf.PublishURL, "application/octet-stream", string(pb), 10); err != nil {
					conf.Log.Errorf("event = %#v, post error: %v", work.Change(), err)
				}
			}

			return status, work, nil
		}()

		if err != nil {
			util.RespondHTTPErr(w, status, err)
		} else {
			util.RespondJSON(w, status, work)
		}
	}
}

func commandInTransaction(conf Config, p commandParam, f commandFunc) (int, model.Work, error) {
	var status int
	var updated model.Work
	err := conf.Repo.RunInTransaction(func() error {
		_status, _updated, err := f(conf, p)
		status = _status
		updated = _updated

		if err != nil {
			conf.Log.Errorf("work save error: %v", err)
			return err
		}

		if err = conf.Repo.SaveWork(_updated); err != nil {
			conf.Log.Errorf("work save error: %v", err)
			return err
		}
		if err = conf.Repo.SaveEvent(_updated.Change()); err != nil {
			conf.Log.Errorf("event save error: %v", err)
			return err
		}
		return nil
	})

	if err != nil {
		if err == ErrWorkNotFound {
			return http.StatusNotFound, model.Work{}, err
		}
		return http.StatusInternalServerError, model.Work{}, err
	}
	return status, updated, nil
}

func createWork(_ Config, p commandParam) (int, model.Work, error) {
	return http.StatusCreated, model.CreateWork(p.Title), nil
}

func updateWork(w model.Work, p commandParam) model.Work {
	return w.Update(p.Title)
}

func deleteWork(w model.Work, _ commandParam) model.Work {
	return w.Delete()
}

func startWork(w model.Work, p commandParam) model.Work {
	return w.Start(p.Time)
}

func pauseWork(w model.Work, p commandParam) model.Work {
	return w.Pause(p.Time)
}

func resumeWork(w model.Work, p commandParam) model.Work {
	return w.Resume(p.Time)
}

func finishWork(w model.Work, p commandParam) model.Work {
	return w.Finish(p.Time)
}
