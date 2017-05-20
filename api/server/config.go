package server

import (
	"net/http"
	"workrec/api/repo"
	"workrec/libs/logger"
)

// Config is a a router configuration.
type Config struct {
	Repo repo.Repo
	Log  logger.Log
}

// WithRequest returns a Config with r.
func (c Config) WithRequest(r *http.Request) Config {
	c.Repo = c.Repo.WithRequest(r)
	c.Log = c.Log.WithRequest(r)
	return c
}
