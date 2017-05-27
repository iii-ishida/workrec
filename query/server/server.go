package server

import (
	"net/http"
	"workrec/libs/logger"
	"workrec/query/repo"
)

func init() {
	conf := Config{
		Repo: repo.AppengineRepo,
		Log:  logger.AppengineLog,
	}
	http.Handle("/", NewRouterForQuery(conf))
}
