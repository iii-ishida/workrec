package main_test

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"

	"cloud.google.com/go/datastore"
	"github.com/golang/mock/gomock"
	"github.com/iii-ishida/workrec/server/auth"
	"github.com/iii-ishida/workrec/server/util"
	main "github.com/iii-ishida/workrec/server/web"
)

func doRequest(t *testing.T, req *http.Request) *http.Response {
	var (
		mockCtrl         = gomock.NewController(t)
		mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
	)
	defer mockCtrl.Finish()

	main.SetMockUserIDGetter(mockUserIDGetter)
	server := httptest.NewServer(main.NewRouter())
	defer server.Close()

	req.URL, _ = url.Parse(server.URL + req.URL.Path)

	res, _ := http.DefaultClient.Do(req)

	return res
}

func doLoggedInRequest(t *testing.T, userID string, req *http.Request) *http.Response {
	var (
		mockCtrl         = gomock.NewController(t)
		mockUserIDGetter = auth.NewMockUserIDGetter(mockCtrl)
	)
	defer mockCtrl.Finish()

	mockUserIDGetter.EXPECT().GetUserID(gomock.Any()).Return(userID, nil)

	main.SetMockUserIDGetter(mockUserIDGetter)
	server := httptest.NewServer(main.NewRouter())
	defer server.Close()

	req.URL, _ = url.Parse(server.URL + req.URL.Path)

	res, _ := http.DefaultClient.Do(req)

	return res
}

func newRequestWithLogin(userID, method, url string, body io.Reader) *http.Request {
	req, _ := http.NewRequest(method, url, body)
	req.Header.Add("Authorization", "Bearer someidtoken")
	ctx := auth.ContextWithUserID(req.Context(), userID)
	return req.WithContext(ctx)
}

func clearStore() {
	ctx := context.Background()
	client, _ := datastore.NewClient(ctx, util.GetProjectID())
	defer client.Close()

	kindQuery := datastore.NewQuery("__kind__").KeysOnly()
	kindKeys, _ := client.GetAll(ctx, kindQuery, nil)

	for _, kind := range kindKeys {
		q := datastore.NewQuery(kind.Name).KeysOnly()
		keys, _ := client.GetAll(ctx, q, nil)
		client.DeleteMulti(ctx, keys)
	}
}
