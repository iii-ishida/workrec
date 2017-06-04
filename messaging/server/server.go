package server

import (
	"net/http"
	"workrec/libs/httpclient"
	"workrec/libs/logger"
	"workrec/messaging/repo"

	"google.golang.org/appengine"
)

func init() {
	conf := Config{
		Repo:       repo.AppengineRepo,
		HTTPClient: httpclient.AppengineHTTPClient,
		Log:        logger.AppengineLog,
		ValidateRequest: func(r *http.Request) bool {
			return r.Header.Get("X-Appengine-Inbound-Appid") == appengine.AppID(appengine.NewContext(r))
		},
	}
	http.Handle("/", NewRouterForMessaging(conf))
}
