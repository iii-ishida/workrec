package server_test

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"workrec/query/server"
)

func TestValidateRequest(t *testing.T) {
	conf := server.Config{
		ValidateRequest: func(_ *http.Request) bool { return false },
	}
	server := httptest.NewServer(server.NewRouterForQuery(conf))
	defer server.Close()

	getReq, _ := http.NewRequest("GET", server.URL+"/query/v1/works", nil)
	postReq, _ := http.NewRequest("POST", server.URL+"/query/v1/works", nil)

	for i, req := range []*http.Request{getReq, postReq} {
		res, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Errorf("case %d: request error %v", i+1, err)
		}
		if res.StatusCode != http.StatusForbidden {
			t.Errorf("case %d: StatusCode = %d, wants = %d", i+1, res.StatusCode, http.StatusForbidden)
		}
	}
}
