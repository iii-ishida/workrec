package server

import (
	"net/http"
	"workrec/api/repo"
	"workrec/libs/httpclient"
	"workrec/libs/logger"
)

// Config is a a router configuration.
type Config struct {
	Repo       repo.Repo
	HTTPClient httpclient.HTTPClient
	Log        logger.Log
	PublishURL string
}

// WithRequest returns a Config with r.
func (c Config) WithRequest(r *http.Request) Config {
	c.Repo = c.Repo.WithRequest(r)
	c.HTTPClient = c.HTTPClient.WithRequest(r)
	c.Log = c.Log.WithRequest(r)
	return c
}
