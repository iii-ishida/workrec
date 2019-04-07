package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

	"github.com/go-chi/chi"
	"github.com/go-chi/cors"
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/api"
	"github.com/iii-ishida/workrec/server/auth"
	"github.com/iii-ishida/workrec/server/util"
)

const defaultPageSize = 50

// NewRouter returns the command http handler.
func NewRouter() http.Handler {
	r := chi.NewRouter()

	cors := cors.New(cors.Options{
		AllowedOrigins: []string{util.ClientOrigin()},
		AllowedMethods: []string{"GET", "POST", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders: []string{"Content-Type", "Authorization"},
	})
	r.Use(cors.Handler)

	a := newAuth()
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
	workAPI, err := newAPI(r)

	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}
	defer workAPI.Close()

	userID := auth.GetUserID(r.Context())

	if err := workAPI.ConstructWorkList(userID); err != nil {
		if err == api.ErrForbidden {
			util.RespondError(w, http.StatusForbidden)
			return
		}

		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}

	pageSize, err := strconv.Atoi(r.URL.Query().Get("page_size"))
	if err != nil {
		pageSize = defaultPageSize
	}
	pageToken := r.URL.Query().Get("page_token")

	list, err := workAPI.GetWorkList(userID, api.GetWorkListParam{PageSize: pageSize, PageToken: pageToken})

	if err != nil {
		if err == api.ErrForbidden {
			util.RespondError(w, http.StatusForbidden)
		} else {
			util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		}
		return
	}

	b, err := api.MarshalWorkListPb(list)
	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/octet-stream")
	w.WriteHeader(http.StatusOK)
	w.Write(b)
}

func createWork(w http.ResponseWriter, r *http.Request) {
	workAPI, err := newAPI(r)

	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}
	defer workAPI.Close()

	var param CreateWorkRequestPb
	if err = unmarshalRequestBody(r, &param); err != nil {
		util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		return
	}

	userID := auth.GetUserID(r.Context())
	if userID == "" {
		util.RespondError(w, http.StatusUnauthorized)
		return
	}

	id, err := workAPI.CreateWork(userID, api.CreateWorkParam{Title: param.Title})

	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}

	w.Header().Set("Location", fmt.Sprintf("%s/v1/works/%s", util.APIOrigin(), id))
	w.WriteHeader(http.StatusCreated)
}

func updateWork(w http.ResponseWriter, r *http.Request) {
	workAPI, err := newAPI(r)

	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}
	defer workAPI.Close()

	var param UpdateWorkRequestPb
	if err = unmarshalRequestBody(r, &param); err != nil {
		util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		return
	}

	userID := auth.GetUserID(r.Context())
	workID := chi.URLParam(r, "workID")
	err = workAPI.UpdateWork(userID, workID, api.UpdateWorkParam{Title: param.Title})

	if err != nil {
		if _, ok := err.(api.ValidationError); ok {
			util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		} else if err == api.ErrForbidden || err == api.ErrNotfound {
			util.RespondErrorAndLog(w, http.StatusNotFound, "error: %s", err.Error())
		} else {
			util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		}
		return
	}

	w.WriteHeader(http.StatusOK)
}

func deleteWork(w http.ResponseWriter, r *http.Request) {
	workAPI, err := newAPI(r)

	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}
	defer workAPI.Close()

	userID := auth.GetUserID(r.Context())
	workID := chi.URLParam(r, "workID")
	err = workAPI.DeleteWork(userID, workID)

	if err != nil {
		if _, ok := err.(api.ValidationError); ok {
			util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		} else if err == api.ErrForbidden || err == api.ErrNotfound {
			util.RespondErrorAndLog(w, http.StatusNotFound, "error: %s", err.Error())
		} else {
			util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		}
		return
	}

	w.WriteHeader(http.StatusOK)
}

func startWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, api.API.StartWork)
}

func pauseWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, api.API.PauseWork)
}

func resumeWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, api.API.ResumeWork)
}

func finishWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, api.API.FinishWork)
}

func cancelFinishWork(w http.ResponseWriter, r *http.Request) {
	changeWorkState(w, r, api.API.CancelFinishWork)
}

type changeWorkStateFunc func(api.API, string, string, api.ChangeWorkStateParam) error

func changeWorkState(w http.ResponseWriter, r *http.Request, fn changeWorkStateFunc) {
	workAPI, err := newAPI(r)

	if err != nil {
		util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		return
	}
	defer workAPI.Close()

	var param ChangeWorkStateRequestPb
	if err = unmarshalRequestBody(r, &param); err != nil {
		util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		return
	}

	paramTime, err := ptypes.Timestamp(param.Time)
	if err != nil {
		util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		return
	}

	userID := auth.GetUserID(r.Context())
	workID := chi.URLParam(r, "workID")
	err = fn(workAPI, userID, workID, api.ChangeWorkStateParam{Time: paramTime})

	if err != nil {
		if _, ok := err.(api.ValidationError); ok {
			util.RespondErrorAndLog(w, http.StatusBadRequest, "error: %s", err.Error())
		} else if err == api.ErrForbidden || err == api.ErrNotfound {
			util.RespondErrorAndLog(w, http.StatusNotFound, "error: %s", err.Error())
		} else {
			util.RespondErrorAndLog(w, http.StatusInternalServerError, "error: %s", err.Error())
		}
		return
	}

	w.WriteHeader(http.StatusOK)
}

// テスト時はモックに差し替える
var newAuth = func() auth.Auth {
	return auth.New(auth.Dependency{UserIDGetter: auth.NewFirebaseUserIDGetter()})
}

func newAPI(r *http.Request) (api.API, error) {
	cloudStore, err := api.NewCloudDataStore(r)
	if err != nil {
		return api.API{}, err
	}

	pub := api.NewCloudPublisher(r)
	return api.New(api.Dependency{
		Store:     cloudStore,
		Publisher: pub,
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
