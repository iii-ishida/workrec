package main_test

import (
	"net/http"
	"testing"
	"time"

	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist"
	"github.com/iii-ishida/workrec/server/worklist/model"
)

func TestListWork(t *testing.T) {
	userID := "some-userid"

	fixture := []model.WorkListItem{
		{UserID: userID, ID: util.NewUUID(), Title: "some title 01", State: model.Unstarted, CreatedAt: time.Now(), UpdatedAt: time.Now()},
		{UserID: userID, ID: util.NewUUID(), Title: "some title 02", State: model.Started, CreatedAt: time.Now(), UpdatedAt: time.Now()},
		{UserID: userID, ID: util.NewUUID(), Title: "some title 03", State: model.Paused, CreatedAt: time.Now(), UpdatedAt: time.Now()},
		{UserID: userID, ID: util.NewUUID(), Title: "some title 04", State: model.Resumed, CreatedAt: time.Now(), UpdatedAt: time.Now()},
		{UserID: userID, ID: util.NewUUID(), Title: "some title 05", State: model.Finished, CreatedAt: time.Now(), UpdatedAt: time.Now()},
	}

	t.Run("正常時", func(t *testing.T) {
		defer clearStore()
		createWorkListItems(fixture)

		req := newRequestWithLogin(userID, "GET", "/v1/works", nil)
		res := doLoggedInRequest(t, userID, req)

		t.Run("ステータスコードにStatusOKを設定すること", func(t *testing.T) {
			if res.StatusCode != http.StatusOK {
				t.Errorf("StatusCode = %d, wants = %d", res.StatusCode, http.StatusOK)
			}
		})
	})

	t.Run("未ログイン", func(t *testing.T) {
		defer clearStore()
		createWorkListItems(fixture)

		req, _ := http.NewRequest("GET", "/v1/works", nil)
		res := doRequest(t, req)

		t.Run("ステータスコードにStatusForbiddenを設定すること", func(t *testing.T) {
			if res.StatusCode != http.StatusForbidden {
				t.Errorf("StatusCode = %d, wants = %d", res.StatusCode, http.StatusForbidden)
			}
		})
	})
}

func createWorkListItems(items []model.WorkListItem) {
	r, _ := http.NewRequest("GET", "/", nil)
	s, _ := worklist.NewCloudDataStore(r)

	for _, item := range items {
		s.PutWork(item)
	}
}
