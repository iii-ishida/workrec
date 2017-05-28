package server

import (
	"net/http"
	"path"

	"github.com/gorilla/mux"
)

// NewRouterForAPI returns api router.
func NewRouterForAPI(conf Config) http.Handler {
	routes := []struct {
		method  string
		path    string
		handler http.HandlerFunc
	}{
		{"POST", "/", commandHandler(conf, createWork)},
		{"PUT", "/{id}", commandHandler(conf, toCommandFunc(updateWork))},
		{"DELETE", "/{id}", commandHandler(conf, toCommandFunc(deleteWork))},

		{"POST", "/{id}/start", commandHandler(conf, toCommandFunc(startWork))},
		{"POST", "/{id}/pause", commandHandler(conf, toCommandFunc(pauseWork))},
		{"POST", "/{id}/resume", commandHandler(conf, toCommandFunc(resumeWork))},
		{"POST", "/{id}/finish", commandHandler(conf, toCommandFunc(finishWork))},
	}

	r := mux.NewRouter()
	for _, route := range routes {
		p := path.Join("/api/v1/works", route.path)
		r.HandleFunc(p, route.handler).Methods(route.method)
	}
	return r
}
