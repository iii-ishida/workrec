package server

import (
	"net/http"
	"workrec/libs/logger"
	"workrec/query/repo"

	"google.golang.org/appengine"
)

func init() {
	conf := Config{
		Repo: repo.AppengineRepo,
		Log:  logger.AppengineLog,
		ValidateRequest: func(r *http.Request) bool {
			return r.Header.Get("X-Appengine-Inbound-Appid") == appengine.AppID(appengine.NewContext(r))
		},
	}
	http.Handle("/", NewRouterForQuery(conf))
}
