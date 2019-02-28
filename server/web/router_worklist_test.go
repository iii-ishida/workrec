package main_test

import (
	"net/http"
	"testing"
	"time"

	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist"
	"github.com/iii-ishida/workrec/server/worklist/model"
)

func TestListWork_OK(t *testing.T) {
	defer clearStore()

	var (
		userID  = "some-userid"
		fixture = []model.WorkListItem{
			{UserID: userID, ID: util.NewUUID(), Title: "some title 01", State: model.Unstarted, CreatedAt: time.Now(), UpdatedAt: time.Now()},
			{UserID: userID, ID: util.NewUUID(), Title: "some title 02", State: model.Started, CreatedAt: time.Now(), UpdatedAt: time.Now()},
			{UserID: userID, ID: util.NewUUID(), Title: "some title 03", State: model.Paused, CreatedAt: time.Now(), UpdatedAt: time.Now()},
			{UserID: userID, ID: util.NewUUID(), Title: "some title 04", State: model.Resumed, CreatedAt: time.Now(), UpdatedAt: time.Now()},
			{UserID: userID, ID: util.NewUUID(), Title: "some title 05", State: model.Finished, CreatedAt: time.Now(), UpdatedAt: time.Now()},
		}

		req = newRequestWithLogin(userID, "GET", "/v1/works", nil)
	)
	createWorkListItems(fixture)

	res := doLoggedInRequest(t, userID, req)

	t.Run("ステータスコードに200を設定すること", func(t *testing.T) {
		if res.StatusCode != 200 {
			t.Errorf("StatusCode = %d, wants = 200", res.StatusCode)
		}
	})
}

func TestListWork_NotLoggedIn(t *testing.T) {
	defer clearStore()

	var (
		userID  = "some-userid"
		fixture = []model.WorkListItem{
			{UserID: userID, ID: util.NewUUID(), Title: "some title 01", State: model.Unstarted, CreatedAt: time.Now(), UpdatedAt: time.Now()},
		}

		req, _ = http.NewRequest("GET", "/v1/works", nil)
	)
	createWorkListItems(fixture)

	res := doRequest(t, req)

	t.Run("ステータスコードに403を設定すること", func(t *testing.T) {
		if res.StatusCode != 403 {
			t.Errorf("StatusCode = %d, wants = 403", res.StatusCode)
		}
	})
}

func createWorkListItems(items []model.WorkListItem) {
	r, _ := http.NewRequest("GET", "/", nil)
	s, _ := worklist.NewCloudDataStore(r)

	for _, item := range items {
		s.PutWork(item)
	}
}
