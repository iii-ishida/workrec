package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"

	"github.com/go-chi/chi"
	"github.com/go-chi/cors"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/auth"
	"github.com/iii-ishida/workrec/server/command"
	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist"
)

const defaultPageSize = 50

// NewRouter returns the command http handler.
func NewRouter(userIDGetter auth.UserIDGetter) http.Handler {
	r := chi.NewRouter()

	cors := cors.New(cors.Options{
		AllowedOrigins: []string{util.GetClientOrigin()},
		AllowedMethods: []string{"GET", "POST", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"Content-Type", "Authorization"},
	})
	r.Use(cors.Handler)

	a := auth.New(auth.Dependency{UserIDGetter: userIDGetter})
	r.Use(a.Handler)

	r.Route("/v1", func(r chi.Router) {
		r.Get("/works", getWorkList)
		r.Post("/works", createWork)
		r.Patch("/works/{workID}", updateWork)
		r.Delete("/works/{workID}", deleteWork)
		r.Post("/works/{workID}:start", startWork)
		r.Post("/works/{workID}:pause", pauseWork)
		r.Post("/works/{workID}:resume", resumeWork)
		r.Post("/works/{workID}:finish", finishWork)
		r.Post("/works/{workID}:cancelFinish", cancelFinishWork)
	})
	return r
}

func getWorkList(w http.ResponseWriter, r *http.Request) {
	q, err := newWorkListQuery(r)

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	defer q.Close()

	userID := auth.GetUserID(r.Context())

	if err := q.ConstructWorks(userID); err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	pageSize, err := strconv.Atoi(r.URL.Query().Get("page_size"))
	if err != nil {
		pageSize = defaultPageSize
	}
	pageToken := r.URL.Query().Get("page_token")

	list, err := q.Get(userID, worklist.Param{PageSize: pageSize, PageToken: pageToken})

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	b, err := worklist.MarshalWorkListPb(list)
	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/octet-stream")
	w.WriteHeader(http.StatusOK)
	w.Write(b)
}

func createWork(w http.ResponseWriter, r *http.Request) {
	cmd, err := newCmd(r)

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	defer cmd.Close()

	var param CreateWorkRequestPb
	if err = unmarshalRequestBody(r, &param); err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	userID := auth.GetUserID(r.Context())
	if userID == "" {
		http.Error(w, http.StatusText(http.StatusUnauthorized), http.StatusUnauthorized)
		return
	}

	id, err := cmd.CreateWork(userID, command.CreateWorkParam{Title: param.Title})

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Location", fmt.Sprintf("%s/v1/works/%s", util.GetAPIOrigin(), id))
	w.WriteHeader(http.StatusCreated)
}

func updateWork(w http.ResponseWriter, r *http.Request) {
	cmd, err := newCmd(r)

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	defer cmd.Close()

	var param UpdateWorkRequestPb
	if err = unmarshalRequestBody(r, &param); err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	userID := auth.GetUserID(r.Context())
	workID := chi.URLParam(r, "workID")
	err = cmd.UpdateWork(userID, workID, command.UpdateWorkParam{Title: param.Title})

	if _, ok := err.(command.ValidationError); ok {
		log.Printf("error: %s", err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	} else if err == command.ErrForbidden {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err == command.ErrNotfound {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func deleteWork(w http.ResponseWriter, r *http.Request) {
	cmd, err := newCmd(r)

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	defer cmd.Close()

	userID := auth.GetUserID(r.Context())
	workID := chi.URLParam(r, "workID")
	err = cmd.DeleteWork(userID, workID)

	if err == command.ErrForbidden {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err == command.ErrForbidden {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err == command.ErrNotfound {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func startWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, command.Command.StartWork)
}

func pauseWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, command.Command.PauseWork)
}

func resumeWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, command.Command.ResumeWork)
}

func finishWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, command.Command.FinishWork)
}

func cancelFinishWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, command.Command.CancelFinishWork)
}

type changeWorkStateFunc func(command.Command, string, string, command.ChangeWorkStateParam) error

func changeWorkState(w http.ResponseWriter, r *http.Request, fn changeWorkStateFunc) {
	cmd, err := newCmd(r)

	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	defer cmd.Close()

	var param ChangeWorkStateRequestPb
	if err = unmarshalRequestBody(r, &param); err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	paramTime, err := ptypes.Timestamp(param.Time)
	if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	userID := auth.GetUserID(r.Context())
	workID := chi.URLParam(r, "workID")
	err = fn(cmd, userID, workID, command.ChangeWorkStateParam{Time: paramTime})

	if _, ok := err.(command.ValidationError); ok {
		log.Printf("error: %s", err.Error())
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	} else if err == command.ErrForbidden {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err == command.ErrNotfound {
		http.Error(w, http.StatusText(http.StatusNotFound), http.StatusNotFound)
		return
	} else if err != nil {
		log.Printf("error: %s", err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func newWorkListQuery(r *http.Request) (worklist.Query, error) {
	cloudStore, err := worklist.NewCloudDataStore(r)
	if err != nil {
		return worklist.Query{}, err
	}

	return worklist.NewQuery(worklist.Dependency{
		Store: cloudStore,
	}), nil
}

func newCmd(r *http.Request) (command.Command, error) {
	cloudStore, err := command.NewCloudDataStore(r)
	if err != nil {
		return command.Command{}, err
	}

	return command.New(command.Dependency{
		Store: cloudStore,
	}), nil
}

func unmarshalRequestBody(r *http.Request, pb proto.Message) error {
	buf, err := ioutil.ReadAll(r.Body)
	if err != nil {
		return err
	}

	if err = proto.Unmarshal(buf, pb); err != nil {
		return err
	}

	return nil
}
