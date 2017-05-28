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
	var queryHost string
	if appengine.IsDevAppServer() {
		messagingHost = "http://localhost:8081"
		queryHost = "http://localhost:8082"
	} else {
		messagingHost = os.Getenv("MESSAGING_SERVICE_HOST")
		queryHost = os.Getenv("QUERY_SERVICE_HOST")
	}

	conf := Config{
		Repo:       repo.AppengineRepo,
		HTTPClient: httpclient.AppengineHTTPClient,
		Log:        logger.AppengineLog,
		PublishURL: messagingHost + "/messaging/v1/workrec/publish",
		QueryURL:   queryHost + "/query/v1/works",
	}
	http.Handle("/", NewRouterForAPI(conf))
}
