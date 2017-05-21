package server

import (
	"net/http"
	"workrec/libs/httpclient"
	"workrec/libs/logger"
	"workrec/messaging/repo"
)

func init() {
	conf := Config{
		Repo:       repo.AppengineRepo,
		HTTPClient: httpclient.AppengineHTTPClient,
		Log:        logger.AppengineLog,
	}
	http.Handle("/", NewRouterForMessaging(conf))
}
