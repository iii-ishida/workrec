package server

import (
	"encoding/json"
	"errors"
	"io/ioutil"
	"net/http"
	"strings"
	"workrec/libs/httpclient"
	"workrec/libs/logger"
	"workrec/libs/util"
	"workrec/messaging/repo"

	"github.com/gorilla/mux"
)

// Config is router configuration.
type Config struct {
	Repo       repo.Repo
	HTTPClient httpclient.HTTPClient
	Log        logger.Log
}

func (c Config) withRequest(r *http.Request) Config {
	c.Repo = c.Repo.WithRequest(r)
	c.HTTPClient = c.HTTPClient.WithRequest(r)
	c.Log = c.Log.WithRequest(r)
	return c
}

// NewRouterForMessaging returns query router.
func NewRouterForMessaging(conf Config) http.Handler {
	r := mux.NewRouter()

	type handlerWithConfig func(Config, string, http.ResponseWriter, *http.Request)
	f := func(h handlerWithConfig) func(http.ResponseWriter, *http.Request) {
		return func(w http.ResponseWriter, r *http.Request) {
			topic := mux.Vars(r)["topic"]
			h(conf.withRequest(r), topic, w, r)
		}
	}

	r.HandleFunc("/messaging/v1/{topic}", f(deleteTopic)).Methods("DELETE")
	r.HandleFunc("/messaging/v1/{topic}/publish", f(publishMessage)).Methods("POST")
	r.HandleFunc("/messaging/v1/{topic}/subscriptions", f(addSubscription)).Methods("PUT")

	return r
}

func deleteTopic(conf Config, topic string, w http.ResponseWriter, r *http.Request) {
	if err := conf.Repo.DeleteTopic(topic); err != nil {
		conf.Log.Errorf("topic delete error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
	} else {
		util.RespondJSON(w, http.StatusOK, nil)
	}
}

func publishMessage(conf Config, topic string, w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		conf.Log.Errorf("request read error: %v", err)
		util.RespondHTTPErr(w, http.StatusBadRequest, err)
		return
	}

	subscriptions, err := conf.Repo.GetSubscriptions(topic)
	if err != nil {
		conf.Log.Errorf("subscriptions get error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	if len(subscriptions) == 0 {
		http.NotFound(w, r)
		return
	}

	contentType := r.Header.Get("Content-Type")
	bodyString := string(body)
	hasError := false
	for _, s := range subscriptions {
		if err := conf.HTTPClient.AsyncPost(s, contentType, bodyString, 10); err != nil {
			conf.Log.Errorf("publish to %s error: %v", s, err)
			hasError = true
		}
	}

	if hasError {
		util.RespondHTTPErr(w, http.StatusInternalServerError, nil)
		return
	}

	util.RespondJSON(w, http.StatusOK, nil)
}

func addSubscription(conf Config, topic string, w http.ResponseWriter, r *http.Request) {
	subscriptions, err := conf.Repo.GetSubscriptions(topic)
	if err != nil {
		conf.Log.Errorf("subscriptions get error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	var p struct {
		Subscription string `json:"subscription"`
	}
	if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
		conf.Log.Errorf("request parse error: %v", err)
		util.RespondHTTPErr(w, http.StatusBadRequest, err)
		return
	}
	if !strings.HasPrefix(p.Subscription, "http") {
		util.RespondHTTPErr(w, http.StatusBadRequest, errors.New("invalid subscription"))
		return
	}

	subscriptions = appendUniq(subscriptions, p.Subscription)
	if err := conf.Repo.SaveSubscriptions(topic, subscriptions); err != nil {
		conf.Log.Errorf("subscriptions save error: %v", err)
		util.RespondHTTPErr(w, http.StatusInternalServerError, err)
		return
	}

	util.RespondJSON(w, http.StatusOK, nil)
}

func appendUniq(src []string, s string) []string {
	m := map[string]struct{}{}
	for _, v := range src {
		m[v] = struct{}{}
	}

	if _, ok := m[s]; ok {
		return src
	}
	return append(src, s)
}
