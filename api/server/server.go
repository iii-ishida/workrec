package server

import (
	"net/http"
	"os"
	"workrec/api/repo"
	"workrec/libs/httpclient"
	"workrec/libs/logger"

	"google.golang.org/appengine"
)

func init() {
	var messagingHost string
	if appengine.IsDevAppServer() {
		messagingHost = "http://localhost:8081"
	} else {
		messagingHost = os.Getenv("MESSAGING_SERVICE_HOST")
	}

	conf := Config{
		Repo:       repo.AppengineRepo,
		HTTPClient: httpclient.AppengineHTTPClient,
		Log:        logger.AppengineLog,
		PublishURL: messagingHost + "/messaging/v1/workrec/publish",
	}
	http.Handle("/", NewRouterForAPI(conf))
}
