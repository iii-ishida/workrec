package server

import (
	"net/http"
	"workrec/api/repo"
	"workrec/libs/logger"
)

func init() {
	conf := Config{
		Repo: repo.AppengineRepo,
		Log:  logger.AppengineLog,
	}
	http.Handle("/", NewRouterForAPI(conf))
}
